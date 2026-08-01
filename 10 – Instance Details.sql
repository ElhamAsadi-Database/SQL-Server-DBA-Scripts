---Script 01 – Instance Details

/* ================================
   Script 01 - Instance Details
   ================================ */

-- Version & Edition
SELECT 
    @@SERVERNAME AS ServerName,
    @@VERSION AS SQLVersion,
    SERVERPROPERTY('ProductVersion') AS ProductVersion,
    SERVERPROPERTY('ProductLevel') AS ProductLevel,
    SERVERPROPERTY('Edition') AS Edition;

-- Memory & CPU
SELECT 
    cpu_count,-- logical_cpu count--Hyper-threading? HT=active*2
    scheduler_count,--logical_cpu count
    physical_memory_kb/1024 AS PhysicalMemoryMB,---total server RAM
    virtual_memory_kb/1024 AS VirtualMemoryMB
FROM sys.dm_os_sys_info;

-- SQL Server Restart Time
SELECT sqlserver_start_time
FROM sys.dm_os_sys_info;

-- Instance Configuration
SELECT 
    name,
    value,
    value_in_use,
    description
FROM sys.configurations
ORDER BY name;

-- TempDB Files
SELECT 
    name,
    type_desc,
    physical_name,
    size*8/1024 AS SizeMB
FROM tempdb.sys.database_files;

-- Collation
SELECT SERVERPROPERTY('Collation') AS ServerCollation;