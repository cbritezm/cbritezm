--------------------------------------------------------------------------------
--			DATABASE SESSIONS CPU USAGE IP MACHINE EXPLAIN PLAN TRACE		
--------------------------------------------------------------------------------

-- List of session by machine and ip
select client_identifier,sid,serial#,status,USERNAME,MACHINE,utl_inaddr.get_host_address(substr(machine,instr(machine,'\')+1)) IP
from v$session;



--------------------------------------------------------------------------------
--	DATABASE SESSIONS FROM USER 		
--------------------------------------------------------------------------------

SELECT s.sid, s.serial#, s.username,s.sql_id, s.osuser, p.spid, s.machine, utl_inaddr.get_host_address(substr(machine,instr(machine,'\')+1)) IP
FROM v$session s, v$process p
WHERE s.paddr = p.addr AND s.username=upper('&Username');

--------------------------------------------------------------------------------
-- SEEESION UNIX PID AND IP CLIENT		
--------------------------------------------------------------------------------

SELECT s.sid, s.serial#, s.username,s.sql_id, s.osuser, p.spid, s.machine, utl_inaddr.get_host_address(substr(machine,instr(machine,'\')+1)) IP
FROM v$session s, v$process p
WHERE s.paddr = p.addr AND s.username='E13_BOR';



--------------------------------------------------------------------------------
--		SESSION CPU USAGE				
--------------------------------------------------------------------------------

SELECT ss.username,se.SID,p.spid,ss.sql_id,VALUE/100 cpu_usage_seconds
from v$session ss,v$sesstat se, v$statname sn,v$process p
where se.STATISTIC# = sn.STATISTIC# and NAME like '%CPU used by this session%'  and se.SID = ss.SID and  ss.status='ACTIVE' and  ss.username is not null and ss.paddr = p.addr
order by VALUE desc;


-------------------------------------------------------------------------------------------------
-- Session status scripts
-------------------------------------------------------------------------------------------------

--Get session info
-------------------------------------------------------------------------------------------------

SET PAGESIZE 9999;
SET VERIFY off;
SET FEEDBACK off;
SET LINESIZE 132;

COLUMN uname      HEADING  'User|Name'               FORMAT A11;
COLUMN sid        HEADING  'Oracle|SID'              FORMAT 999999;
COLUMN pid        HEADING  'Oracle|PID'              FORMAT 999999;
COLUMN sernum     HEADING  'Serial#'                 FORMAT 999999;
COLUMN spid       HEADING  'Server|PID'              FORMAT 999999;
COLUMN suser      HEADING  'Client|OS User'          FORMAT A8;
COLUMN status     HEADING  'Status'                  FORMAT A8;
COLUMN server     HEADING  'Server'                  FORMAT A9;
COLUMN process    HEADING  'Client|Process'          FORMAT A8;
COLUMN smach      HEADING  'Client|Machine'          FORMAT A15   WORD_WRAPPED;
COLUMN sprog      HEADING  'Program'                 FORMAT A15   WORD_WRAPPED;
COLUMN cli        HEADING  'Client|Info'             FORMAT A15   WORD_WRAPPED;

SELECT a.username uname,a.sid sid,b.pid pid,a.serial# sernum,b.spid spid,a.osuser suser,a.status status,a.server server,a.machine smach,a.process process,a.program sprog,a.client_info cli
FROM v$session a, v$process b
WHERE a.paddr = b.addr AND a.type != 'BACKGROUND'
ORDER BY a.sid;


--------------------------------------------------------------------------------
--		SESSION ENABLE TRACE			#
--------------------------------------------------------------------------------
exec sys.dbms_system.set_sql_trace_in_session(109,333,TRUE); 


exec sys.dbms_system.set_sql_trace_in_session(109,333,FALSE); 

--------------------------------------------------------------------------------
--		SESSION EXPLAIN PLAN			
--------------------------------------------------------------------------------

select plan_table_output from
table(dbms_xplan.display_cursor('bv82a1h58wsfr',null,'all +PEEKED_BINDS'));
