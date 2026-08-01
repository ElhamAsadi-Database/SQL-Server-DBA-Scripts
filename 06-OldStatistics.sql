SELECT  
    sch.name              AS SchemaName,
    t.name                AS TableName,
    s.name                AS StatsName,
    st.stats_id,
    s.auto_created,
    s.user_created,
    s.no_recompute,
    sp.last_updated,
    sp.rows,
    sp.rows_sampled,
    sp.modification_counter,

    CASE 
        WHEN sp.modification_counter = 0
            THEN 'OK'
        WHEN sp.modification_counter > (sp.rows * 0.20)   -- 20% changes
            THEN 'STALE - UPDATE NEEDED (Major Changes)'
        WHEN sp.modification_counter > 5000               -- Microsoft heuristic
            THEN 'STALE - UPDATE NEEDED'
        ELSE 'OK'
    END AS Status

FROM sys.stats s
JOIN sys.objects t          ON s.object_id = t.object_id
JOIN sys.schemas sch        ON t.schema_id = sch.schema_id
CROSS APPLY sys.dm_db_stats_properties(s.object_id, s.stats_id) sp
LEFT JOIN sys.stats_columns st
    ON s.object_id = st.object_id AND s.stats_id = st.stats_id

WHERE 
    t.type = 'U'  -- user tables
    AND sp.modification_counter IS NOT NULL
    AND (
            sp.modification_counter > (sp.rows * 0.20)
         OR sp.modification_counter > 5000
        )

ORDER BY sp.modification_counter DESC, sp.last_updated ASC;