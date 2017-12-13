--------------------------------------------------------------------------------
-- 				CREATE READ ROLE				  
--------------------------------------------------------------------------------

--set define off
set verify off
set feedback off
set heading off
set pagesize 0
--set echo off
accept schema_name prompt "SCHEMA NAME FOR READ ROLE:"
accept newrole prompt "NAME OF ROLE TO CREATE:"
set termout off
spool create_role_&newrole..sql
select 'CREATE ROLE '||upper('&&newrole')||';' from dual;
select 'GRANT '||
                                CASE
                                    WHEN OBJECT_TYPE='SYNONYM' OR 
										OBJECT_TYPE='VIEW' OR 
										OBJECT_TYPE='TABLE' OR
										OBJECT_TYPE='SEQUENCE' OR
										
									THEN 'SELECT'
                                    WHEN OBJECT_TYPE='PACKAGE' OR 
										OBJECT_TYPE='PACKAGE BODY' OR 
										OBJECT_TYPE='PROCEDURE' OR 
										OBJECT_TYPE='FUNCTION' 
									THEN 'DEBUG')
                                    ELSE ''
                                END
                ||' ON '||owner||'.'||OBJECT_NAME||' TO '||upper('&newrole')||';'
from dba_objects
where owner=upper('&schema_name') AND OBJECT_TYPE NOT IN ('INDEX','JOB','TRIGGER','TYPE','DB_LINK','TABLE PARTITION');
spool off
exit
