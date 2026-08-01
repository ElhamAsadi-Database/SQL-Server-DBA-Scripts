--blocking_session_id=0  Blocking وجود ندارد.
--blocking_session_id=0>0  این Query توسط Session دیگر Block شده است.

----wait_type
--LCK_M_S        (Lock wait)
--PAGEIOLATCH_SH (Disk IO)
--CXPACKET       (Parallelism)
--WRITELOG       (Transaction Log)

--elapsed_seconds

--مدت زمان اجرای Query.

--برای تشخیص Long Running Query مهم است.

--logical_reads

--میزان IO منطقی Query.

--اگر خیلی بالا باشد Query احتمالاً:

--Index مناسب ندارد
--Scan انجام می‌دهد.


--granted_memory_MB

--Memory که SQL Server برای Query تخصیص داده است.

--percent_complete
--برای عملیات‌های طولانی مثل:
--BACKUP
--RESTORE
--INDEX REBUILD
--DBCC


SELECT
    s.session_id,

    s.login_name,
    s.host_name,
    s.program_name,

    DB_NAME(r.database_id) AS database_name,

    r.status,

    r.command,

    r.blocking_session_id,

    r.wait_type,
    r.wait_time AS wait_time_ms,

    r.cpu_time AS cpu_time_ms,

    r.total_elapsed_time / 1000 AS elapsed_seconds,

    r.logical_reads,
    r.reads,
    r.writes,

    s.memory_usage * 8 / 1024 AS session_memory_MB,

    mg.requested_memory_kb / 1024 AS requested_memory_MB,
    mg.granted_memory_kb / 1024 AS granted_memory_MB,
    mg.max_used_memory_kb / 1024 AS used_memory_MB,

    r.percent_complete,

    r.start_time,

    SUBSTRING(
        st.text,
        (r.statement_start_offset / 2) + 1,
        ((CASE r.statement_end_offset
            WHEN -1 THEN DATALENGTH(st.text)
            ELSE r.statement_end_offset
        END - r.statement_start_offset) / 2) + 1
    ) AS running_statement,

    st.text AS full_query_text

FROM sys.dm_exec_sessions s

LEFT JOIN sys.dm_exec_requests r
    ON s.session_id = r.session_id

LEFT JOIN sys.dm_exec_query_memory_grants mg
    ON r.session_id = mg.session_id

OUTER APPLY sys.dm_exec_sql_text(r.sql_handle) st

WHERE
    s.is_user_process = 1

ORDER BY
    r.cpu_time DESC,
    r.total_elapsed_time DESC;
