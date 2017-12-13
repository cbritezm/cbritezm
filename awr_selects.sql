--------------------------------------------------------------------------------
-- AWR usefull selects
--------------------------------------------------------------------------------

-- Read by other session

select snap_id, sample_time, session_id, session_serial#,user_id,sql_id,sql_plan_hash_value,current_obj#,current_file#,current_block#,program,module,action,blocking_session,
blocking_session_serial#,top_level_sql_id, event_name,time_waited/1000 as time_waited_ms
from sys.wrh$_active_session_history ass,sys.wrh$_event_name en
where ass.event_id=en.event_id and en.event_name='read by other session'
order by snap_id desc, sample_time desc;

-- Read by other session time waited, from snap_id
--------------------------------------------------------------------------------

select sql_id, sum(time_waited) as time_waited 
from sys.wrh$_active_session_history ass,sys.wrh$_event_name en
where ass.event_id=en.event_id and en.event_name='read by other session' and snap_id=5562
group by sql_id
order by 2 desc;

-- Waits
--------------------------------------------------------------------------------

select en.event_name, count(*) as esperas, sum(time_waited) as time_waited 
from sys.wrh$_active_session_history ass,sys.wrh$_event_name en
where ass.event_id=en.event_id
group by en.event_name
order by 3 desc;

-- db file sequential read. reads quantity
--------------------------------------------------------------------------------

select ao.object_name, count(*) as lecturas         
from sys.wrh$_active_session_history ass,sys.wrh$_event_name en,all_objects ao
where ass.event_id=en.event_id and en.event_name='db file sequential read' and current_obj# not in (0,-1) and ASS.CURRENT_OBJ#=AO.OBJECT_ID --and snap_id=5562
group by ao.object_name
order by 2 desc;

-- Reads by datafile
--------------------------------------------------------------------------------

select   df.file_name, count(*) as lecturas      
from sys.wrh$_active_session_history ass,sys.wrh$_event_name en,dba_data_files df
where ass.event_id=en.event_id and en.event_name='db file sequential read'  and ass.current_file#=df.file_id--and snap_id=5562
group by df.file_name
order by 2 desc;

--Waits by hour.
--------------------------------------------------------------------------------

select   to_char(s.begin_interval_time,'HH24:MI') as hora, count(*) as esperas
from sys.wrh$_active_session_history ass,sys.wrh$_event_name en,sys.wrm$_snapshot s
where ass.event_id=en.event_id and en.event_name='db file sequential read' and ASS.SNAP_ID=S.SNAP_ID and trunc(s.begin_interval_time)=trunc(sysdate) and to_char(s.begin_interval_time,'MI')='00'
group by s.begin_interval_time
order by s.begin_interval_time;

