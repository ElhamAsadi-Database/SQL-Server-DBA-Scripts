select *  
from sys.dm_os_wait_stats 
order by wait_time_ms desc;

--*****************************************************

-- Get all SQL Statements with missing indexes and their cached query plans 
;WITH  
 XMLNAMESPACES 
     (DEFAULT N'http://schemas.microsoft.com/sqlserver/2004/07/showplan'   
             ,N'http://schemas.microsoft.com/sqlserver/2004/07/showplan' AS ShowPlan)       
SELECT ECP.[usecounts]    AS [UsageCounts] 
      ,ECP.[refcounts]    AS [RefencedCounts] 
      ,ECP.[objtype]      AS [ObjectType] 
      ,ECP.[cacheobjtype] AS [CacheObjectType] 
      ,EST.[dbid]         AS [DatabaseID] 
      ,EST.[objectid]     AS [ObjectID] 
      ,EST.[text]         AS [Statement]       
      ,EQP.[query_plan]   AS [QueryPlan] 
FROM sys.dm_exec_cached_plans AS ECP 
     CROSS APPLY sys.dm_exec_sql_text(ECP.[plan_handle]) AS EST 
     CROSS APPLY sys.dm_exec_query_plan(ECP.[plan_handle]) AS EQP 
WHERE ECP.[usecounts] > 1  -- Plan should be used more then one time (= no AdHoc queries) 
      AND EQP.[query_plan].exist(N'/ShowPlanXML/BatchSequence/Batch/Statements/StmtSimple/QueryPlan/MissingIndexes/MissingIndexGroup') <> 0 
ORDER BY ECP.[usecounts] DESC

-- ***********************************************************

SELECT TOP 25
	databases.name,
	dm_exec_sql_text.text AS TSQL_Text,
	CAST(CAST(dm_exec_query_stats.total_worker_time AS DECIMAL)/CAST(dm_exec_query_stats.execution_count AS DECIMAL) AS INT) as cpu_per_execution,
	CAST(CAST(dm_exec_query_stats.total_logical_reads AS DECIMAL)/CAST(dm_exec_query_stats.execution_count AS DECIMAL) AS INT) as logical_reads_per_execution,
	CAST(CAST(dm_exec_query_stats.total_elapsed_time AS DECIMAL)/CAST(dm_exec_query_stats.execution_count AS DECIMAL) AS INT) as elapsed_time_per_execution,
	dm_exec_query_stats.creation_time, 
	dm_exec_query_stats.execution_count,
	dm_exec_query_stats.total_worker_time AS total_cpu_time,
	dm_exec_query_stats.max_worker_time AS max_cpu_time, 
	dm_exec_query_stats.total_elapsed_time, 
	dm_exec_query_stats.max_elapsed_time, 
	dm_exec_query_stats.total_logical_reads, 
	dm_exec_query_stats.max_logical_reads,
	dm_exec_query_stats.total_physical_reads, 
	dm_exec_query_stats.max_physical_reads,
	dm_exec_query_plan.query_plan,
	dm_exec_cached_plans.cacheobjtype,
	dm_exec_cached_plans.objtype,
	dm_exec_cached_plans.size_in_bytes
FROM sys.dm_exec_query_stats 
CROSS APPLY sys.dm_exec_sql_text(dm_exec_query_stats.plan_handle)
CROSS APPLY sys.dm_exec_query_plan(dm_exec_query_stats.plan_handle)
INNER JOIN sys.databases
ON dm_exec_sql_text.dbid = databases.database_id
INNER JOIN sys.dm_exec_cached_plans 
ON dm_exec_cached_plans.plan_handle = dm_exec_query_stats.plan_handle
WHERE databases.name = 'AdventureWorks2014'
ORDER BY dm_exec_query_stats.max_logical_reads DESC;

-- ******************************************************************

DECLARE @database_name NVARCHAR(128) = 'AdventureWorks2014';
;WITH XMLNAMESPACES
    (DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan')   
SELECT
	dm_exec_sql_text.text AS sql_text,
	CAST(CAST(dm_exec_query_stats.execution_count AS DECIMAL) / CAST((CASE WHEN DATEDIFF(HOUR, dm_exec_query_stats.creation_time, CURRENT_TIMESTAMP) = 0 THEN 1 ELSE DATEDIFF(HOUR, dm_exec_query_stats.creation_time, CURRENT_TIMESTAMP) END) AS DECIMAL) AS INT) AS executions_per_hour,
	dm_exec_query_stats.creation_time, 
	dm_exec_query_stats.execution_count,
	CAST(CAST(dm_exec_query_stats.total_worker_time AS DECIMAL)/CAST(dm_exec_query_stats.execution_count AS DECIMAL) AS INT) as cpu_per_execution,
	CAST(CAST(dm_exec_query_stats.total_logical_reads AS DECIMAL)/CAST(dm_exec_query_stats.execution_count AS DECIMAL) AS INT) as logical_reads_per_execution,
	CAST(CAST(dm_exec_query_stats.total_elapsed_time AS DECIMAL)/CAST(dm_exec_query_stats.execution_count AS DECIMAL) AS INT) as elapsed_time_per_execution,
	dm_exec_query_stats.total_worker_time AS total_cpu_time,
	dm_exec_query_stats.max_worker_time AS max_cpu_time, 
	dm_exec_query_stats.total_elapsed_time, 
	dm_exec_query_stats.max_elapsed_time, 
	dm_exec_query_stats.total_logical_reads, 
	dm_exec_query_stats.max_logical_reads,
	dm_exec_query_stats.total_physical_reads, 
	dm_exec_query_stats.max_physical_reads,
	dm_exec_query_plan.query_plan
FROM sys.dm_exec_query_stats
CROSS APPLY sys.dm_exec_sql_text(dm_exec_query_stats.sql_handle)
CROSS APPLY sys.dm_exec_query_plan(dm_exec_query_stats.plan_handle)
WHERE query_plan.exist('//PlanAffectingConvert') = 1
AND query_plan.exist('//ColumnReference[@Database = "[AdventureWorks2014]"]') = 1
ORDER BY dm_exec_query_stats.total_worker_time DESC;