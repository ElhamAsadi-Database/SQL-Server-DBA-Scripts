/* ==================================
   Script 03 - Table Size Summary
   ================================== */

   SELECT
    t.name AS TableName,
    SUM(p.rows) AS TotalRows,
    SUM(a.total_pages) * 8 AS TotalSpaceKB,
    SUM(a.used_pages) * 8 AS UsedSpaceKB,
    SUM(a.data_pages) * 8 AS DataSpaceKB
FROM sys.tables t
INNER JOIN sys.indexes i 
    ON t.object_id = i.object_id
INNER JOIN sys.partitions p 
    ON i.object_id = p.object_id 
    AND i.index_id = p.index_id
INNER JOIN sys.allocation_units a 
    ON p.partition_id = a.container_id
WHERE t.is_ms_shipped = 0
AND i.index_id <= 1     -- فقط Heap و Clustered Index برای RowCount
GROUP BY t.name
ORDER BY DataSpaceKB DESC;