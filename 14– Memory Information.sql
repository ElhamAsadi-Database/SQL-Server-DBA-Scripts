---Script 05 – Memory Information 



/* ==========================================================
   SECTION 1: INSTANCE MEMORY CONFIGURATION
   ========================================================== */

   -- Memory & CPU
SELECT 
    cpu_count,-- logical_cpu count--Hyper-threading? HT=active*2
    scheduler_count,--logical_cpu count
    physical_memory_kb/1024 AS PhysicalMemoryMB,---total server RAM
    virtual_memory_kb/1024 AS VirtualMemoryMB
FROM sys.dm_os_sys_info;
--Total RAM =64GB
 ---OS=8 GB 
 --Max Server Memory = Total RAM – OS Reserved
 --Max Server Memory = 56000 MB
 --Min Server Memory=10000 MB


-- EXEC sp_configure 'show advanced options', 1;
--RECONFIGURE;

--EXEC sp_configure 'min server memory (MB)', 10000;   -- 10GB
--EXEC sp_configure 'max server memory (MB)', 56000;   -- 56GB
--RECONFIGURE;

--main server--min =16000
SELECT 
    SERVERPROPERTY('MachineName') AS MachineName,
    SERVERPROPERTY('ServerName') AS ServerName,
    SERVERPROPERTY('Edition') AS Edition,
    SERVERPROPERTY('ProductVersion') AS ProductVersion,
    (SELECT value_in_use FROM sys.configurations WHERE name = 'max server memory (MB)') AS MaxServerMemoryMB,
    (SELECT value_in_use FROM sys.configurations WHERE name = 'min server memory (MB)') AS MinServerMemoryMB,
    physical_memory_kb / 1024 AS PhysicalMemoryMB,
    virtual_memory_kb / 1024 AS VirtualMemoryMB,
    cpu_count,
    scheduler_count
FROM sys.dm_os_sys_info;


/* ==========================================================
   SECTION 2: LIVE MEMORY USAGE
   ========================================================== */

SELECT 
    (cntr_value / 1024) AS BufferPoolMB
FROM sys.dm_os_performance_counters
WHERE counter_name = 'Database Cache Memory (KB)';

SELECT 
    (cntr_value / 1024) AS StolenMemoryMB
FROM sys.dm_os_performance_counters
WHERE counter_name = 'Stolen Server Memory (KB)';

SELECT 
    (cntr_value / 1024) AS TotalServerMemoryMB
FROM sys.dm_os_performance_counters
WHERE counter_name = 'Total Server Memory (KB)';

SELECT 
    (cntr_value / 1024) AS TargetServerMemoryMB
FROM sys.dm_os_performance_counters
WHERE counter_name = 'Target Server Memory (KB)';


/* ==========================================================
   SECTION 3: MEMORY GRANTS & PRESSURE DIAGNOSTICS
   ========================================================== */

SELECT 
    * 
FROM sys.dm_exec_query_memory_grants
ORDER BY requested_memory_kb DESC;

SELECT 
    memory_grants_pending,
    memory_grants_outstanding
FROM sys.dm_os_memory_clerks mc
JOIN sys.dm_os_wait_stats ws
    ON 1 = 1
OPTION (MAXDOP 1);


/* ==========================================================
   SECTION 4: CPU UTILIZATION (REAL-TIME)
   ========================================================== */

SELECT 
    record.value('(./SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]', 'int') AS SystemIdle,
    record.value('(./SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]', 'int') AS SQLProcessCPU,
    timestamp
FROM (
      SELECT 
          timestamp, 
          CONVERT(XML, record) AS record
      FROM sys.dm_os_ring_buffers
      WHERE ring_buffer_type = 'RING_BUFFER_SCHEDULER_MONITOR'
            AND record LIKE '%<SystemHealth>%'
) AS x;


/* ==========================================================
   SECTION 5: SCHEDULER STATUS (SOS SCHEDULERS)
   ========================================================== */

SELECT 
    scheduler_id,
    status,
    is_online,
    is_idle,
    current_tasks_count,
    runnable_tasks_count,
    work_queue_count
FROM sys.dm_os_schedulers
WHERE scheduler_id < 255   -- Skip DAC + Hidden schedulers
ORDER BY scheduler_id;


/* ==========================================================
   SECTION 6: NUMA NODE DIAGNOSTICS
   ========================================================== */

SELECT 
    node_id,
    memory_node_id,
    online_scheduler_count,
    cpu_affinity_mask
FROM sys.dm_os_nodes
WHERE node_state_desc = 'ONLINE';