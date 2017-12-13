--------------------------------------------------------------------------------
-- Kill user session
--------------------------------------------------------------------------------
SET HEADING OFF FEEDBACK OFF ECHO OFF PAGESIZE 0
spool sessions.sql
select 'alter system kill session ''' ||sid|| ',' || serial#|| ''' immediate;' from v$session where status='INACTIVE';
spool off
