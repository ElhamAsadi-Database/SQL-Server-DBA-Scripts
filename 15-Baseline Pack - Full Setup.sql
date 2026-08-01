/*
===============================================================================
SQL Server Baseline Pack - Full Setup
Target: SQL Server 2022
Timezone: Iran Local Time for SQL Agent schedules
Stored timestamps: UTC
Peak collection windows:
    09:00 - 15:00
    19:00 - 21:00

Includes:
- Wait stats snapshots + deltas
- File latency snapshots + deltas
- Optional WhoIsActive logging
- Weekly purge
===============================================================================
*/

SET NOCOUNT ON;
SET XACT_ABORT ON;

------------------------------------------------------------------------------
-- [0] CONFIG
------------------------------------------------------------------------------
DECLARE 
    @UtilityDB sysname              = N'DBA_Utility',
    @RetentionDays int              = 14,

    -- Sampling intervals during peak windows
    @WaitSampleMinutes int          = 5,
    @IoSampleMinutes int            = 5,

    -- WhoIsActive logging
    @EnableWhoIsActiveJob bit       = 0,      -- 0=disabled, 1=enabled
    @WhoIsActiveIntervalSeconds int = 60,

    -- Weekly purge schedule - IRAN LOCAL TIME
    -- SQL Agent day mapping:
    -- 1=Sunday, 2=Monday, 3=Tuesday, 4=Wednesday, 5=Thursday, 6=Friday, 7=Saturday
    @PurgeWeeklyDay int             = 6,      -- Friday
    @PurgeWeeklyAtHHMM char(5)      = '02:30';

------------------------------------------------------------------------------
-- [1] Create Utility Database
------------------------------------------------------------------------------
IF DB_ID(@UtilityDB) IS NULL
BEGIN
    DECLARE @sql nvarchar(max) = N'CREATE DATABASE ' + QUOTENAME(@UtilityDB) + N';';
    EXEC (@sql);
END
GO

------------------------------------------------------------------------------
-- [2] Create Schema, Tables, Indexes
------------------------------------------------------------------------------
USE DBA_Utility;
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'dba')
    EXEC('CREATE SCHEMA dba AUTHORIZATION dbo');
GO

IF OBJECT_ID(N'dba.Baseline_CollectionRuns', N'U') IS NULL
BEGIN
    CREATE TABLE dba.Baseline_CollectionRuns
    (
        run_id           bigint IDENTITY(1,1) NOT NULL
            CONSTRAINT PK_Baseline_CollectionRuns PRIMARY KEY,
        collector_name   sysname NOT NULL,
        start_time_utc   datetime2(0) NOT NULL,
        end_time_utc     datetime2(0) NULL,
        success          bit NOT NULL CONSTRAINT DF_BCR_success DEFAULT (0),
        info             nvarchar(4000) NULL
    );

    CREATE INDEX IX_BCR_collector_time
        ON dba.Baseline_CollectionRuns(collector_name, start_time_utc DESC);
END
GO

IF OBJECT_ID(N'dba.Baseline_WaitStats_Snapshot', N'U') IS NULL
BEGIN
    CREATE TABLE dba.Baseline_WaitStats_Snapshot
    (
        snapshot_time_utc     datetime2(0) NOT NULL,
        wait_type             nvarchar(120) NOT NULL,
        waiting_tasks_count   bigint NOT NULL,
        wait_time_ms          bigint NOT NULL,
        max_wait_time_ms      bigint NOT NULL,
        signal_wait_time_ms   bigint NOT NULL,
        CONSTRAINT PK_Baseline_WaitStats_Snapshot
            PRIMARY KEY CLUSTERED (snapshot_time_utc, wait_type)
    );

    CREATE INDEX IX_BWSS_wait_type_time
        ON dba.Baseline_WaitStats_Snapshot(wait_type, snapshot_time_utc DESC);
END
GO

IF OBJECT_ID(N'dba.Baseline_WaitStats_Delta', N'U') IS NULL
BEGIN
    CREATE TABLE dba.Baseline_WaitStats_Delta
    (
        interval_start_utc          datetime2(0) NOT NULL,
        interval_end_utc            datetime2(0) NOT NULL,
        wait_type                   nvarchar(120) NOT NULL,
        waiting_tasks_count_delta   bigint NOT NULL,
        wait_time_ms_delta          bigint NOT NULL,
        signal_wait_time_ms_delta   bigint NOT NULL,
        CONSTRAINT PK_Baseline_WaitStats_Delta
            PRIMARY KEY CLUSTERED (interval_end_utc, wait_type)
    );

    CREATE INDEX IX_BWSD_waittype_end
        ON dba.Baseline_WaitStats_Delta(wait_type, interval_end_utc DESC)
        INCLUDE (wait_time_ms_delta, signal_wait_time_ms_delta,
                 waiting_tasks_count_delta, interval_start_utc);
