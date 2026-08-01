---Script 08 –  Tempdb Config



-- TempDB Files
SELECT 
    name,
    type_desc,
    physical_name,
    size*8/1024 AS SizeMB
FROM tempdb.sys.database_files;

--1=<logical core<=8 ==tempDB file count=  به تعداد  core 

--logical core>=8---tempDB file count-- اول 8  تا بعد در هر مزحله 4 تا 4 تا اضافه کن 


SELECT 
    cpu_count,--Logical CPU
    scheduler_count,
    hyperthread_ratio,
    numa_node_count,
    socket_count,
    cores_per_socket
FROM sys.dm_os_sys_info;



--Logical CPU/2= core number--اگر  HT  فعال

---core number/numa_node_count= numa per node


--numa per node>=maxdop  



SELECT 
    wait_type,
    wait_time_ms,
    waiting_tasks_count,
    wait_time_ms / NULLIF(waiting_tasks_count,0) AS AvgWait_ms
FROM sys.dm_os_wait_stats
WHERE wait_type LIKE 'PAGELATCH_%'
ORDER BY wait_time_ms DESC;

 --این سه تا وجود داشت کمبود فایل  
--PAGELATCH_UP
--PAGELATCH_SH
--PAGELATCH_EX

--,  AvgWait_ms > 5ms-- مشکل  temp 


--اگر AvgWait_ms > 5ms → مشکل TempDB قطعی است
--اگر waiting_tasks_count خیلی زیاد باشد → ۹۹٪ مشکل تعداد فایل‌هاست
--اگر فقط PAGELATCH_EX بالا باشد → contention شدید

--PAGELATCH_EX	قطعا مشکل  tempdb

--AvgWait > 1ms → معمولی نیست
--AvgWait > 5ms → کمبود فایل قطعی
--PAGELATCH_UP بالا → شروع مشکل
---Severe TempDB Latch Contention


SELECT 
    file_id,
    name,
    type_desc,
    physical_name,
    size*8/1024 AS SizeMB,
    growth*8/1024 AS GrowthMB
FROM tempdb.sys.database_files;



ALTER DATABASE tempdb 
ADD FILE (NAME = tempdev9, FILENAME = 'D:\MSSQL\Data\tempdb9.ndf', SIZE = 1024MB, FILEGROWTH = 512MB);
ALTER DATABASE tempdb 
ADD FILE (NAME = tempdev10, FILENAME = 'D:\MSSQL\Data\tempdb10.ndf', SIZE = 1024MB, FILEGROWTH = 512MB);
ALTER DATABASE tempdb 
ADD FILE (NAME = tempdev11, FILENAME = 'D:\MSSQL\Data\tempdb11.ndf', SIZE = 1024MB, FILEGROWTH = 512MB);
ALTER DATABASE tempdb 
ADD FILE (NAME = tempdev12, FILENAME = 'D:\MSSQL\Data\tempdb12.ndf', SIZE = 1024MB, FILEGROWTH = 512MB);

--همه سایزها و رشدها یکی باشد 
--Size = 1GB--سایز اولیه به اندازه سایز پیک 
--Growth = 512MB یا 1GB

USE master;
GO

ALTER DATABASE tempdb 
MODIFY FILE (
    NAME = tempdev,     -- نام فایل فعلی (بدون تغییر)
    SIZE = 2048MB,
    FILEGROWTH = 512MB
);
GO

ALTER DATABASE tempdb 
MODIFY FILE (
    NAME = templog,     -- نام فایل فعلی (همان باقی می‌ماند)
    SIZE = 1024MB,
    FILEGROWTH = 256MB
);
GO
