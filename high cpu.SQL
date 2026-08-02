SELECT s.session_id,
	r.status,
	r.blocking_session_id 'Blk by',
	r.wait_type,
	wait_resource,
	r.wait_time / (1000 * 60) 'Wait M',
	r.cpu_time,
	r.logical_reads,
	r.reads,
	r.writes,
	r.total_elapsed_time / (1000 * 60) 'Elaps M',
	Substring(st.TEXT,(r.statement_start_offset / 2) + 1,
	((CASE r.statement_end_offset
	WHEN -1
	THEN Datalength(st.TEXT)
	ELSE r.statement_end_offset
	END - r.statement_start_offset) / 2) + 1) AS statement_text,
	Coalesce(Quotename(Db_name(st.dbid)) + N'.' + Quotename(Object_schema_name(st.objectid, st.dbid)) + N'.' +
	Quotename(Object_name(st.objectid, st.dbid)), '') AS command_text,
	r.command,
	s.login_name,
	s.host_name,
	s.program_name,
	s.last_request_end_time,
	s.login_time,
	r.open_transaction_count
FROM sys.dm_exec_sessions AS s
JOIN sys.dm_exec_requests AS r
	ON r.session_id = s.session_id
CROSS APPLY sys.Dm_exec_sql_text(r.sql_handle) AS st
WHERE r.session_id != @@SPID
ORDER BY r.cpu_time desc
------------------------------------------------------------------------------------------
/*
SQL Server: SQL Statistics: Batch Requests/sec
SQL Server: SQL Statistics: SQL Compilations/sec
SQL Server: SQL Statistics: SQL Recompilations/sec
Batch Requests/sec: Number of SQL batch requests received by server.
SQL Compilations/sec: Number of SQL compilations per second.
SQL Recompilations/sec: Number of SQL re-compiles per second.
*/