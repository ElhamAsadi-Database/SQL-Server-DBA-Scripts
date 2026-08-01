/* ==================================
   Script 02 - Database Inventory
   ================================== */


SELECT 
    d.name AS DatabaseName,
    d.database_id,
    d.recovery_model_desc AS RecoveryModel,
    d.compatibility_level AS CompatibilityLevel,
    d.state_desc AS Status,
    d.owner_sid,
    mf.type_desc AS FileType,
    mf.physical_name AS FilePath,
    (mf.size * 8 / 1024) AS FileSizeMB
FROM sys.databases d
JOIN sys.master_files mf 
    ON d.database_id = mf.database_id
ORDER BY d.database_id, mf.file_id;

/* ==================================
   Database Size Summary 
   ================================== */

   


SELECT 
    d.name AS DatabaseName,
    SUM(mf.size * 8 / 1024) AS TotalSizeMB
FROM sys.databases d
JOIN sys.master_files mf 
    ON d.database_id = mf.database_id
GROUP BY d.name
ORDER BY TotalSizeMB DESC;


/* ==================================
   Database Inventory - Full Detail
   ================================== */

SELECT
    d.name AS DatabaseName,
    d.database_id,
    d.recovery_model_desc AS RecoveryModel,
    d.compatibility_level AS CompatibilityLevel,
    d.collation_name AS Collation,
    d.user_access_desc AS AccessMode,
    d.state_desc AS State,
    d.is_read_only AS ReadOnly,
    SUM(mf.size * 8 / 1024) AS TotalSizeMB,
    SUM(CASE WHEN mf.type = 0 THEN mf.size * 8 / 1024 ELSE 0 END) AS DataSizeMB,
    SUM(CASE WHEN mf.type = 1 THEN mf.size * 8 / 1024 ELSE 0 END) AS LogSizeMB
FROM sys.databases d
JOIN sys.master_files mf 
    ON d.database_id = mf.database_id
GROUP BY
    d.name,
    d.database_id,
    d.recovery_model_desc,
    d.compatibility_level,
    d.collation_name,
    d.user_access_desc,
    d.state_desc,
    d.is_read_only
ORDER BY TotalSizeMB DESC;