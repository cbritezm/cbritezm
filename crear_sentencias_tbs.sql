--------------------------------------------------------------------------------
-- Recreate tablespace
--------------------------------------------------------------------------------

set heading off
set lines 200
spool create_tbs.sql

select 'create tablespace '||t1.tablespace_name||' datafile '''||t2.file_name||''' size '||t3.tablespace_size||' autoextend on next 10M;'
from dba_tablespaces t1 inner join dba_data_files t2 on (t1.tablespace_name=t2.tablespace_name) inner join dba_tablespace_usage_metrics t3 on (t2.tablespace_name=t3.tablespace_name)
/
spool off
quit
