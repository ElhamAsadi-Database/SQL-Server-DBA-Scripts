SELECT
    /* Session / Blocking */
    r.session_id,
    r.blocking_session_id,
    CASE 
        WHEN r.blocking_session_id = 0 THEN 'ROOT (Blocking Others)'
        ELSE 'VICTIM (Blocked)'
    END AS BlockingRole,

    /* Timing */
    r.start_time AS QueryStartTime,
    r.total_elapsed_time / 1000 AS RuntimeSeconds,
    r.percent_complete AS PercentComplete,

    /* Waits */
    r.wait_type AS WaitType,
    r.wait_time AS WaitTime_ms,
    CASE 
        WHEN r.wait_type LIKE 'LCK%' THEN 'Lock Wait'
        WHEN r.wait_type LIKE 'PAGEIOLATCH%' THEN 'I/O Wait'
        WHEN r.wait_type LIKE 'CXPACKET%' OR r.wait_type LIKE 'CXCONSUMER%' THEN 'Parallelism'
        WHEN r.wait_type LIKE 'ASYNC_NETWORK_IO' THEN 'Network Wait'
        WHEN r.wait_type LIKE 'WRITELOG' THEN 'Transaction Log Wait'
        WHEN r.wait_type LIKE 'RESOURCE_SEMAPHORE%' THEN 'Memory Grant Wait'
        ELSE 'Other'
    END AS WaitCategory,

    /* Resource Usage */
    r.cpu_time AS CPU_ms,
    r.reads AS Reads,
    r.writes AS Writes,
    r.logical_reads AS LogicalReads,
    r.granted_query_memory AS GrantedMemory,

    /* Session Info */
    s.status AS SessionStatus,
    s.open_transaction_count AS OpenTransactions,

    CASE s.transaction_isolation_level
        WHEN 0 THEN 'Unspecified'
        WHEN 1 THEN 'ReadUncommitted'
        WHEN 2 THEN 'ReadCommitted'
        WHEN 3 THEN 'RepeatableRead'
        WHEN 4 THEN 'Serializable'
        WHEN 5 THEN 'Snapshot'
    END AS IsolationLevel,

    /* Request Info */
    r.command AS CommandType,
    DB_NAME(r.database_id) AS DatabaseName,

    /* Program Info */
    s.program_name AS ProgramName,
    s.login_name AS LoginName,
    s.host_name AS HostName,
    c.client_net_address AS IPAddress,

    /* SQL Text */
    t.text AS FullQueryText,

    /* Blocking SQL Text */
    bt.text AS BlockingQueryText,
    bs.program_name AS BlockingProgramName,
    bs.host_name AS BlockingHostName,
    bs.login_name AS BlockingLoginName,

    /* Execution Plan Handle */
    r.plan_handle AS PlanHandle,

    /*  Graphical Execution Plan (XML) */
    qp.query_plan AS QueryPlanXML

FROM sys.dm_exec_requests r
INNER JOIN sys.dm_exec_sessions s
        ON r.session_id = s.session_id
LEFT JOIN sys.dm_exec_connections c
        ON r.connection_id = c.connection_id
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) t
OUTER APPLY sys.dm_exec_query_plan(r.plan_handle) qp  

LEFT JOIN sys.dm_exec_requests br
        ON r.blocking_session_id = br.session_id
LEFT JOIN sys.dm_exec_sessions bs
        ON br.session_id = bs.session_id
OUTER APPLY sys.dm_exec_sql_text(br.sql_handle) bt

WHERE r.total_elapsed_time / 1000 >= 5
  AND r.session_id <> @@SPID

ORDER BY
    r.blocking_session_id DESC,
    RuntimeSeconds DESC;

	--kill 54
