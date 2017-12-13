--------------------------------------------------------------------------------
-- Drop user objects
--------------------------------------------------------------------------------

select 'DROP '|| object_type ||' '|| owner ||'.'|| object_name ||';'
from dba_objects
where owner in (upper('&UserName'))
and object_type in ('TABLE', 'VIEW', 'PROCEDURE', 'FUNCTION', 'PACKAGE', 'SEQUENCE', 'TRIGGER','MATERIALIZED VIEW','INDEX','SYNONYM','TYPE')
order by object_id desc;


set lines 200
set pagesize 0
set feedback off
set echo off
set heading off
accept USERNAME prompt 'Enter objects owner to delete:'
set verify off
spool drop_&USERNAME..sql
Select 'DROP '|| object_type ||' '|| owner ||'.'|| object_name || DECODE(OBJECT_TYPE,'TABLE',' CASCADE CONSTRAINTS','')||';'
from dba_objects
where owner in (upper('&USERNAME'))
and object_type in ('TABLE', 'VIEW', 'PROCEDURE', 'FUNCTION', 'PACKAGE', 'SEQUENCE', 'TRIGGER','MATERIALIZED VIEW','SYNONYM','TYPE')
order by object_id desc;
spool off
quit

--------------------------------------------------------------------------------
-- Purge schema objects. Connect with the user
--------------------------------------------------------------------------------
SET SERVEROUTPUT OFF;
SET DEFINE OFF;
SET PAGESIZE 0;
SET HEADING OFF;
SET FEEDBACK OFF;
SET ECHO OFF;
DECLARE
BEGIN
  FOR obj IN (SELECT 'DROP '||object_type||' "'||object_name||'"'||DECODE(object_type,'TABLE',' CASCADE CONSTRAINTS','TYPE',' FORCE') AS drop_sql
                FROM user_objects
                WHERE object_type IN ('TABLE','VIEW','PACKAGE','TYPE','PROCEDURE','FUNCTION','TRIGGER','SEQUENCE','SYNONYM','MATERIALIZED VIEW')
                ORDER BY object_id ) LOOP
    BEGIN
      EXECUTE IMMEDIATE obj.drop_sql;
    EXCEPTION WHEN OTHERS THEN
      NULL;
    END;
  END LOOP;
        execute immediate 'purge recyclebin';
END;
/
SELECT DECODE(COUNT(*),0,'OK','KO') ans
FROM user_objects where object_type not in ('DATABASE LINK');