END
GO

IF OBJECT_ID(N'dba.Baseline_FileLatency_Snapshot', N'U') IS NULL
BEGIN
    CREATE TABLE dba.Baseline_FileLatency_Snapshot
    (
        snapshot_time_utc      datetime2(0) NOT NULL,
        database_id            int NOT NULL,
        file_id                int NOT NULL,
        file_type              nvarchar(10) NOT NULL,   -- ROWS / LOG
        num_of_reads           bigint NOT NULL,
        num_of_writes          bigint NOT NULL,
        io_stall_read_ms       bigint NOT NULL,
        io_stall_write_ms      bigint NOT NULL,
        size_on_disk_bytes     bigint NOT NULL,
        physical_name          nvarchar(260) NOT NULL,
        CONSTRAINT PK_Baseline_FileLatency_Snapshot
            PRIMARY KEY CLUSTERED (snapshot_time_utc, database_id, file_id)
    );

    CREATE INDEX IX_BFLS_dbfile_time
        ON dba.Baseline_FileLatency_Snapshot(database_id, file_id, snapshot_time_utc DESC)
        INCLUDE (file_type, num_of_reads, num_of_writes,
                 io_stall_read_ms, io_stall_write_ms, size_on_disk_bytes);
END
GO

IF OBJECT_ID(N'dba.Baseline_FileLatency_Delta', N'U') IS NULL
BEGIN
    CREATE TABLE dba.Baseline_FileLatency_Delta
    (
        interval_start_utc      datetime2(0) NOT NULL,
        interval_end_utc        datetime2(0) NOT NULL,
        database_id             int NOT NULL,
        file_id                 int NOT NULL,
        file_type               nvarchar(10) NOT NULL,
        reads_delta             bigint NOT NULL,
        writes_delta            bigint NOT NULL,
        read_stall_ms_delta     bigint NOT NULL,
        write_stall_ms_delta    bigint NOT NULL,
        avg_read_latency_ms     decimal(18,2) NULL,
        avg_write_latency_ms    decimal(18,2) NULL,
        physical_name           nvarchar(260) NOT NULL,
        CONSTRAINT PK_Baseline_FileLatency_Delta
            PRIMARY KEY CLUSTERED (interval_end_utc, database_id, file_id)
    );

    CREATE INDEX IX_BFLD_dbfile_end
        ON dba.Baseline_FileLatency_Delta(database_id, file_id, interval_end_utc DESC)
        INCLUDE (avg_read_latency_ms, avg_write_latency_ms,
                 reads_delta, writes_delta, physical_name, file_type);
END
GO

IF OBJECT_ID(N'dba.WhoIsActive_Log', N'U') IS NULL
BEGIN
    CREATE TABLE dba.WhoIsActive_Log
    (
        collection_time_utc datetime2(0) NOT NULL,
        session_id          smallint NULL,
        blocking_session_id smallint NULL,
        status              nvarchar(30) NULL,
        login_name          nvarchar(128) NULL,
        host_name           nvarchar(128) NULL,
        program_name        nvarchar(256) NULL,
        database_name       nvarchar(128) NULL,
        wait_info           nvarchar(4000) NULL,
        open_tran_count     int NULL,
        tran_start_time     datetime NULL,
        cpu                 int NULL,
        tempdb_allocations  bigint NULL,
        tempdb_current      bigint NULL,
        reads               bigint NULL,
        writes              bigint NULL,
        physical_reads      bigint NULL,
        used_memory         bigint NULL,
        sql_text            nvarchar(max) NULL,
        additional_info     xml NULL,
        CONSTRAINT PK_WhoIsActive_Log
            PRIMARY KEY CLUSTERED (collection_time_utc, session_id)
    );

    CREATE INDEX IX_WIA_blocking
        ON dba.WhoIsActive_Log(blocking_session_id, collection_time_utc DESC)
        INCLUDE (session_id, wait_info, status, program_name,
                 host_name, database_name, open_tran_count);

    CREATE INDEX IX_WIA_tran
        ON dba.WhoIsActive_Log(tran_start_time, collection_time_utc DESC)
        INCLUDE (session_id, open_tran_count, blocking_session_id,
                 program_name, host_name);
