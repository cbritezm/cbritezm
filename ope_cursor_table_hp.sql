CREATE TABLE HP_OPEN_CURSOR(
USERNAME VARCHAR2(30),
SID NUMBER,
SERIAL# NUMBER,
STATUS VARCHAR2(8),
MACHINE VARCHAR2(64),
SQL_ID VARCHAR2(13),
CURSOR_OPENED NUMBER,
CURSOR_CURRENT NUMBER,
LOGON_TIME DATE,
CURRENT_TIME DATE);


INSERT INTO HP_OPEN_CURSOR 
SELECT username,sid,serial#,status,machine,sql_id,"Opened Cursors","Current Cursors",logon_time,sysdate
from  (
	select 	ss.username username, 
			sum(decode(NAME,'opened cursors cumulative',value)) "Opened Cursors",
			sum(decode(NAME,'opened cursors current',value)) "Current Cursors",
			ss.sid sid ,ss.serial# serial#,ss.sql_id sql_id,logon_time,ss.status status,ss.machine machine
	from 	v$session ss, 
		v$sesstat se, 
		v$statname sn
	where 	se.STATISTIC# = sn.STATISTIC#
	and 	(NAME  like '%opened cursors current%'
	or 	 NAME  like '%recursive calls%'
	or 	 NAME  like '%opened cursors cumulative%')
	and 	se.SID = ss.SID
	and 	ss.USERNAME is not null
	group 	by ss.username,ss.sid,ss.serial#,ss.sql_id,logon_time,ss.status,machine
)
orasnap_user_cursors
order 	by "Current Cursors" desc;

select username,sid,serial#,status,machine,sql_id,cursor_current,to_char(logon_time,'dd/mm/yyyy hh24:mi:ss') logon_time,to_char(current_time,'dd/mm/yyyy hh24:mi:ss') current_time from hp_open_cursor where to_char(current_time,'dd/mm/yyyy')=to_char(sysdate,'dd/mm/yyyy') order by current_time;

select username,sid,serial#,status,machine,sql_id,cursor_current,to_char(logon_time,'dd/mm/yyyy hh24:mi:ss') logon_time,to_char(current_time,'dd/mm/yyyy hh24:mi:ss') current_time from hp_open_cursor where to_char(current_time,'dd/mm/yyyy')=to_char(sysdate,'dd/mm/yyyy') order by cursor_current;
select username,sid,serial#,status,machine,sql_id,cursor_current,to_char(logon_time,'dd/mm/yyyy hh24:mi:ss') logon_time,to_char(current_time,'dd/mm/yyyy hh24:mi:ss') current_time from hp_open_cursor where to_char(logon_time,'dd/mm/yyyy')=to_char(sysdate,'dd/mm/yyyy') order by cursor_current;