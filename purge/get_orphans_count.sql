set heading off
set echo off
set timing off
set time off
set feedback 0
set verify OFF
set pagesize 0
SELECT (x.latch+y.sysstat+z.parameter+w.sqlcount) qty
from
(SELECT count(*) latch from  sys.WRH$_LATCH a WHERE NOT EXISTS (SELECT 1 FROM sys.wrm$_snapshot b WHERE b.snap_id = a.snap_id AND dbid=(SELECT dbid FROM v$database)
AND b.dbid = a.dbid AND b.instance_number = a.instance_number)) x,
(SELECT count(*) sysstat FROM sys.WRH$_SYSSTAT a WHERE NOT EXISTS (SELECT 1 FROM sys.wrm$_snapshot b WHERE b.snap_id = a.snap_id AND dbid=(SELECT dbid FROM v$database)
AND b.dbid = a.dbid AND b.instance_number = a.instance_number)) y,
(SELECT count(*) parameter FROM sys.WRH$_PARAMETER a WHERE NOT EXISTS (SELECT 1 FROM sys.wrm$_snapshot b WHERE b.snap_id = a.snap_id AND dbid=(SELECT dbid FROM v$database)
AND b.dbid = a.dbid AND b.instance_number = a.instance_number))z,
(SELECT count(*) sqlcount from wrh$_sql_plan where trunc(TIMESTAMP) < (select min(BEGIN_INTERVAL_TIME) from dba_hist_snapshot)) w;
exit
