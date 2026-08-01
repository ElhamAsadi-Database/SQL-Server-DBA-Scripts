
---Script 09 – Primary key 

SELECT 
    t.name AS TableName,
    c.name AS PKColumn,
    ty.name AS DataType,
    c.max_length,
    i.name AS PKName
FROM sys.indexes i
JOIN sys.index_columns ic 
    ON i.object_id = ic.object_id AND i.index_id = ic.index_id
JOIN sys.columns c 
    ON ic.object_id = c.object_id AND ic.column_id = c.column_id
JOIN sys.types ty 
    ON c.user_type_id = ty.user_type_id
JOIN sys.tables t 
    ON t.object_id = i.object_id
WHERE 
    i.is_primary_key = 1
ORDER BY t.name;


SELECT 
    t.name AS TableName,
    c.name AS PKColumn,
    ty.name AS DataType,
    c.default_object_id,
    dc.definition AS DefaultValue
FROM sys.indexes i
JOIN sys.index_columns ic 
    ON i.object_id = ic.object_id AND i.index_id = ic.index_id
JOIN sys.columns c 
    ON ic.object_id = c.object_id AND ic.column_id = c.column_id
JOIN sys.types ty 
    ON c.user_type_id = ty.user_type_id
LEFT JOIN sys.default_constraints dc 
    ON c.default_object_id = dc.object_id
JOIN sys.tables t 
    ON t.object_id = i.object_id
WHERE 
    i.is_primary_key = 1
ORDER BY t.name;


SELECT 
name
FROM sys.triggers
WHERE parent_id = OBJECT_ID('AccountChargeState')



SELECT 
    t.name AS TableName,
    i.name AS IndexName,
    i.type_desc,
    c.name AS ColumnName,
    ty.name AS DataType
FROM sys.indexes i
JOIN sys.index_columns ic 
    ON i.object_id = ic.object_id AND i.index_id = ic.index_id
JOIN sys.columns c 
    ON ic.object_id = c.object_id AND ic.column_id = c.column_id
JOIN sys.types ty 
    ON c.user_type_id = ty.user_type_id
JOIN sys.tables t 
    ON t.object_id = i.object_id
WHERE 
    i.is_primary_key = 1
    AND i.type_desc = 'CLUSTERED'


	SELECT 
    t.name AS TableName,
    c.name AS ColumnName,
    ty.name AS DataType,
    c.max_length,
    c.is_nullable,
    c.is_identity
FROM sys.tables t
JOIN sys.columns c ON t.object_id = c.object_id
JOIN sys.types ty ON c.user_type_id = ty.user_type_id
WHERE 
    ty.name IN (
        'nvarchar', 'varchar', 'text', 'ntext', 
        'nvarchar(max)', 'varchar(max)',
        'datetime', 'smalldatetime',
        'float', 'real'
    )
ORDER BY t.name, c.column_id;