END
GO

------------------------------------------------------------------------------
-- [3] Procedures
------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE dba.Capture_WaitStats
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @t datetime2(0) = SYSUTCDATETIME();
    DECLARE @run_id bigint;

    INSERT dba.Baseline_CollectionRuns(collector_name, start_time_utc, success)
    VALUES (N'WaitStats', @t, 0);

    SET @run_id = SCOPE_IDENTITY();

    BEGIN TRY
        INSERT dba.Baseline_WaitStats_Snapshot
        (
            snapshot_time_utc, wait_type, waiting_tasks_count,
            wait_time_ms, max_wait_time_ms, signal_wait_time_ms
        )
        SELECT
            @t,
            ws.wait_type,
            ws.waiting_tasks_count,
            ws.wait_time_ms,
            ws.max_wait_time_ms,
            ws.signal_wait_time_ms
        FROM sys.dm_os_wait_stats AS ws
        WHERE ws.wait_type NOT LIKE N'SLEEP%'
          AND ws.wait_type NOT IN
          (
            N'BROKER_EVENTHANDLER', N'BROKER_RECEIVE_WAITFOR', N'BROKER_TASK_STOP',
            N'BROKER_TO_FLUSH', N'BROKER_TRANSMITTER', N'CHECKPOINT_QUEUE',
            N'CLR_AUTO_EVENT', N'CLR_MANUAL_EVENT', N'DIRTY_PAGE_POLL',
            N'DISPATCHER_QUEUE_SEMAPHORE', N'FT_IFTS_SCHEDULER_IDLE_WAIT',
            N'FT_IFTSHC_MUTEX', N'HADR_FILESTREAM_IOMGR_IOCOMPLETION',
            N'HADR_LOGCAPTURE_WAIT', N'HADR_NOTIFICATION_DEQUEUE',
            N'HADR_TIMER_TASK', N'HADR_WORK_QUEUE',
            N'LAZYWRITER_SLEEP', N'LOGMGR_QUEUE', N'ONDEMAND_TASK_QUEUE',
            N'PREEMPTIVE_OS_FLUSHFILEBUFFERS', N'REQUEST_FOR_DEADLOCK_SEARCH',
            N'RESOURCE_QUEUE', N'SERVER_IDLE_CHECK', N'SLEEP_SYSTEMTASK',
            N'SQLTRACE_BUFFER_FLUSH', N'SQLTRACE_INCREMENTAL_FLUSH_SLEEP',
            N'TRACEWRITE', N'WAITFOR', N'XE_DISPATCHER_WAIT', N'XE_TIMER_EVENT'
          );

        ;WITH last_two AS
        (
            SELECT
                wait_type,
                snapshot_time_utc,
                waiting_tasks_count,
                wait_time_ms,
                signal_wait_time_ms,
                ROW_NUMBER() OVER
                (
                    PARTITION BY wait_type
                    ORDER BY snapshot_time_utc DESC
                ) AS rn
            FROM dba.Baseline_WaitStats_Snapshot
        )
        INSERT dba.Baseline_WaitStats_Delta
        (
            interval_start_utc, interval_end_utc, wait_type,
            waiting_tasks_count_delta, wait_time_ms_delta, signal_wait_time_ms_delta
        )
        SELECT
            s2.snapshot_time_utc,
            s1.snapshot_time_utc,
            s1.wait_type,
            s1.waiting_tasks_count - s2.waiting_tasks_count,
            s1.wait_time_ms - s2.wait_time_ms,
            s1.signal_wait_time_ms - s2.signal_wait_time_ms
        FROM last_two s1
        JOIN last_two s2
          ON s1.wait_type = s2.wait_type
         AND s1.rn = 1
         AND s2.rn = 2
        WHERE (s1.wait_time_ms - s2.wait_time_ms) > 0;

        UPDATE dba.Baseline_CollectionRuns
        SET end_time_utc = SYSUTCDATETIME(),
            success = 1
        WHERE run_id = @run_id;
    END TRY
    BEGIN CATCH
        UPDATE dba.Baseline_CollectionRuns
        SET end_time_utc = SYSUTCDATETIME(),
            success = 0,
            info = CONCAT(N'Error ', ERROR_NUMBER(), N': ', ERROR_MESSAGE())
        WHERE run_id = @run_id;

        THROW;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE dba.Capture_FileLatency
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @t datetime2(0) = SYSUTCDATETIME();
    DECLARE @run_id bigint;

    INSERT dba.Baseline_CollectionRuns(collector_name, start_time_utc, success)
    VALUES (N'FileLatency', @t, 0);

    SET @run_id = SCOPE_IDENTITY();

    BEGIN TRY
        INSERT dba.Baseline_FileLatency_Snapshot
        (
            snapshot_time_utc, database_id, file_id, file_type,
            num_of_reads, num_of_writes, io_stall_read_ms, io_stall_write_ms,
            size_on_disk_bytes, physical_name
        )
        SELECT
            @t,
            vfs.database_id,
            vfs.file_id,
            mf.type_desc,
            vfs.num_of_reads,
            vfs.num_of_writes,
            vfs.io_stall_read_ms,
            vfs.io_stall_write_ms,
            vfs.size_on_disk_bytes,
            mf.physical_name
        FROM sys.dm_io_virtual_file_stats(NULL, NULL) AS vfs
        JOIN sys.master_files AS mf
          ON vfs.database_id = mf.database_id
         AND vfs.file_id = mf.file_id;

        ;WITH last_two AS
        (
            SELECT
                database_id,
                file_id,
                snapshot_time_utc,
                num_of_reads,
                num_of_writes,
                io_stall_read_ms,
                io_stall_write_ms,
                physical_name,
                file_type,
                ROW_NUMBER() OVER
                (
                    PARTITION BY database_id, file_id
                    ORDER BY snapshot_time_utc DESC
                ) AS rn
            FROM dba.Baseline_FileLatency_Snapshot
        )
        INSERT dba.Baseline_FileLatency_Delta
        (
            interval_start_utc, interval_end_utc,
            database_id, file_id, file_type,
            reads_delta, writes_delta,
            read_stall_ms_delta, write_stall_ms_delta,
            avg_read_latency_ms, avg_write_latency_ms,
            physical_name
        )
        SELECT
            s2.snapshot_time_utc,
            s1.snapshot_time_utc,
            s1.database_id,
            s1.file_id,
            s1.file_type,
            s1.num_of_reads - s2.num_of_reads,
            s1.num_of_writes - s2.num_of_writes,
            s1.io_stall_read_ms - s2.io_stall_read_ms,
            s1.io_stall_write_ms - s2.io_stall_write_ms,
            CASE
                WHEN (s1.num_of_reads - s2.num_of_reads) > 0
                THEN CONVERT(decimal(18,2),
                     (s1.io_stall_read_ms - s2.io_stall_read_ms) * 1.0
                     / (s1.num_of_reads - s2.num_of_reads))
                ELSE NULL
            END,
            CASE
                WHEN (s1.num_of_writes - s2.num_of_writes) > 0
                THEN CONVERT(decimal(18,2),
                     (s1.io_stall_write_ms - s2.io_stall_write_ms) * 1.0
                     / (s1.num_of_writes - s2.num_of_writes))
                ELSE NULL
            END,
            s1.physical_name
        FROM last_two s1
        JOIN last_two s2
          ON s1.database_id = s2.database_id
         AND s1.file_id = s2.file_id
         AND s1.rn = 1
         AND s2.rn = 2
        WHERE (s1.io_stall_read_ms - s2.io_stall_read_ms) > 0
           OR (s1.io_stall_write_ms - s2.io_stall_write_ms) > 0
           OR (s1.num_of_reads - s2.num_of_reads) > 0
           OR (s1.num_of_writes - s2.num_of_writes) > 0;

        UPDATE dba.Baseline_CollectionRuns
        SET end_time_utc = SYSUTCDATETIME(),
            success = 1
        WHERE run_id = @run_id;
    END TRY
    BEGIN CATCH
        UPDATE dba.Baseline_CollectionRuns
        SET end_time_utc = SYSUTCDATETIME(),
            success = 0,
            info = CONCAT(N'Error ', ERROR_NUMBER(), N': ', ERROR_MESSAGE())
        WHERE run_id = @run_id;

        THROW;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE dba.Purge_Baseline
    @RetentionDays int
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @cutoff datetime2(0) = DATEADD(DAY, -@RetentionDays, SYSUTCDATETIME());

    WHILE 1 = 1
    BEGIN
        DELETE TOP (5000)
        FROM dba.Baseline_WaitStats_Delta
        WHERE interval_end_utc < @cutoff;

        IF @@ROWCOUNT = 0 BREAK;
    END

    WHILE 1 = 1
    BEGIN
        DELETE TOP (5000)
        FROM dba.Baseline_WaitStats_Snapshot
        WHERE snapshot_time_utc < @cutoff;

        IF @@ROWCOUNT = 0 BREAK;
    END

    WHILE 1 = 1
    BEGIN
        DELETE TOP (5000)
        FROM dba.Baseline_FileLatency_Delta
        WHERE interval_end_utc < @cutoff;

        IF @@ROWCOUNT = 0 BREAK;
    END

    WHILE 1 = 1
    BEGIN
        DELETE TOP (5000)
        FROM dba.Baseline_FileLatency_Snapshot
        WHERE snapshot_time_utc < @cutoff;

        IF @@ROWCOUNT = 0 BREAK;
    END

    WHILE 1 = 1
    BEGIN
        DELETE TOP (5000)
        FROM dba.WhoIsActive_Log
        WHERE collection_time_utc < @cutoff;

        IF @@ROWCOUNT = 0 BREAK;
    END

    WHILE 1 = 1
    BEGIN
        DELETE TOP (5000)
        FROM dba.Baseline_CollectionRuns
        WHERE start_time_utc < @cutoff;

        IF @@ROWCOUNT = 0 BREAK;
    END
