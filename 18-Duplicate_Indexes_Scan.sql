--دو ایندکس زمانی Duplicate محسوب می‌شوند که:

--ستون‌های ایندکس (key columns) یکسان باشند
--ترتیب ستون‌ها یکسان باشد
----فقط INCLUDE متفاوت باشد (در بیشتر موارد ایندکس کوچکتر بهترین گزینه است)

--یا:

--ایندکسی کاملاً زیرمجموعه ایندکس بزرگ‌تر باشد (Subset Index)


---------------------------------------------------------
-- Duplicate Indexes Scan - Final Stable Version
-- Prepared for: الهام
---------------------------------------------------------

---------------------------------------------------------
-- 1. Key Columns (with independent ORDER BY)
---------------------------------------------------------
WITH KeyCols AS (
    SELECT
        i.object_id,
        i.index_id,
        i.name AS IndexName,
        STRING_AGG(COL_NAME(ic.object_id, ic.column_id), ',')
            WITHIN GROUP (ORDER BY ic.key_ordinal) AS KeyColumns
    FROM sys.indexes i
    JOIN sys.index_columns ic
        ON i.object_id = ic.object_id
        AND i.index_id = ic.index_id
    WHERE 
        i.is_primary_key = 0
        AND i.is_unique_constraint = 0
        AND ic.is_included_column = 0
        AND i.type_desc = 'NONCLUSTERED'
    GROUP BY 
        i.object_id, i.index_id, i.name
),

---------------------------------------------------------
-- 2. Include Columns (with its own ORDER BY)
---------------------------------------------------------
IncludeCols AS (
    SELECT
        i.object_id,
        i.index_id,
        STRING_AGG(COL_NAME(ic.object_id, ic.column_id), ',')
            WITHIN GROUP (ORDER BY ic.index_column_id) AS IncludeColumns
    FROM sys.indexes i
    JOIN sys.index_columns ic
        ON i.object_id = ic.object_id
        AND i.index_id = ic.index_id
    WHERE 
        i.is_primary_key = 0
        AND i.is_unique_constraint = 0
        AND ic.is_included_column = 1
        AND i.type_desc = 'NONCLUSTERED'
    GROUP BY 
        i.object_id, i.index_id
),

---------------------------------------------------------
-- 3. Merge Key + Include Columns
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
        ON k.object_id = i.object_id
        AND k.index_id = i.index_id
),

---------------------------------------------------------
-- 4. Identify Duplicate Indexes
---------------------------------------------------------
Duplicates AS (
    SELECT
        A.object_id,
        OBJECT_SCHEMA_NAME(A.object_id) AS SchemaName,
        OBJECT_NAME(A.object_id) AS TableName,

        A.index_id AS IndexID_A,
        A.IndexName AS IndexName_A,
        A.KeyColumns AS KeyCols_A,
        A.IncludeColumns AS IncludeCols_A,

        B.index_id AS IndexID_B,
        B.IndexName AS IndexName_B,
        B.KeyColumns AS KeyCols_B,
        B.IncludeColumns AS IncludeCols_B
    FROM Merged A
    JOIN Merged B
        ON A.object_id = B.object_id
        AND A.index_id < B.index_id
        AND A.KeyColumns = B.KeyColumns
)

---------------------------------------------------------
-- Final Output
---------------------------------------------------------
SELECT *
FROM Duplicates
ORDER BY SchemaName, TableName, KeyCols_A;
