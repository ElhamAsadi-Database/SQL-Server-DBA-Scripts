---------------------------------------------------------
-- Index Fragmentation QUICK SCAN (Recommended Version)
-- Prepared for: الهام
---------------------------------------------------------
--PageCount < 1000

--→ ایندکس کوچک، Ignore

--5% ≤ Frag ≤ 30%

--→ Reorganize

--Frag > 30%

--→ Rebuild


WITH Frag AS (
    SELECT
        DB_NAME() AS DatabaseName,
        OBJECT_SCHEMA_NAME(i.object_id) AS SchemaName,
        OBJECT_NAME(i.object_id) AS TableName,
        i.name AS IndexName,
        i.index_id,
        ps.avg_fragmentation_in_percent AS FragPercent,
        ps.page_count AS PageCount
    FROM sys.indexes i
    JOIN sys.dm_db_index_physical_stats(
            DB_ID(), NULL, NULL, NULL, 'SAMPLED'
         ) ps
        ON  i.object_id = ps.object_id
        AND i.index_id  = ps.index_id
    WHERE 
        i.index_id > 0
        AND i.is_disabled = 0
        AND ps.page_count > 0
)

SELECT
    DatabaseName,
    SchemaName,
    TableName,
    IndexName,
    index_id,
    FragPercent,
    PageCount,

    CASE
        WHEN PageCount < 1000
            THEN 'IGNORE (Small Index - No Maintenance)'
        WHEN FragPercent < 5
            THEN 'OK (No Action)'
        WHEN FragPercent BETWEEN 5 AND 30
            THEN 'REORGANIZE Recommended'
        WHEN FragPercent > 30
            THEN 'REBUILD Recommended'
        ELSE 'Check Manually'
    END AS ActionRecommendation

FROM Frag
ORDER BY FragPercent DESC, PageCount DESC;
