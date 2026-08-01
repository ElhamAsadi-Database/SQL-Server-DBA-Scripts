select 
sch.name as schemaname,
obj.name as tablename,
sum(ps.row_count) as totalrows,
st.name as Statsname,
STATS_DATE(st.object_id, st.stats_id)as lastupdated,
sp.modification_counter as modifierows,
DATEDIFF(day,STATS_DATE(st.object_id, st.stats_id), GETDATE()) as daysold

from  sys.stats st

cross apply sys.dm_db_stats_properties(st.object_id, st.stats_id) sp
join sys.objects obj
     on st.object_id=obj.object_id
join sys.schemas sch
     on sch.schema_id=obj.schema_id
join sys.dm_db_partition_stats ps
     on obj.object_id=ps.object_id
where obj.type='U'
and ps.index_id in (0,1)


group by 
sch.name,
obj.name,
st.name, 
st.object_id,
st.stats_id,
sp.modification_counter
having  sum(ps.row_count)>0 and modification_counter>sum(ps.row_count)*20/100
order by daysold , modifierows

--update statistics dbo.UserActivity with fullscan
--update statistics dbo.UserAttemptsLogs with sample 5 percent
--update statistics dbo.UserSecuritySetting with sample 30 percent

