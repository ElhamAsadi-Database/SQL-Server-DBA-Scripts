
---------------------------------------------------------

---------------------------------------------------------
-- Overlapping Indexes Scan - One Script Version
-- Prepared for:  Elham Asadi
---------------------------------------------------------

WITH
---------------------------------------------------------
-- 1) Key Columns (Ordered by key_ordinal)
---------------------------------------------------------
KeyCols AS (
    SELECT
        i.object_id,
        i.index_id,
        i.name AS IndexName,
        STRING_AGG(COL_NAME(ic.object_id, ic.column_id), ',')
            WITHIN GROUP (ORDER BY ic.key_ordinal) AS KeyColumns
    FROM sys.indexes i
    JOIN sys.index_columns ic
        ON  i.object_id = ic.object_id
        AND i.index_id  = ic.index_id
    WHERE 
        i.type_desc = 'NONCLUSTERED'
        AND i.is_primary_key = 0
        AND i.is_unique_constraint = 0
        AND ic.is_included_column = 0
    GROUP BY i.object_id, i.index_id, i.name
),

---------------------------------------------------------
-- 2) Include Columns (Ordered by index_column_id)
---------------------------------------------------------
IncludeCols AS (
    SELECT
        i.object_id,
        i.index_id,
        STRING_AGG(COL_NAME(ic.object_id, ic.column_id), ',')
            WITHIN GROUP (ORDER BY ic.index_column_id) AS IncludeColumns
    FROM sys.indexes i
    JOIN sys.index_columns ic
        ON  i.object_id = ic.object_id
        AND i.index_id  = ic.index_id
    WHERE 
        i.type_desc = 'NONCLUSTERED'
        AND i.is_primary_key = 0
        AND i.is_unique_constraint = 0
        AND ic.is_included_column = 1
    GROUP BY i.object_id, i.index_id
),

---------------------------------------------------------
-- 3) Merge Key + Include Columns
---------------------------------------------------------
Merged AS (
    SELECT
        k.object_id,
        k.index_id,
        k.IndexName,
        k.KeyColumns,
        ISNULL(i.IncludeColumns, '') AS IncludeColumns
    FROM KeyCols k
    LEFT JOIN IncludeCols i
        ON  k.object_id = i.object_id
        AND k.index_id  = i.index_id
),

---------------------------------------------------------
-- 4) Overlapping Indexes Detection

---------------------------------------------------------
Overlaps AS (
    SELECT
        A.object_id,
        OBJECT_SCHEMA_NAME(A.object_id) AS SchemaName,
        OBJECT_NAME(A.object_id) AS TableName,

        A.index_id       AS CoveredIndexID,
        A.IndexName      AS CoveredIndexName,
        A.KeyColumns     AS CoveredKeys,
        A.IncludeColumns AS CoveredIncludes,

        B.index_id       AS CoveringIndexID,
        B.IndexName      AS CoveringIndexName,
        B.KeyColumns     AS CoveringKeys,
        B.IncludeColumns AS CoveringIncludes
    FROM Merged A
    JOIN Merged B
        ON  A.object_id = B.object_id
        AND A.index_id <> B.index_id
        AND B.KeyColumns LIKE A.KeyColumns + '%'
)

---------------------------------------------------------
-- Final Output
---------------------------------------------------------
SELECT *
FROM Overlaps
ORDER BY SchemaName, TableName, CoveredKeys, CoveredIndexID;
