SELECT

    PARSENAME(REPLACE(REPLACE(mid.statement, '[', ''), ']', ''), 3) AS DatabaseName,
    PARSENAME(REPLACE(REPLACE(mid.statement, '[', ''), ']', ''), 2) AS SchemaName,
    PARSENAME(REPLACE(REPLACE(mid.statement, '[', ''), ']', ''), 1) AS TableName ,
    migs.avg_user_impact,
	migs.user_scans,
	migs.user_seeks,
    CONVERT (varchar(30), getdate(), 126) AS runtime,
   'CREATE INDEX index_'+PARSENAME(REPLACE(REPLACE(mid.statement, '[', ''), ']', ''), 1)+ '  ON  ' + mid.statement + ' (' + ISNULL (mid.equality_columns, '') + CASE
    WHEN mid.equality_columns IS NOT NULL
    AND mid.inequality_columns IS NOT NULL THEN ','
    ELSE ''
  END + ISNULL (mid.inequality_columns, '') + ')' + ISNULL (' INCLUDE (' + mid.included_columns + ')', '') AS create_index_statement
  --,
  --migs.* 
  
FROM sys.dm_db_missing_index_groups mig
	INNER JOIN sys.dm_db_missing_index_group_stats migs ON migs.group_handle = mig.index_group_handle
	INNER JOIN sys.dm_db_missing_index_details mid ON mig.index_handle = mid.index_handle
WHERE migs.avg_user_impact>30
ORDER BY 
migs.avg_user_impact,
user_seeks desc
---,
--user_scans 