END
GO

------------------------------------------------------------------------------
-- [4] SQL Agent Jobs and Schedules
------------------------------------------------------------------------------
USE msdb;
GO

DECLARE 
    @UtilityDB sysname              = N'DBA_Utility',
    @RetentionDays int              = 14,
    @WaitSampleMinutes int          = 5,
    @IoSampleMinutes int            = 5,
    @EnableWhoIsActiveJob bit       = 0,
    @WhoIsActiveIntervalSeconds int = 60,
    @PurgeWeeklyDay int             = 6,        -- Friday
    @PurgeWeeklyAtHHMM char(5)      = '02:30';

DECLARE @active_start_time_0900 int = 090000;
DECLARE @active_end_time_1500   int = 150000;
DECLARE @active_start_time_1900 int = 190000;
DECLARE @active_end_time_2100   int = 210000;

DECLARE @hh int = TRY_CONVERT(int, LEFT(@PurgeWeeklyAtHHMM, 2));
DECLARE @mm int = TRY_CONVERT(int, RIGHT(@PurgeWeeklyAtHHMM, 2));
DECLARE @purge_time int = (@hh * 10000) + (@mm * 100);

------------------------------------------------------------------------------
-- WaitStats Job
------------------------------------------------------------------------------
IF NOT EXISTS
(
    SELECT 1
    FROM msdb.dbo.sysjobs
    WHERE name = N'DBA Baseline - WaitStats'
)
BEGIN
    EXEC msdb.dbo.sp_add_job
        @job_name = N'DBA Baseline - WaitStats',
        @enabled = 1,
        @description = N'Captures wait stats snapshot and delta during peak windows only',
        @owner_login_name = SUSER_SNAME();

    EXEC msdb.dbo.sp_add_jobstep
        @job_name = N'DBA Baseline - WaitStats',
        @step_name = N'Capture Wait Stats',
        @subsystem = N'TSQL',
        @database_name = @UtilityDB,
        @command = N'EXEC dba.Capture_WaitStats;',
        @on_success_action = 1,
        @on_fail_action = 2;

    EXEC msdb.dbo.sp_add_jobserver
        @job_name = N'DBA Baseline - WaitStats';
