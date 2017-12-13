-- Open cursors by max value

select max(a.value) as highest_open_cur, p.value as max_open_cur
from v$sesstat a, v$statname b, v$parameter p
where a.statistic# = b.statistic# 
and b.name = 'opened cursors current'
and p.name= 'open_cursors'
group by p.value;

-- Open cursors by users and total

break on report
compute sum label "Total:" of Cantidad ON report
select SUM(a.value) as Cantidad, s.username
from v$sesstat a, v$statname b, v$session s
where a.statistic# = b.statistic#  and s.sid=a.sid
and b.name = 'opened cursors current'
and a.value>0 and s.username IS NOT NULL
group by s.username
order by Cantidad desc;


select * from ( select ss.value, sn.name, ss.sid
 from v$sesstat ss, v$statname sn
 where ss.statistic# = sn.statistic#
 and sn.name like '%opened cursors current%'
 order by value desc) where rownum < 11 ;
 
 
 select * from ( select sum(ss.value)
 from v$sesstat ss, v$statname sn
 where ss.statistic# = sn.statistic#
 and sn.name like '%opened cursors current%'
 order by value desc) where rownum < 11 ;



 CPU USAGE
 
 
 select
   ss.username,
   se.SID,
   VALUE/100 cpu_usage_seconds
from
   v$session ss,
   v$sesstat se,
   v$statname sn
where
   se.STATISTIC# = sn.STATISTIC#
and
   NAME like '%CPU used by this session%'
and
   se.SID = ss.SID
and
   ss.status='ACTIVE'
and
   ss.username is not null
order by VALUE desc;



CURRENT OPENED CURSORS

select 	user_process username,
	"Recursive Calls",
	"Opened Cursors",
	"Current Cursors"
from  (
	select 	nvl(ss.USERNAME,'ORACLE PROC')||'('||se.sid||') ' user_process, 
			sum(decode(NAME,'recursive calls',value)) "Recursive Calls",
			sum(decode(NAME,'opened cursors cumulative',value)) "Opened Cursors",
			sum(decode(NAME,'opened cursors current',value)) "Current Cursors"
	from 	v$session ss, 
		v$sesstat se, 
		v$statname sn
	where 	se.STATISTIC# = sn.STATISTIC#
	and 	(NAME  like '%opened cursors current%'
	or 	 NAME  like '%recursive calls%'
	or 	 NAME  like '%opened cursors cumulative%')
	and 	se.SID = ss.SID
	and 	ss.USERNAME is not null
	group 	by nvl(ss.USERNAME,'ORACLE PROC')||'('||se.SID||') '
)
orasnap_user_cursors
order 	by USER_PROCESS,"Current Cursors";

set echo off;
set pagesize 500;
set feedback off;
set serverout off;
set termout off;
spool resources_usage.txt append;
break on report
compute sum label "Total:" of Cantidad ON report
select SUM(a.value) as Cantidad, s.username
from v$sesstat a, v$statname b, v$session s
where a.statistic# = b.statistic#  and s.sid=a.sid
and b.name = 'opened cursors current'
and a.value>0 and s.username IS NOT NULL
group by s.username
order by Cantidad desc;
spool off;
quit

