--------------------------------------------------------------------------------
--				BLOCKED OBJECTS: LOCK TYPE,USERNAME,OWNER,OBJECT_NAME			
--------------------------------------------------------------------------------

COLUMN owner FORMAT A20
COLUMN username FORMAT A20
COLUMN object_owner FORMAT A20
COLUMN object_name FORMAT A30
COLUMN locked_mode FORMAT A15
 
SELECT b.inst_id,
       b.session_id AS sid,
       NVL(b.oracle_username, '(oracle)') AS username,
       a.owner AS object_owner,
       a.object_name,
       Decode(b.locked_mode, 0, 'None',
                             1, 'Null (NULL)',
                             2, 'Row-S (SS)',
                             3, 'Row-X (SX)',
                             4, 'Share (S)',
                             5, 'S/Row-X (SSX)',
                             6, 'Exclusive (X)',
                             b.locked_mode) locked_mode,
       b.os_user_name
FROM   dba_objects a,
       gv$locked_object b
WHERE  a.object_id = b.object_id
ORDER BY 1, 2, 3, 4


--		DETAILLED BLOCKED OBJECTS: USERNAME,MACHINE,OBJECT,OBJECT_TYPE,SQL_ID				
--------------------------------------------------------------------------------
col object_name format a35
col owner format a15
col osuser format a15
col machine format a30
col logedin format a25
select c.owner,c.object_name,c.object_type,b.sid,b.serial#,b.status,b.osuser,b.machine,b.sql_id,TO_CHAR(logon_time,'DD/MM/YYYY HH24:MI:SS') as logedin,last_call_et timeoff
from v$locked_object a ,v$session b,dba_objects c
where b.sid = a.session_id and a.object_id = c.object_id;
   

--										RAC BLOCKED OBJECTS												+
--------------------------------------------------------------------------------

col owner format a10
col object_name format a30
col osuser format a10
col machine format a25
set lines 300
  
select a.inst_id,c.owner,c.object_name,c.object_type,b.sid,b.serial#,b.status,b.osuser,to_char(b.logon_time,'DD/MM/YYYY HH24:MI:SS') as Logedin,b.machine
from gv$locked_object a , gv$session b, dba_objects c
where b.sid = a.session_id  and a.object_id = c.object_id and upper(b.machine)='ESPINA' and c.object_name='PKG_COMUNICACIO_RALC' ;
   
select a.inst_id,c.owner,c.object_name,c.object_type,b.sid,b.serial#,b.status,b.osuser,to_char(b.logon_time,'DD/MM/YYYY HH24:MI:SS') as Logedin,b.machine
from gv$locked_object a , gv$session b, dba_objects c
where b.sid = a.session_id  and a.object_id = c.object_id
order by b.logon_time desc;
   
   
--							RAC BLOCKED OBJECTS: CREATE KILL SESSION									+
--------------------------------------------------------------------------------

set lines 300
SELECT 'ALTER SYSTEM KILL SESSION '||''''||b.sid||','||b.serial#||''''||' immediate;'
from gv$locked_object a , gv$session b, dba_objects c
where b.sid = a.session_id and a.object_id = c.object_id and upper(b.machine)='ESPINA';
   