END

IF NOT EXISTS
(
    SELECT 1 FROM msdb.dbo.sysschedules
    WHERE name = N'DBA Baseline - WaitStats - Peak 09-15'
)
BEGIN
    EXEC msdb.dbo.sp_add_schedule
        @schedule_name = N'DBA Baseline - WaitStats - Peak 09-15',
        @enabled = 1,
        @freq_type = 4,
        @freq_interval = 1,
        @freq_subday_type = 4,
        @freq_subday_interval = @WaitSampleMinutes,
        @active_start_time = @active_start_time_0900,
        @active_end_time = @active_end_time_1500;
END

IF NOT EXISTS
(
    SELECT 1 FROM msdb.dbo.sysschedules
    WHERE name = N'DBA Baseline - WaitStats - Peak 19-21'
)
BEGIN
    EXEC msdb.dbo.sp_add_schedule
        @schedule_name = N'DBA Baseline - WaitStats - Peak 19-21',
        @enabled = 1,
        @freq_type = 4,
        @freq_interval = 1,
        @freq_subday_type = 4,
        @freq_subday_interval = @WaitSampleMinutes,
        @active_start_time = @active_start_time_1900,
        @active_end_time = @active_end_time_2100;
END

IF NOT EXISTS
(
    SELECT 1
    FROM msdb.dbo.sysjobs j
    JOIN msdb.dbo.sysjobschedules js ON j.job_id = js.job_id
    JOIN msdb.dbo.sysschedules s ON js.schedule_id = s.schedule_id
    WHERE j.name = N'DBA Baseline - WaitStats'
      AND s.name = N'DBA Baseline - WaitStats - Peak 09-15'
)
BEGIN
    EXEC msdb.dbo.sp_attach_schedule
        @job_name = N'DBA Baseline - WaitStats',
        @schedule_name = N'DBA Baseline - WaitStats - Peak 09-15';
