SELECT distinct
    sc.TABLE_CATALOG as DBname,
    t.name AS TableName,
    c.name AS ColumnName
	--,
  --  ty.name AS DataType,
	--IIF(c.max_length = -1, ty.name + '(max)',ty.name) AS DataTypeDisplay

FROM 
    sys.tables t
JOIN 
    sys.columns c ON t.object_id = c.object_id
JOIN 
    sys.types ty ON c.user_type_id = ty.user_type_id
JOIN 
    INFORMATION_SCHEMA.COLUMNS sc ON sc.TABLE_NAME = t.name
WHERE 
    ty.name = 'nvarchar'
    AND c.max_length = -1
ORDER BY 
    t.name, c.name;
