-- -----------------------------------------------------------------------------
-- Get index usage from awr tables. 
-- -----------------------------------------------------------------------------

set lines 200
set pages 250  

ACCEPT days number PROMPT 'Enter num days       :  '; 
ACCEPT owner char PROMPT  'Enter indexes owner  :  '; 

SET VERIFY OFF

ttitle center '*********** INDEX USAGE *********** ' skip 2

col t0 heading 'Awr|Begin'         format a8 
col t1 heading 'Awr|End'           format a8 
col owner heading 'Owner|Name'        format a8
col table_name heading 'Table|Name'        format a30
col index_name heading 'Index|Name'        format a30
col sum_disk_reads_total heading 'Disk|Reads'        format 99,999,999,999
col sum_rows_processed_total heading 'Rows|Processed'    format 99,999,999
col count_invocations heading 'Invocation|Count'  format 999,999
col start_monitoring heading 'Start|Monitor' format a08 
col end_monitoring heading 'End|Monitor' format a08
col monitoring heading 'Monitored' format a6
col used heading  'Used' format a3 

select  trunc(sysdate - &&days ) t0, trunc(sysdate) t1 , tidx.owner owner , tidx.table_name table_name, tidx.INDEX_NAME index_name,tawr.sum_rows_processed_total, tawr.count_invocations,
tusg.start_monitoring, tusg.end_monitoring , tusg.monitoring , tusg.used 
from 
(
select p.object_owner, p.object_name,sum(t.disk_reads_total) sum_disk_reads_total,sum(t.rows_processed_total) sum_rows_processed_total, count(t.sql_id) count_invocations 
from dba_hist_sql_plan p,dba_hist_sqlstat  t, dba_hist_snapshot s 
where  p.sql_id = t.sql_id and t.snap_id = s.snap_id   and p.object_owner = '&&owner' and p.object_type like '%INDEX%' and s.begin_interval_time > sysdate - &&days
group by p.object_owner ,  p.object_name
) tawr , 
dba_indexes tidx  , 
( select u.name owner , io.name index_name , t.name table_name  ,decode(bitand(i.flags, 65536), 0, 'NO', 'YES') monitoring ,decode(bitand(ou.flags, 1), 0, 'NO', 'YES') used ,
trunc(to_date(ou.start_monitoring,'mm-dd-yyyy hh24:mi:ss')) start_monitoring, trunc(to_Date(ou.end_monitoring,'mm-dd-yyyy hh24:mi:ss')) end_monitoring
from sys.obj$ io, sys.obj$ t, sys.ind$ i, sys.object_usage ou, sys.user$ u
where i.obj# = ou.obj# and io.obj# = ou.obj#
and t.obj# = i.bo#
and io.owner# = u.user# ) tusg 
where tawr.OBJECT_OWNER (+) = tidx.owner  and tawr.object_name  (+) = tidx.INDEX_NAME and tusg.owner  (+) = tidx.owner and tusg.index_name   (+) = tidx.index_name and tidx.owner = '&&owner' 
order by  tidx.owner, tidx.table_name, tidx.INDEX_NAME
;
