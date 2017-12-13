set echo off;
set pagesize 500;
set feedback off;
set serverout off;
set termout off;
spool resources_usage.txt append;
select resource_name,current_utilization,max_utilization,limit_value from v$resource_limit
where resource_name IN ('processes','sessions','transactions');
spool off;
quit
