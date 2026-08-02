/*
بلوک ۱: مشخصات اصلی سرور و نسخه (Server & Version)
*/
SELECT 'SERVER' AS Section, 'ServerName' AS Property, CAST(@@SERVERNAME AS NVARCHAR(MAX)) AS Value
UNION ALL SELECT 'SERVER', 'MachineName', CAST(SERVERPROPERTY('MachineName') AS NVARCHAR(MAX))
UNION ALL SELECT 'SERVER', 'InstanceName', ISNULL(CAST(SERVERPROPERTY('InstanceName') AS NVARCHAR(MAX)), 'MSSQLSERVER')
UNION ALL SELECT 'SERVER', 'Edition', CAST(SERVERPROPERTY('Edition') AS NVARCHAR(MAX))
UNION ALL SELECT 'SERVER', 'ProductVersion', CAST(SERVERPROPERTY('ProductVersion') AS NVARCHAR(MAX))
UNION ALL SELECT 'SERVER', 'ProductLevel', CAST(SERVERPROPERTY('ProductLevel') AS NVARCHAR(MAX))
UNION ALL SELECT 'SERVER', 'Collation', CAST(SERVERPROPERTY('Collation') AS NVARCHAR(MAX))
UNION ALL SELECT 'SERVER', 'IsClustered', CAST(ISNULL(CAST(SERVERPROPERTY('IsClustered') AS INT), 0) AS NVARCHAR(MAX)))
UNION ALL SELECT 'SERVER', 'IsHadrEnabled', CAST(ISNULL(CAST(SERVERPROPERTY('IsHadrEnabled') AS INT), 0) AS NVARCHAR(MAX)))
UNION ALL SELECT 'SERVER', 'SQL_Start_Time', CAST(sqlserver_start_time AS NVARCHAR(MAX)) FROM sys.dm_os_sys_info;
----------------------------
/*
 ۲: تحلیل عمیق CPU و معماری (CPU & Architecture)
*/
SELECT 'CPU' AS Section, 'Logical_CPU_Count' AS Property, CAST(cpu_count AS NVARCHAR(MAX)) AS Value FROM sys.dm_os_sys_info
UNION ALL SELECT 'CPU', 'Physical_Core_Count', CAST(CASE WHEN hyperthread_ratio > 0 THEN cpu_count / hyperthread_ratio ELSE cpu_count END AS NVARCHAR(MAX)) FROM sys.dm_os_sys_info
UNION ALL SELECT 'CPU', 'Hyperthread_Ratio', CAST(hyperthread_ratio AS NVARCHAR(MAX)) FROM sys.dm_os_sys_info
UNION ALL SELECT 'CPU', 'Hyperthreading_Enabled', CAST(CASE WHEN hyperthread_ratio > 1 THEN 'YES' ELSE 'NO' END AS NVARCHAR(MAX)) FROM sys.dm_os_sys_info
UNION ALL SELECT 'CPU', 'NUMA_Node_Count', CAST(numa_node_count AS NVARCHAR(MAX)) FROM sys.dm_os_sys_info
UNION ALL SELECT 'CPU', 'Virtual_Machine_Type', CAST(virtual_machine_type_desc AS NVARCHAR(MAX)) FROM sys.dm_os_sys_info
-- بخش سوکت‌ها (فقط اگر نسخه جدید باشد)
UNION ALL SELECT 'CPU', 'Socket_Count', CAST(ISNULL(socket_count, 0) AS NVARCHAR(MAX)) FROM sys.dm_os_sys_info
UNION ALL SELECT 'CPU', 'Cores_Per_Socket', CAST(ISNULL(cores_per_socket, 0) AS NVARCHAR(MAX)) FROM sys.dm_os_sys_info;

----------------------------
/*
۳: تحلیل جامع حافظه (Memory Analysis)
*/
SELECT 'MEMORY' AS Section, 'Physical_RAM_GB' AS Property, CAST(CAST(physical_memory_kb/1024.0/1024.0 AS DECIMAL(18,2)) AS NVARCHAR(MAX)) AS Value FROM sys.dm_os_sys_info
UNION ALL SELECT 'MEMORY', 'SQL_Committed_GB', CAST(CAST(committed_kb/1024.0/1024.0 AS DECIMAL(18,2)) AS NVARCHAR(MAX)) FROM sys.dm_os_sys_info
UNION ALL SELECT 'MEMORY', 'SQL_Target_Memory_GB', CAST(CAST(committed_target_kb/1024.0/1024.0 AS DECIMAL(18,2)) AS NVARCHAR(MAX)) FROM sys.dm_os_sys_info
UNION ALL SELECT 'MEMORY', 'OS_Available_RAM_GB', CAST(CAST(available_physical_memory_kb/1024.0/1024.0 AS DECIMAL(18,2)) AS NVARCHAR(MAX)) FROM sys.dm_os_sys_memory
UNION ALL SELECT 'MEMORY', 'System_Memory_State', CAST(system_memory_state_desc AS NVARCHAR(MAX)) FROM sys.dm_os_sys_memory
UNION ALL SELECT 'MEMORY', 'Max_SQL_Memory_Config_GB', CAST(CAST(CONVERT(BIGINT, (SELECT value_in_use FROM sys.configurations WHERE name='max server memory (MB)'))/1024.0 AS DECIMAL(18,2)) AS NVARCHAR(MAX));
----------------------------
/*
بلوک ۴: تنظیمات حیاتی (Critical Configurations)
*/
SELECT 'CONFIG' AS Section, 'MaxDOP' AS Property, CAST(value_in_use AS NVARCHAR(MAX)) AS Value FROM sys.configurations WHERE name='max degree of parallelism'
UNION ALL SELECT 'CONFIG', 'CostThresholdForParallelism', CAST(value_in_use AS NVARCHAR(MAX)) FROM sys.configurations WHERE name='cost threshold for parallelism'
UNION ALL SELECT 'CONFIG', 'MaxServerMemory_MB', CAST(value_in_use AS NVARCHAR(MAX)) FROM sys.configurations WHERE name='max server memory (MB)'
UNION ALL SELECT 'CONFIG', 'MinServerMemory_MB', CAST(value_in_use AS NVARCHAR(MAX)) FROM sys.configurations WHERE name='min server memory (MB)'
UNION ALL SELECT 'CONFIG', 'OptimizeForAdHoc', CAST(value_in_use AS NVARCHAR(MAX)) FROM sys.configurations WHERE name='optimize for ad hoc workloads'
UNION ALL SELECT 'CONFIG', 'BackupCompression', CAST(value_in_use AS NVARCHAR(MAX)) FROM sys.configurations WHERE name='backup compression default';
----------------------------
/*
۵: ذخیره‌سازی و دیتابیس (Storage & DB Summary)
*/
SELECT 'DATABASES' AS Section, 'DatabaseCount' AS Property, CAST(COUNT(*) AS NVARCHAR(MAX)) AS Value FROM sys.databases WHERE database_id > 4
UNION ALL SELECT 'DATABASES', 'Total_DB_Size_GB', CAST(CAST(SUM(size)*8.0/1024/1024 AS DECIMAL(18,2)) AS NVARCHAR(MAX)) FROM sys.master_files WHERE database_id > 4;
----------------------
/*
بلوک ۶: وضعیت درایوها و دیسک (Disk & Storage)
*/
SELECT DISTINCT
    'STORAGE' AS Section,
    CAST(vs.volume_mount_point AS NVARCHAR(50)) + ' Total_GB' AS Property,
    CAST(CAST(vs.total_bytes / 1024.0 / 1024.0 / 1024.0 AS DECIMAL(18,2)) AS NVARCHAR(MAX)) AS Value