END

IF NOT EXISTS
(
    SELECT 1
    FROM msdb.dbo.sysjobs j
    JOIN msdb.dbo.sysjobschedules js ON j.job_id = js.job_id
    JOIN msdb.dbo.sysschedules s ON js.schedule_id = s.schedule_id
    WHERE j.name = N'DBA Baseline - WaitStats'
      AND s.name = N'DBA Baseline - WaitStats - Peak 19-21'
)
BEGIN
    EXEC msdb.dbo.sp_attach_schedule
        @job_name = N'DBA Baseline - WaitStats',
        @schedule_name = N'DBA Baseline - WaitStats - Peak 19-21';
END

------------------------------------------------------------------------------
-- FileLatency Job
------------------------------------------------------------------------------
IF NOT EXISTS
(
    SELECT 1
    FROM msdb.dbo.sysjobs
    WHERE name = N'DBA Baseline - FileLatency'
)
BEGIN
    EXEC msdb.dbo.sp_add_job
        @job_name = N'DBA Baseline - FileLatency',
        @enabled = 1,
        @description = N'Captures file latency snapshot and delta during peak windows only',
        @owner_login_name = SUSER_SNAME();

    EXEC msdb.dbo.sp_add_jobstep
        @job_name = N'DBA Baseline - FileLatency',
        @step_name = N'Capture File Latency',
        @subsystem = N'TSQL',
        @database_name = @UtilityDB,
        @command = N'EXEC dba.Capture_FileLatency;',
        @on_success_action = 1,
        @on_fail_action = 2;

    EXEC msdb.dbo.sp_add_jobserver
        @job_name = N'DBA Baseline - FileLatency';
END

IF NOT EXISTS
(
    SELECT 1 FROM msdb.dbo.sysschedules
    WHERE name = N'DBA Baseline - FileLatency - Peak 09-15'
)
BEGIN
    EXEC msdb.dbo.sp_add_schedule
        @schedule_name = N'DBA Baseline - FileLatency - Peak 09-15',
        @enabled = 1,
        @freq_type = 4,
        @freq_interval = 1,
        @freq_subday_type = 4,
        @freq_subday_interval = @IoSampleMinutes,
        @active_start_time = @active_start_time_0900,
        @active_end_time = @active_end_time_1500;
END

IF NOT EXISTS
(
    SELECT 1 FROM msdb.dbo.sysschedules
    WHERE name = N'DBA Baseline - FileLatency - Peak 19-21'
)
BEGIN
    EXEC msdb.dbo.sp_add_schedule
        @schedule_name = N'DBA Baseline - FileLatency - Peak 19-21',
        @enabled = 1,
        @freq_type = 4,
        @freq_interval = 1,
        @freq_subday_type = 4,
        @freq_subday_interval = @IoSampleMinutes,
        @active_start_time = @active_start_time_1900,
        @active_end_time = @active_end_time_2100;
END

IF NOT EXISTS
(
    SELECT 1
    FROM msdb.dbo.sysjobs j
    JOIN msdb.dbo.sysjobschedules js ON j.job_id = js.job_id
    JOIN msdb.dbo.sysschedules s ON js.schedule_id = s.schedule_id
    WHERE j.name = N'DBA Baseline - FileLatency'
      AND s.name = N'DBA Baseline - FileLatency - Peak 09-15'
)
BEGIN
    EXEC msdb.dbo.sp_attach_schedule
        @job_name = N'DBA Baseline - FileLatency',
        @schedule_name = N'DBA Baseline - FileLatency - Peak 09-15';
END

