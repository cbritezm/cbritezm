--------------------------------------------------------------------------------
-- Kill session
--------------------------------------------------------------------------------

-- spool file
--------------------------------------------------------------------------------

set heading off
set lines 200
spool kills.sql
select 'ALTER SYSTEM KILL SESSION '''||sid||','||serial#||''' immediate;' from v$session where username='VUM'
/
spool off

-- plsql kill
--------------------------------------------------------------------------------
begin
	for i in (select 'ALTER SYSTEM KILL SESSION '''||sid||','||serial#||',@'||inst_id||''' IMMEDIATE;' kill_cmd from gv$session where username is not null and inst_id=1 and last_call_et >4000)
	loop
		begin
			--execute immediate i.kill_cmd;
			dbms_output.put_line(i.kill_cmd);
		end;
	end loop;
end;
/

