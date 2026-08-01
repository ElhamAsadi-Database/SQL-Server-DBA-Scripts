SELECT 
    DB_NAME(ius.database_id) AS DatabaseName,
    s.name AS SchemaName,
    t.name AS TableName,
    i.name AS IndexName,
    i.index_id,
    i.type_desc AS IndexType,
    i.is_primary_key,
    i.is_unique,
    ius.user_seeks,
    ius.user_scans,
    ius.user_lookups,
    ius.user_updates,
    ius.last_user_seek,
    ius.last_user_scan,
    ius.last_user_lookup,
    ius.last_user_update,
    ps.page_count,
    (ps.page_count * 8) / 1024 AS IndexSizeMB
FROM sys.dm_db_index_usage_stats AS ius
JOIN sys.indexes AS i 
    ON ius.object_id = i.object_id 
    AND ius.index_id = i.index_id
JOIN sys.objects t 
    ON t.object_id = i.object_id
JOIN sys.schemas s 
    ON t.schema_id = s.schema_id
OUTER APPLY sys.dm_db_index_physical_stats(DB_ID(), i.object_id, i.index_id, NULL, 'SAMPLED') ps
WHERE 
    ius.database_id = DB_ID()
    AND i.index_id > 1 --  heap - clustered
    AND ius.user_seeks = 0
    AND ius.user_scans = 0
    AND ius.user_lookups = 0
	AND is_unique=0
	AND is_primary_key=0
ORDER BY IndexSizeMB DESC;