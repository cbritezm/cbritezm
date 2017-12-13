--############################################################################
--#			GET CURRENT DB PROCESSES (USER PROCESSES)						 #
--############################################################################
SELECT sess.process, sess.status, sess.username, sess.schemaname, sql.sql_text
FROM v$session sess,
v$sql     sql
WHERE sql.sql_id(+) = sess.sql_id AND sess.type= 'USER';


--############################################################################
--#					GET PROCESSES HISTORY									 #
--############################################################################

select
   a.begin_interval_time,
   a.end_interval_time,
   b.resource_name,
   b.current_utilization,
   b.max_utilization
from
   dba_hist_resource_limit b,
   dba_hist_snapshot a
where
   a.snap_id = b.snap_id
and
   b.resource_name = 'processes'
order by
   a.begin_interval_time;