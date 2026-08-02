USE [master];
GO
/*
ALTER DATABASE [BaseInfoDB] ADD FILEGROUP [FG_AccountHistory_PRE2026Q2];
ALTER DATABASE [BaseInfoDB] ADD FILEGROUP [FG_AccountHistory_2026Q2];
ALTER DATABASE [BaseInfoDB] ADD FILEGROUP [FG_AccountHistory_2026Q3];
ALTER DATABASE [BaseInfoDB] ADD FILEGROUP [FG_AccountHistory_2026Q4];

ALTER DATABASE [BaseInfoDB] ADD FILEGROUP [FG_AccountHistory_2027Q1];
ALTER DATABASE [BaseInfoDB] ADD FILEGROUP [FG_AccountHistory_2027Q2];
ALTER DATABASE [BaseInfoDB] ADD FILEGROUP [FG_AccountHistory_2027Q3];
ALTER DATABASE [BaseInfoDB] ADD FILEGROUP [FG_AccountHistory_2027Q4];

ALTER DATABASE [BaseInfoDB] ADD FILEGROUP [FG_AccountHistory_2028Q1];
ALTER DATABASE [BaseInfoDB] ADD FILEGROUP [FG_AccountHistory_2028Q2];
ALTER DATABASE [BaseInfoDB] ADD FILEGROUP [FG_AccountHistory_2028Q3];
ALTER DATABASE [BaseInfoDB] ADD FILEGROUP [FG_AccountHistory_2028Q4];

ALTER DATABASE [BaseInfoDB] ADD FILEGROUP [FG_AccountHistory_2029Q1];
ALTER DATABASE [BaseInfoDB] ADD FILEGROUP [FG_AccountHistory_2029Q2];
ALTER DATABASE [BaseInfoDB] ADD FILEGROUP [FG_AccountHistory_2029Q3];
ALTER DATABASE [BaseInfoDB] ADD FILEGROUP [FG_AccountHistory_2029Q4];

ALTER DATABASE [BaseInfoDB] ADD FILEGROUP [FG_AccountHistory_2030Q1];
ALTER DATABASE [BaseInfoDB] ADD FILEGROUP [FG_AccountHistory_2030Q2];
ALTER DATABASE [BaseInfoDB] ADD FILEGROUP [FG_AccountHistory_2030Q3];
ALTER DATABASE [BaseInfoDB] ADD FILEGROUP [FG_AccountHistory_2030Q4];

ALTER DATABASE [BaseInfoDB] ADD FILEGROUP [FG_AccountHistory_FUTURE];
GO
*/
/*
USE [master];
GO

ALTER DATABASE [BaseInfoDB]
ADD FILE
(
    NAME = N'BaseInfoDB_AccountHistory_PRE2026Q2',
    FILENAME = N'E:\DB-DATA\BaseInfoDB\BaseInfoDB_AccountHistory_PRE2026Q2.ndf',
    SIZE = 1024KB,
    FILEGROWTH = 1024KB
)
TO FILEGROUP [FG_AccountHistory_PRE2026Q2];

ALTER DATABASE [BaseInfoDB]
ADD FILE
(
    NAME = N'BaseInfoDB_AccountHistory_2026Q2',
    FILENAME = N'E:\DB-DATA\BaseInfoDB\BaseInfoDB_AccountHistory_2026Q2.ndf',
    SIZE = 1024KB,
    FILEGROWTH = 1024KB
)
TO FILEGROUP [FG_AccountHistory_2026Q2];

ALTER DATABASE [BaseInfoDB]
ADD FILE
(
    NAME = N'BaseInfoDB_AccountHistory_2026Q3',
    FILENAME = N'E:\DB-DATA\BaseInfoDB\BaseInfoDB_AccountHistory_2026Q3.ndf',
    SIZE = 1024KB,
    FILEGROWTH = 1024KB
)
TO FILEGROUP [FG_AccountHistory_2026Q3];

ALTER DATABASE [BaseInfoDB]
ADD FILE
(
    NAME = N'BaseInfoDB_AccountHistory_2026Q4',
    FILENAME = N'E:\DB-DATA\BaseInfoDB\BaseInfoDB_AccountHistory_2026Q4.ndf',
    SIZE = 1024KB,
    FILEGROWTH = 1024KB
)
TO FILEGROUP [FG_AccountHistory_2026Q4];

ALTER DATABASE [BaseInfoDB]
ADD FILE
(
    NAME = N'BaseInfoDB_AccountHistory_2027Q1',
    FILENAME = N'E:\DB-DATA\BaseInfoDB\BaseInfoDB_AccountHistory_2027Q1.ndf',
    SIZE = 1024KB,
    FILEGROWTH = 1024KB
)
TO FILEGROUP [FG_AccountHistory_2027Q1];

ALTER DATABASE [BaseInfoDB]
ADD FILE
(
    NAME = N'BaseInfoDB_AccountHistory_2027Q2',
    FILENAME = N'E:\DB-DATA\BaseInfoDB\BaseInfoDB_AccountHistory_2027Q2.ndf',
    SIZE = 1024KB,
    FILEGROWTH = 1024KB
)
TO FILEGROUP [FG_AccountHistory_2027Q2];

ALTER DATABASE [BaseInfoDB]
ADD FILE
(
    NAME = N'BaseInfoDB_AccountHistory_2027Q3',
    FILENAME = N'E:\DB-DATA\BaseInfoDB\BaseInfoDB_AccountHistory_2027Q3.ndf',
    SIZE = 1024KB,
    FILEGROWTH = 1024KB
)
TO FILEGROUP [FG_AccountHistory_2027Q3];

ALTER DATABASE [BaseInfoDB]
ADD FILE
(
    NAME = N'BaseInfoDB_AccountHistory_2027Q4',
    FILENAME = N'E:\DB-DATA\BaseInfoDB\BaseInfoDB_AccountHistory_2027Q4.ndf',
    SIZE = 1024KB,
    FILEGROWTH = 1024KB
)
TO FILEGROUP [FG_AccountHistory_2027Q4];

ALTER DATABASE [BaseInfoDB]
ADD FILE
(
    NAME = N'BaseInfoDB_AccountHistory_2028Q1',
    FILENAME = N'E:\DB-DATA\BaseInfoDB\BaseInfoDB_AccountHistory_2028Q1.ndf',
    SIZE = 1024KB,
    FILEGROWTH = 1024KB
)
TO FILEGROUP [FG_AccountHistory_2028Q1];

ALTER DATABASE [BaseInfoDB]
ADD FILE
(
    NAME = N'BaseInfoDB_AccountHistory_2028Q2',
    FILENAME = N'E:\DB-DATA\BaseInfoDB\BaseInfoDB_AccountHistory_2028Q2.ndf',
    SIZE = 1024KB,
    FILEGROWTH = 1024KB
)
TO FILEGROUP [FG_AccountHistory_2028Q2];

ALTER DATABASE [BaseInfoDB]
ADD FILE
(
    NAME = N'BaseInfoDB_AccountHistory_2028Q3',
    FILENAME = N'E:\DB-DATA\BaseInfoDB\BaseInfoDB_AccountHistory_2028Q3.ndf',
    SIZE = 1024KB,
    FILEGROWTH = 1024KB
)
TO FILEGROUP [FG_AccountHistory_2028Q3];

ALTER DATABASE [BaseInfoDB]
ADD FILE
(
    NAME = N'BaseInfoDB_AccountHistory_2028Q4',
    FILENAME = N'E:\DB-DATA\BaseInfoDB\BaseInfoDB_AccountHistory_2028Q4.ndf',
    SIZE = 1024KB,
    FILEGROWTH = 1024KB
)
TO FILEGROUP [FG_AccountHistory_2028Q4];

ALTER DATABASE [BaseInfoDB]
ADD FILE
(
    NAME = N'BaseInfoDB_AccountHistory_2029Q1',
    FILENAME = N'E:\DB-DATA\BaseInfoDB\BaseInfoDB_AccountHistory_2029Q1.ndf',
    SIZE = 1024KB,
    FILEGROWTH = 1024KB
)
TO FILEGROUP [FG_AccountHistory_2029Q1];

ALTER DATABASE [BaseInfoDB]
ADD FILE
(
    NAME = N'BaseInfoDB_AccountHistory_2029Q2',
    FILENAME = N'E:\DB-DATA\BaseInfoDB\BaseInfoDB_AccountHistory_2029Q2.ndf',
    SIZE = 1024KB,
    FILEGROWTH = 1024KB
)
TO FILEGROUP [FG_AccountHistory_2029Q2];

ALTER DATABASE [BaseInfoDB]
ADD FILE
(
    NAME = N'BaseInfoDB_AccountHistory_2029Q3',
    FILENAME = N'E:\DB-DATA\BaseInfoDB\BaseInfoDB_AccountHistory_2029Q3.ndf',
    SIZE = 1024KB,
    FILEGROWTH = 1024KB
)
TO FILEGROUP [FG_AccountHistory_2029Q3];

ALTER DATABASE [BaseInfoDB]
ADD FILE
(
    NAME = N'BaseInfoDB_AccountHistory_2029Q4',
    FILENAME = N'E:\DB-DATA\BaseInfoDB\BaseInfoDB_AccountHistory_2029Q4.ndf',
    SIZE = 1024KB,
    FILEGROWTH = 1024KB
)
TO FILEGROUP [FG_AccountHistory_2029Q4];

ALTER DATABASE [BaseInfoDB]
ADD FILE
(
    NAME = N'BaseInfoDB_AccountHistory_2030Q1',
    FILENAME = N'E:\DB-DATA\BaseInfoDB\BaseInfoDB_AccountHistory_2030Q1.ndf',
    SIZE = 1024KB,
    FILEGROWTH = 1024KB
)
TO FILEGROUP [FG_AccountHistory_2030Q1];

ALTER DATABASE [BaseInfoDB]
ADD FILE
(
    NAME = N'BaseInfoDB_AccountHistory_2030Q2',
    FILENAME = N'E:\DB-DATA\BaseInfoDB\BaseInfoDB_AccountHistory_2030Q2.ndf',
    SIZE = 1024KB,
    FILEGROWTH = 1024KB
)
TO FILEGROUP [FG_AccountHistory_2030Q2];

ALTER DATABASE [BaseInfoDB]
ADD FILE
(
    NAME = N'BaseInfoDB_AccountHistory_2030Q3',
    FILENAME = N'E:\DB-DATA\BaseInfoDB\BaseInfoDB_AccountHistory_2030Q3.ndf',
    SIZE = 1024KB,
    FILEGROWTH = 1024KB
)
TO FILEGROUP [FG_AccountHistory_2030Q3];

ALTER DATABASE [BaseInfoDB]
ADD FILE
(
    NAME = N'BaseInfoDB_AccountHistory_2030Q4',
    FILENAME = N'E:\DB-DATA\BaseInfoDB\BaseInfoDB_AccountHistory_2030Q4.ndf',
    SIZE = 1024KB,
    FILEGROWTH = 1024KB
)
TO FILEGROUP [FG_AccountHistory_2030Q4];

ALTER DATABASE [BaseInfoDB]
ADD FILE
(
    NAME = N'BaseInfoDB_AccountHistory_FUTURE',
    FILENAME = N'E:\DB-DATA\BaseInfoDB\BaseInfoDB_AccountHistory_FUTURE.ndf',
    SIZE = 1024KB,
    FILEGROWTH = 1024KB
)
TO FILEGROUP [FG_AccountHistory_FUTURE];
GO
*/
/*
USE [BaseInfoDB];
GO

CREATE PARTITION FUNCTION [pf_AccountHistory_SysEndTime] (datetime2(7))
AS RANGE RIGHT FOR VALUES
(
    '2026-04-01T00:00:00.0000000',
    '2026-05-01T00:00:00.0000000',
    '2026-06-01T00:00:00.0000000',
    '2026-07-01T00:00:00.0000000',
    '2026-08-01T00:00:00.0000000',
    '2026-09-01T00:00:00.0000000',
    '2026-10-01T00:00:00.0000000',
    '2026-11-01T00:00:00.0000000',
    '2026-12-01T00:00:00.0000000',

    '2027-01-01T00:00:00.0000000',
    '2027-02-01T00:00:00.0000000',
    '2027-03-01T00:00:00.0000000',
    '2027-04-01T00:00:00.0000000',
    '2027-05-01T00:00:00.0000000',
    '2027-06-01T00:00:00.0000000',
    '2027-07-01T00:00:00.0000000',
    '2027-08-01T00:00:00.0000000',
    '2027-09-01T00:00:00.0000000',
    '2027-10-01T00:00:00.0000000',
    '2027-11-01T00:00:00.0000000',
    '2027-12-01T00:00:00.0000000',

    '2028-01-01T00:00:00.0000000',
    '2028-02-01T00:00:00.0000000',
    '2028-03-01T00:00:00.0000000',
    '2028-04-01T00:00:00.0000000',
    '2028-05-01T00:00:00.0000000',
    '2028-06-01T00:00:00.0000000',
    '2028-07-01T00:00:00.0000000',
    '2028-08-01T00:00:00.0000000',
    '2028-09-01T00:00:00.0000000',
    '2028-10-01T00:00:00.0000000',
    '2028-11-01T00:00:00.0000000',
    '2028-12-01T00:00:00.0000000',

    '2029-01-01T00:00:00.0000000',
    '2029-02-01T00:00:00.0000000',
    '2029-03-01T00:00:00.0000000',
    '2029-04-01T00:00:00.0000000',
    '2029-05-01T00:00:00.0000000',
    '2029-06-01T00:00:00.0000000',
    '2029-07-01T00:00:00.0000000',
    '2029-08-01T00:00:00.0000000',
    '2029-09-01T00:00:00.0000000',
    '2029-10-01T00:00:00.0000000',
    '2029-11-01T00:00:00.0000000',
    '2029-12-01T00:00:00.0000000',

    '2030-01-01T00:00:00.0000000',
    '2030-02-01T00:00:00.0000000',
    '2030-03-01T00:00:00.0000000',
    '2030-04-01T00:00:00.0000000',
    '2030-05-01T00:00:00.0000000',
    '2030-06-01T00:00:00.0000000',
    '2030-07-01T00:00:00.0000000',
    '2030-08-01T00:00:00.0000000',
    '2030-09-01T00:00:00.0000000',
    '2030-10-01T00:00:00.0000000',
    '2030-11-01T00:00:00.0000000',
    '2030-12-01T00:00:00.0000000',

    '2031-01-01T00:00:00.0000000'
);
GO

*/
/*
USE [BaseInfoDB];
GO

CREATE PARTITION SCHEME [ps_AccountHistory_SysEndTime]
AS PARTITION [pf_AccountHistory_SysEndTime]
TO
(
    [FG_AccountHistory_PRE2026Q2],

    [FG_AccountHistory_2026Q2],
    [FG_AccountHistory_2026Q2],
    [FG_AccountHistory_2026Q2],

    [FG_AccountHistory_2026Q3],
    [FG_AccountHistory_2026Q3],
    [FG_AccountHistory_2026Q3],

    [FG_AccountHistory_2026Q4],
    [FG_AccountHistory_2026Q4],
    [FG_AccountHistory_2026Q4],

    [FG_AccountHistory_2027Q1],
    [FG_AccountHistory_2027Q1],
    [FG_AccountHistory_2027Q1],

    [FG_AccountHistory_2027Q2],
    [FG_AccountHistory_2027Q2],
    [FG_AccountHistory_2027Q2],

    [FG_AccountHistory_2027Q3],
    [FG_AccountHistory_2027Q3],
    [FG_AccountHistory_2027Q3],

    [FG_AccountHistory_2027Q4],
    [FG_AccountHistory_2027Q4],
    [FG_AccountHistory_2027Q4],

    [FG_AccountHistory_2028Q1],
    [FG_AccountHistory_2028Q1],
    [FG_AccountHistory_2028Q1],

    [FG_AccountHistory_2028Q2],
    [FG_AccountHistory_2028Q2],
    [FG_AccountHistory_2028Q2],

    [FG_AccountHistory_2028Q3],
    [FG_AccountHistory_2028Q3],
    [FG_AccountHistory_2028Q3],

    [FG_AccountHistory_2028Q4],
    [FG_AccountHistory_2028Q4],
    [FG_AccountHistory_2028Q4],

    [FG_AccountHistory_2029Q1],
    [FG_AccountHistory_2029Q1],
    [FG_AccountHistory_2029Q1],

    [FG_AccountHistory_2029Q2],
    [FG_AccountHistory_2029Q2],
    [FG_AccountHistory_2029Q2],

    [FG_AccountHistory_2029Q3],
    [FG_AccountHistory_2029Q3],
    [FG_AccountHistory_2029Q3],

    [FG_AccountHistory_2029Q4],
    [FG_AccountHistory_2029Q4],
    [FG_AccountHistory_2029Q4],

    [FG_AccountHistory_2030Q1],
    [FG_AccountHistory_2030Q1],
    [FG_AccountHistory_2030Q1],

    [FG_AccountHistory_2030Q2],
    [FG_AccountHistory_2030Q2],
    [FG_AccountHistory_2030Q2],

    [FG_AccountHistory_2030Q3],
    [FG_AccountHistory_2030Q3],
    [FG_AccountHistory_2030Q3],

    [FG_AccountHistory_2030Q4],
    [FG_AccountHistory_2030Q4],
    [FG_AccountHistory_2030Q4],

    [FG_AccountHistory_FUTURE]
);
GO
*/
/*
USE [BaseInfoDB];
GO

ALTER TABLE [dbo].[Account]
ADD
    [SysStartTime] datetime2(7) GENERATED ALWAYS AS ROW START HIDDEN NOT NULL
        CONSTRAINT [DF_Account_SysStartTime] DEFAULT SYSUTCDATETIME(),

    [SysEndTime] datetime2(7) GENERATED ALWAYS AS ROW END HIDDEN NOT NULL
        CONSTRAINT [DF_Account_SysEndTime] DEFAULT CONVERT(datetime2(7), '9999-12-31 23:59:59.9999999'),

    PERIOD FOR SYSTEM_TIME ([SysStartTime], [SysEndTime]);
GO
*/
/*
USE [BaseInfoDB];
GO

DECLARE @Columns nvarchar(max);
DECLARE @SQL nvarchar(max);

IF OBJECT_ID(N'dbo.AccountHistory', N'U') IS NOT NULL
BEGIN
    THROW 51000, 'dbo.AccountHistory already exists.', 1;
END;

SELECT @Columns =
    STRING_AGG(
        CAST(
            QUOTENAME(c.name) + N' ' +
            CASE
                WHEN t.name IN ('varchar', 'char', 'varbinary', 'binary')
                    THEN t.name + N'(' + CASE WHEN c.max_length = -1 THEN N'MAX' ELSE CONVERT(varchar(10), c.max_length) END + N')'

                WHEN t.name IN ('nvarchar', 'nchar')
                    THEN t.name + N'(' + CASE WHEN c.max_length = -1 THEN N'MAX' ELSE CONVERT(varchar(10), c.max_length / 2) END + N')'

                WHEN t.name IN ('decimal', 'numeric')
                    THEN t.name + N'(' + CONVERT(varchar(10), c.precision) + N',' + CONVERT(varchar(10), c.scale) + N')'

                WHEN t.name IN ('datetime2', 'time', 'datetimeoffset')
                    THEN t.name + N'(' + CONVERT(varchar(10), c.scale) + N')'

                ELSE t.name
            END +
            CASE
                WHEN c.collation_name IS NOT NULL
                    THEN N' COLLATE ' + c.collation_name
                ELSE N''
            END +
            CASE
                WHEN c.is_nullable = 1 THEN N' NULL' ELSE N' NOT NULL'
            END
        AS nvarchar(max)),
        N',' + CHAR(13) + CHAR(10)
    ) WITHIN GROUP (ORDER BY c.column_id)
FROM sys.columns c
INNER JOIN sys.types t
    ON c.user_type_id = t.user_type_id
WHERE c.object_id = OBJECT_ID(N'dbo.Account')
  AND c.is_computed = 0;

SET @SQL = N'
CREATE TABLE [dbo].[AccountHistory]
(
' + @Columns + N'
)
ON [ps_AccountHistory_SysEndTime]([SysEndTime]);
';

PRINT @SQL;
EXEC sys.sp_executesql @SQL;
GO
*/
/*
USE [BaseInfoDB];
GO

CREATE CLUSTERED INDEX [CIX_AccountHistory_SysEndTime_SysStartTime_AccountNo]
ON [dbo].[AccountHistory]
(
    [SysEndTime] ASC,
    [SysStartTime] ASC,
    [AccountNo] ASC
)
ON [ps_AccountHistory_SysEndTime]([SysEndTime]);
GO
*/
/*
CREATE NONCLUSTERED INDEX [IX_AccountHistory_AccountNo_Time]
ON [dbo].[AccountHistory]
(
    [AccountNo] ASC,
    [SysEndTime] ASC,
    [SysStartTime] ASC
)
ON [ps_AccountHistory_SysEndTime]([SysEndTime]);
GO
--SELECT *
--FROM dbo.Account FOR SYSTEM_TIME AS OF @AsOfTime
--WHERE AccountNo = @AccountNo;
*/
/*
USE [BaseInfoDB];
GO

ALTER TABLE [dbo].[Account]
SET
(
    SYSTEM_VERSIONING = ON
    (
        HISTORY_TABLE = [dbo].[AccountHistory],
        DATA_CONSISTENCY_CHECK = ON
    )
);
GO
*/
/*
SELECT
    t.name AS TableName,
    t.temporal_type_desc,
    h.name AS HistoryTableName
FROM sys.tables t
LEFT JOIN sys.tables h
    ON t.history_table_id = h.object_id
WHERE t.name = N'Account';
GO
*/
/*
SELECT
    i.name AS IndexName,
    ps.name AS PartitionSchemeName,
    pf.name AS PartitionFunctionName,
    c.name AS PartitionColumn
FROM sys.indexes i
INNER JOIN sys.data_spaces ds
    ON i.data_space_id = ds.data_space_id
INNER JOIN sys.partition_schemes ps
    ON ds.data_space_id = ps.data_space_id
INNER JOIN sys.partition_functions pf
    ON ps.function_id = pf.function_id
INNER JOIN sys.index_columns ic
    ON i.object_id = ic.object_id
   AND i.index_id = ic.index_id
INNER JOIN sys.columns c
    ON ic.object_id = c.object_id
   AND ic.column_id = c.column_id
WHERE i.object_id = OBJECT_ID(N'dbo.AccountHistory');
GO
*/