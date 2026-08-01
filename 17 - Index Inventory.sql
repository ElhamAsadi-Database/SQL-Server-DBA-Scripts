/* ==================================
   Script 04 - Index Inventory
   ================================== */

SELECT 
    t.name AS TableName,
    i.name AS IndexName,
    i.index_id,
    i.type_desc,
    i.is_unique,
    i.is_primary_key
FROM sys.indexes i
JOIN sys.tables t 
    ON i.object_id = t.object_id
WHERE i.index_id > 0         -- Ignore heap/internal
ORDER BY t.name, i.index_id;


SELECT 
    t.name AS TableName,
    COUNT(i.index_id) AS IndexCount,
    STRING_AGG(i.name, ', ') WITHIN GROUP (ORDER BY i.name) AS IndexNames
FROM sys.indexes i
JOIN sys.tables t 
    ON i.object_id = t.object_id
WHERE i.index_id > 0
GROUP BY t.name
ORDER BY IndexCount DESC;