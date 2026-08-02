-- Below we can see the number of Inserts, Updates and Deletes that occurred for each index, so this shows how much work SQL Server had to do to maintain the index. 
SELECT OBJECT_NAME(A.[OBJECT_ID]) AS [OBJECT NAME], 
       I.[NAME] AS [INDEX NAME], 
       A.LEAF_INSERT_COUNT, 
       A.LEAF_UPDATE_COUNT, 
       A.LEAF_DELETE_COUNT 
FROM   SYS.DM_DB_INDEX_OPERATIONAL_STATS (db_id(),NULL,NULL,NULL ) A 
       INNER JOIN SYS.INDEXES AS I 
         ON I.[OBJECT_ID] = A.[OBJECT_ID] 
            AND I.INDEX_ID = A.INDEX_ID 
WHERE  OBJECTPROPERTY(A.[OBJECT_ID],'IsUserTable') = 1
-- ****************************************************************************
SELECT OBJECT_NAME(S.[OBJECT_ID]) AS [OBJECT NAME], 
       I.[NAME] AS [INDEX NAME], 
       USER_SEEKS, 
       USER_SCANS, 
       USER_LOOKUPS, 
       USER_UPDATES 
FROM   SYS.DM_DB_INDEX_USAGE_STATS AS S 
       INNER JOIN SYS.INDEXES AS I ON I.[OBJECT_ID] = S.[OBJECT_ID] AND I.INDEX_ID = S.INDEX_ID 
WHERE  OBJECTPROPERTY(S.[OBJECT_ID],'IsUserTable') = 1
       AND S.database_id = DB_ID()
ORDER BY       USER_SEEKS, 
       USER_SCANS, 
       USER_LOOKUPS, 
       USER_UPDATES 
--*****************************************************************************
-- Ensure a USE  statement has been executed first.
SELECT [DatabaseName]
	,[ObjectId]
	,[ObjectName]
	,[IndexId]
	,[IndexDescription]
	,CONVERT(DECIMAL(16, 1), (SUM([avg_record_size_in_bytes] * [record_count]) / (1024.0 * 1024))) AS [IndexSize(MB)]
	,[lastupdated] AS [StatisticLastUpdated]
	,[AvgFragmentationInPercent]
FROM (
	SELECT DISTINCT DB_Name(Database_id) AS 'DatabaseName'
		,OBJECT_ID AS ObjectId
		,Object_Name(Object_id) AS ObjectName
		,Index_ID AS IndexId
		,Index_Type_Desc AS IndexDescription
		,avg_record_size_in_bytes
		,record_count
		,STATS_DATE(object_id, index_id) AS 'lastupdated'
		,CONVERT([varchar](512), round(Avg_Fragmentation_In_Percent, 3)) AS 'AvgFragmentationInPercent'
	FROM sys.dm_db_index_physical_stats(db_id(), NULL, NULL, NULL, 'detailed')
	WHERE OBJECT_ID IS NOT NULL
		AND Avg_Fragmentation_In_Percent <> 0
	) T
GROUP BY DatabaseName
	,ObjectId
	,ObjectName
	,IndexId
	,IndexDescription
	,lastupdated
	,AvgFragmentationInPercent