FROM sys.master_files AS f
CROSS APPLY sys.dm_os_volume_stats(f.database_id, f.file_id) AS vs
UNION ALL
SELECT DISTINCT
    'STORAGE',
    CAST(vs.volume_mount_point AS NVARCHAR(50)) + ' Free_GB',
    CAST(CAST(vs.available_bytes / 1024.0 / 1024.0 / 1024.0 AS DECIMAL(18,2)) AS NVARCHAR(MAX))
FROM sys.master_files AS f
CROSS APPLY sys.dm_os_volume_stats(f.database_id, f.file_id) AS vs;
----------------------
/*
بلوک ۷: تحلیل TempDB 
*/
SELECT 'TEMPDB' AS Section, 'FileCount' AS Property, CAST(COUNT(*) AS NVARCHAR(MAX)) AS Value FROM sys.master_files WHERE database_id = 2 AND type = 0
UNION ALL
SELECT 'TEMPDB', 'TotalSize_MB', CAST(SUM(size)*8.0/1024 AS NVARCHAR(MAX)) FROM sys.master_files WHERE database_id = 2
UNION ALL
SELECT 'TEMPDB', 'Is_Autogrowth_Percent', CAST(MAX(CAST(is_percent_growth AS INT)) AS NVARCHAR(MAX)) FROM sys.master_files WHERE database_id = 2;
----------------------
/*
 ۸: امنیت و لاگین‌ها (Security & Sysadmins)
*/
SELECT 'SECURITY' AS Section, 'TotalLogins' AS Property, CAST(COUNT(*) AS NVARCHAR(MAX)) AS Value FROM sys.server_principals WHERE type IN ('S','U','G')
UNION ALL
SELECT 'SECURITY', 'SysadminCount', CAST(COUNT(*) AS NVARCHAR(MAX)) FROM sys.server_principals p JOIN sys.server_role_members rm ON p.principal_id = rm.member_principal_id WHERE rm.role_principal_id = (SELECT principal_id FROM sys.server_principals WHERE name = 'sysadmin')
UNION ALL
SELECT 'SECURITY', 'ServerRoleCount', CAST(COUNT(*) AS NVARCHAR(MAX)) FROM sys.server_principals WHERE type = 'R';
----------------------
/*
 ۹: وضعیت بک‌آپ‌ها (Backup Status)
*/
SELECT 'BACKUP' AS Section, 'DB_Without_Full_Backup' AS Property, CAST(COUNT(*) AS NVARCHAR(MAX)) AS Value FROM sys.databases d WHERE d.database_id > 4 AND d.name NOT IN (SELECT database_name FROM msdb.dbo.backupset WHERE type = 'D')
UNION ALL
SELECT 'BACKUP', 'Total_Backups_Last_24H', CAST(COUNT(*) AS NVARCHAR(MAX)) FROM msdb.dbo.backupset WHERE backup_finish_date > DATEADD(hh, -24, GETDATE());
----------------------
/*
 ۱۰: لینک سرورها و اینستنس (Infrastructure)
*/
SELECT 'INFRA' AS Section, 'LinkedServerCount' AS Property, CAST(COUNT(*) AS NVARCHAR(MAX)) AS Value FROM sys.servers WHERE server_id > 0
UNION ALL
SELECT 'INFRA', 'IsLocalOnly', CAST(CASE WHEN EXISTS (SELECT 1 FROM sys.servers WHERE server_id > 0) THEN 'NO' ELSE 'YES' END AS NVARCHAR(MAX))
UNION ALL
SELECT 'INFRA', 'Instance_Type', CAST(CASE WHEN SERVERPROPERTY('IsClustered') = 1 THEN 'Clustered Instance' ELSE 'Standalone Instance' END AS NVARCHAR(MAX));

----------------------
/*

*/

----------------------
/*

*/