IF NOT EXISTS
(
    SELECT 1
    FROM msdb.dbo.sysjobs j
    JOIN msdb.dbo.sysjobschedules js ON j.job_id = js.job_id
    JOIN msdb.dbo.sysschedules s ON js.schedule_id = s.schedule_id
    WHERE j.name = N'DBA Baseline - FileLatency'
      AND s.name = N'DBA Baseline - FileLatency - Peak 19-21'
)
BEGIN
    EXEC msdb.dbo.sp_attach_schedule
        @job_name = N'DBA Baseline - FileLatency',
        @schedule_name = N'DBA Baseline - FileLatency - Peak 19-21';
END

------------------------------------------------------------------------------
-- Weekly Purge Job
------------------------------------------------------------------------------
IF NOT EXISTS
(
    SELECT 1
    FROM msdb.dbo.sysjobs
    WHERE name = N'DBA Baseline - Purge Weekly'
)
BEGIN
    EXEC msdb.dbo.sp_add_job
        @job_name = N'DBA Baseline - Purge Weekly',
        @enabled = 1,
        @description = N'Purges baseline history older than retention period once per week',
        @owner_login_name = SUSER_SNAME();

    EXEC msdb.dbo.sp_add_jobstep
        @job_name = N'DBA Baseline - Purge Weekly',
        @step_name = N'Purge Old Rows',
        @subsystem = N'TSQL',
        @database_name = @UtilityDB,
        @command = N'EXEC dba.Purge_Baseline @RetentionDays = 14;',
        @on_success_action = 1,
        @on_fail_action = 2;

    EXEC msdb.dbo.sp_add_jobserver
        @job_name = N'DBA Baseline - Purge Weekly';
END

IF NOT EXISTS
(
    SELECT 1 FROM msdb.dbo.sysschedules
    WHERE name = N'DBA Baseline - Purge Weekly - Schedule'
)
BEGIN
    DECLARE @dowMask int =
        CASE @PurgeWeeklyDay
            WHEN 1 THEN 1
            WHEN 2 THEN 2
            WHEN 3 THEN 4
            WHEN 4 THEN 8
            WHEN 5 THEN 16
            WHEN 6 THEN 32
            WHEN 7 THEN 64
        END;

    EXEC msdb.dbo.sp_add_schedule
        @schedule_name = N'DBA Baseline - Purge Weekly - Schedule',
        @enabled = 1,
        @freq_type = 8,
        @freq_interval = @dowMask,
        @active_start_time = @purge_time;
END

IF NOT EXISTS
(
    SELECT 1
    FROM msdb.dbo.sysjobs j
    JOIN msdb.dbo.sysjobschedules js ON j.job_id = js.job_id
    JOIN msdb.dbo.sysschedules s ON js.schedule_id = s.schedule_id
    WHERE j.name = N'DBA Baseline - Purge Weekly'
      AND s.name = N'DBA Baseline - Purge Weekly - Schedule'
)
BEGIN
    EXEC msdb.dbo.sp_attach_schedule
        @job_name = N'DBA Baseline - Purge Weekly',
        @schedule_name = N'DBA Baseline - Purge Weekly - Schedule';
END

------------------------------------------------------------------------------
-- Optional WhoIsActive Logging Job
------------------------------------------------------------------------------
IF NOT EXISTS
(
    SELECT 1
    FROM msdb.dbo.sysjobs
    WHERE name = N'DBA Baseline - WhoIsActive Logging'
)
BEGIN
    EXEC msdb.dbo.sp_add_job
        @job_name = N'DBA Baseline - WhoIsActive Logging',
        @enabled = CASE WHEN @EnableWhoIsActiveJob = 1 THEN 1 ELSE 0 END,
        @description = N'Logs sp_WhoIsActive output during peak windows only',
        @owner_login_name = SUSER_SNAME();

    EXEC msdb.dbo.sp_add_jobstep
        @job_name = N'DBA Baseline - WhoIsActive Logging',
        @step_name = N'Capture WhoIsActive',
        @subsystem = N'TSQL',
        @database_name = @UtilityDB,
        @command = N'
DECLARE @t TABLE
(
    [dd hh:mm:ss.mss] varchar(8000) NULL,
    session_id smallint NULL,
    sql_text nvarchar(max) NULL,
    login_name nvarchar(128) NULL,
    wait_info nvarchar(4000) NULL,
    status nvarchar(30) NULL,
    blocking_session_id smallint NULL,
    open_tran_count int NULL,
    host_name nvarchar(128) NULL,
    program_name nvarchar(256) NULL,
    database_name nvarchar(128) NULL,
    tran_start_time datetime NULL,
    cpu int NULL,
    tempdb_allocations bigint NULL,
    tempdb_current bigint NULL,
    reads bigint NULL,
    writes bigint NULL,
    physical_reads bigint NULL,
    used_memory bigint NULL,
    additional_info xml NULL
);

