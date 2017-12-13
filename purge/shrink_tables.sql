set serveroutput on;
set feedback off

declare
	v_latch integer(10);
	v_sysstat integer(10);
	v_parameter integer(10);
	v_sqlplan integer(10);
begin
	DBMS_OUTPUT.ENABLE (buffer_size => NULL);

	SELECT count(*) into v_latch from  sys.WRH$_LATCH a WHERE NOT EXISTS 
	(SELECT 1 FROM sys.wrm$_snapshot b WHERE b.snap_id = a.snap_id AND dbid=(SELECT dbid FROM v$database) 
	AND b.dbid = a.dbid AND b.instance_number = a.instance_number);

	SELECT count(*) into v_sysstat FROM sys.WRH$_SYSSTAT a WHERE NOT EXISTS
		(SELECT 1 FROM sys.wrm$_snapshot b WHERE b.snap_id = a.snap_id AND dbid=(SELECT dbid FROM v$database)
		AND b.dbid = a.dbid AND b.instance_number = a.instance_number);

	SELECT count(*) into v_parameter FROM sys.WRH$_PARAMETER a WHERE NOT EXISTS
		(SELECT 1 FROM sys.wrm$_snapshot b WHERE b.snap_id = a.snap_id AND dbid=(SELECT dbid FROM v$database)
		AND b.dbid = a.dbid AND b.instance_number = a.instance_number);

	SELECT count(*) into v_sqlplan from wrh$_sql_plan 
		WHERE trunc(TIMESTAMP) < (select min(BEGIN_INTERVAL_TIME) from dba_hist_snapshot);

	IF v_latch = 0 THEN

		execute immediate 'ALTER TABLE sys.WRH$_LATCH ENABLE ROW MOVEMENT';
		execute immediate 'ALTER TABLE sys.WRH$_LATCH shrink space';
		dbms_output.put_line('		DONE SHRINK TABLE sys.WRH$_LATCH');

	END IF;

	IF v_sysstat = 0 THEN

		execute immediate 'ALTER TABLE sys.WRH$_SYSSTAT ENABLE ROW MOVEMENT';
                execute immediate 'ALTER TABLE sys.WRH$_SYSSTAT shrink space';
		dbms_output.put_line('		DONE SHRINK TABLE sys.WRH$_SYSSTAT');

        END IF;

	IF v_parameter = 0 THEN

		execute immediate 'ALTER TABLE sys.WRH$_PARAMETER ENABLE ROW MOVEMENT';
                execute immediate 'ALTER TABLE sys.WRH$_PARAMETER shrink space';
		dbms_output.put_line('		DONE SHRINK TABLE sys.WRH$_PARAMETER');

        END IF;

	IF v_sqlplan = 0 THEN

                execute immediate 'ALTER TABLE sys.WRH$_SQL_PLAN ENABLE ROW MOVEMENT';
                execute immediate 'ALTER TABLE sys.WRH$_SQL_PLAN shrink space';
		dbms_output.put_line('		DONE SHRINK TABLE sys.WRH$_SQL_PLAN');

	END IF;

end;
/
exit
