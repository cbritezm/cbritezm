--------------------------------------------------------------------------------
--		PACKAGE BLOCKED
--------------------------------------------------------------------------------

BREAK ON sid ON lock_id1 ON kill_sid

COL sid            FOR 999999
COL lock_type      FOR A38
COL mode_held      FOR A12
COL mode_requested FOR A12
COL lock_id1       FOR A20
COL lock_id2       FOR A20
COL kill_sid       FOR A50

SELECT s.sid,l.lock_type,l.mode_held,l.mode_requested,l.lock_id1,'alter system kill session '''|| s.sid|| ','|| s.serial#|| ''' immediate;' kill_sid
FROM   dba_lock_internal l,v$session s
WHERE  s.sid = l.session_id AND    UPPER(l.lock_id1) LIKE '%&package_name%' AND    l.lock_type = 'Body Definition Lock';

--------------------------------------------------------------------------------
--		PACKAGE BLOCKED - WHAT SESSION IS DOING.
--------------------------------------------------------------------------------

BREAK ON sid ON username ON osuser ON os_pid ON program

SELECT s.sid,NVL(s.username, 'ORACLE PROC') username,s.osuser,p.spid os_pid,s.program,t.sql_text
FROM   v$session s,v$sqltext t,v$process p
WHERE  s.sql_hash_value = t.hash_value AND    s.paddr = p.addr AND    s.sid = &session_id AND    t.piece = 0 -- optional to list just the first line
ORDER BY s.sid, t.hash_value, t.piece;

--------------------------------------------------------------------------------
--		PACKAGE BLOCKED - OSPID
--------------------------------------------------------------------------------
SELECT s.sid, s.serial#, p.spid
FROM v$process p, v$session s
WHERE p.addr = s.paddr
AND s.SID=&sid