INSERT @t
EXEC master.dbo.sp_WhoIsActive
    @get_task_info = 2,
    @get_locks = 1,
    @get_additional_info = 1,
    @get_outer_command = 1,
    @get_plans = 0,
    @find_block_leaders = 1;

INSERT dba.WhoIsActive_Log
(
    collection_time_utc, session_id, blocking_session_id, status,
    login_name, host_name, program_name, database_name, wait_info,
    open_tran_count, tran_start_time, cpu, tempdb_allocations, tempdb_current,
    reads, writes, physical_reads, used_memory, sql_text, additional_info
)
SELECT
    SYSUTCDATETIME(),
    session_id, blocking_session_id, status,
    login_name, host_name, program_name, database_name, wait_info,
    open_tran_count, tran_start_time, cpu, tempdb_allocations, tempdb_current,
    reads, writes, physical_reads, used_memory, sql_text, additional_info
FROM @t
WHERE session_id IS NOT NULL;
',
        @on_success_action = 1,
        @on_fail_action = 2;

    EXEC msdb.dbo.sp_add_jobserver
        @job_name = N'DBA Baseline - WhoIsActive Logging';
END

IF NOT EXISTS
(
    SELECT 1 FROM msdb.dbo.sysschedules
    WHERE name = N'DBA Baseline - WhoIsActive - Peak 09-15'
)
BEGIN
    EXEC msdb.dbo.sp_add_schedule
        @schedule_name = N'DBA Baseline - WhoIsActive - Peak 09-15',
        @enabled = 1,
        @freq_type = 4,
        @freq_interval = 1,
        @freq_subday_type = 2,
        @freq_subday_interval = @WhoIsActiveIntervalSeconds,
        @active_start_time = @active_start_time_0900,
        @active_end_time = @active_end_time_1500;
END

IF NOT EXISTS
(
    SELECT 1 FROM msdb.dbo.sysschedules
    WHERE name = N'DBA Baseline - WhoIsActive - Peak 19-21'
)
BEGIN
    EXEC msdb.dbo.sp_add_schedule
        @schedule_name = N'DBA Baseline - WhoIsActive - Peak 19-21',
        @enabled = 1,
        @freq_type = 4,
        @freq_interval = 1,
        @freq_subday_type = 2,
        @freq_subday_interval = @WhoIsActiveIntervalSeconds,
        @active_start_time = @active_start_time_1900,
        @active_end_time = @active_end_time_2100;
END

IF NOT EXISTS
(
    SELECT 1
    FROM msdb.dbo.sysjobs j
    JOIN msdb.dbo.sysjobschedules js ON j.job_id = js.job_id
    JOIN msdb.dbo.sysschedules s ON js.schedule_id = s.schedule_id
    WHERE j.name = N'DBA Baseline - WhoIsActive Logging'
      AND s.name = N'DBA Baseline - WhoIsActive - Peak 09-15'
)
BEGIN
    EXEC msdb.dbo.sp_attach_schedule
        @job_name = N'DBA Baseline - WhoIsActive Logging',
        @schedule_name = N'DBA Baseline - WhoIsActive - Peak 09-15';
END

IF NOT EXISTS
(
    SELECT 1
    FROM msdb.dbo.sysjobs j
    JOIN msdb.dbo.sysjobschedules js ON j.job_id = js.job_id
    JOIN msdb.dbo.sysschedules s ON js.schedule_id = s.schedule_id
    WHERE j.name = N'DBA Baseline - WhoIsActive Logging'
      AND s.name = N'DBA Baseline - WhoIsActive - Peak 19-21'
)
BEGIN
    EXEC msdb.dbo.sp_attach_schedule
        @job_name = N'DBA Baseline - WhoIsActive Logging',
        @schedule_name = N'DBA Baseline - WhoIsActive - Peak 19-21';
END
GO

------------------------------------------------------------------------------
-- [5] Smoke Test
------------------------------------------------------------------------------
USE DBA_Utility;
GO

EXEC dba.Capture_WaitStats;
EXEC dba.Capture_FileLatency;
GO

PRINT 'DONE - Baseline Pack installed successfully.';
PRINT 'Collectors run only during Iran local peak windows: 09:00-15:00 and 19:00-21:00.';
PRINT 'Stored timestamps are UTC.';
PRINT 'Weekly purge is enabled.';
PRINT 'WhoIsActive job is optional and currently disabled unless CONFIG changed.';
GO
