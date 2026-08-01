SELECT  
    DB_NAME(database_id) AS DatabaseName,
    OBJECT_NAME(i.object_id) AS TableName,
    i.name AS IndexName,
    i.index_id,
    i.type_desc AS IndexType,
    ius.user_seeks,
    ius.user_scans,
    ius.user_lookups,
    ius.user_updates,
    (isnull(ius.user_seeks,0 )+ isnull(ius.user_scans,0) + isnull(ius.user_lookups,0)) AS TotalReads,
    ius.last_user_seek,
    ius.last_user_scan,
    ius.last_user_lookup,
    ius.last_user_update
FROM sys.indexes AS i
JOIN sys.dm_db_index_usage_stats AS ius
    ON i.object_id = ius.object_id
   AND i.index_id = ius.index_id
WHERE ius.database_id = DB_ID()  
  AND i.is_hypothetical = 0
  AND i.index_id > 0
ORDER BY TotalReads desc;
