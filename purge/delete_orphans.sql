set serveroutput on;

declare
	v_latch integer(10);
	v_sysstat integer(10);
	v_parameter integer(10);
begin
	DBMS_OUTPUT.ENABLE (buffer_size => NULL);

	SELECT count(*) into v_latch from  sys.WRH$_LATCH a WHERE NOT EXISTS 
	(SELECT 1 FROM sys.wrm$_snapshot b WHERE b.snap_id = a.snap_id AND dbid=(SELECT dbid FROM v$database) 
	AND b.dbid = a.dbid AND b.instance_number = a.instance_number);

	SELECT count(*) into v_sysstat FROM sys.WRH$_SYSSTAT a
		WHERE NOT EXISTS
		(SELECT 1 FROM sys.wrm$_snapshot b WHERE b.snap_id = a.snap_id AND dbid=(SELECT dbid FROM v$database)
		AND b.dbid = a.dbid AND b.instance_number = a.instance_number);

	SELECT count(*) into v_parameter FROM sys.WRH$_PARAMETER a
		WHERE NOT EXISTS
		(SELECT 1 FROM sys.wrm$_snapshot b WHERE b.snap_id = a.snap_id AND dbid=(SELECT dbid FROM v$database)
		AND b.dbid = a.dbid AND b.instance_number = a.instance_number);

	--dbms_output.put_line('SYSAUX TOTAL: '||v_total||'(MB), USED SPACE: '||v_used||'(MB) FREE: '||v_free||'(MB)');
	--dbms_output.put_line('LATCH: '||v_latch);
	--dbms_output.put_line('SYSSTAT: '||v_sysstat);
	--dbms_output.put_line('PARAMETER: '||v_parameter);

	IF v_latch > 0 THEN
		dbms_output.put_line('PURGING '||v_latch||' RECORDS IN sys.WRH$_LATCH');
		LOOP
			DELETE FROM sys.WRH$_LATCH a WHERE NOT EXISTS
			(SELECT 1 FROM sys.wrm$_snapshot b WHERE b.snap_id = a.snap_id AND dbid=(SELECT dbid FROM v$database) 
			AND b.dbid = a.dbid AND b.instance_number = a.instance_number) 
			AND ROWNUM< 500001; 
			EXIT WHEN SQL%ROWCOUNT = 0;
			commit;
		END LOOP;
		execute immediate 'ALTER TABLE sys.WRH$_LATCH ENABLE ROW MOVEMENT';
		execute immediate 'ALTER TABLE sys.WRH$_LATCH shrink space';
	END IF;
	IF v_sysstat > 0 THEN
		dbms_output.put_line('PURGING '||v_sysstat||' RECORDS IN sys.WRH$_SYSSTAT');
		LOOP
			DELETE FROM sys.WRH$_SYSSTAT a WHERE NOT EXISTS
			(SELECT 1 FROM sys.wrm$_snapshot b WHERE b.snap_id = a.snap_id AND dbid=(SELECT dbid FROM v$database)
			AND b.dbid = a.dbid AND b.instance_number = a.instance_number) AND ROWNUM< 500001;
			EXIT WHEN SQL%ROWCOUNT = 0;
                        commit;
                END LOOP;
		execute immediate 'ALTER TABLE sys.WRH$_SYSSTAT ENABLE ROW MOVEMENT';
                execute immediate 'ALTER TABLE sys.WRH$_SYSSTAT shrink space';

        END IF;
	IF v_parameter > 0 THEN
		dbms_output.put_line('PURGING '||v_parameter||' RECORDS IN sys.WRH$_PARAMETER');
		LOOP
			DELETE FROM sys.WRH$_PARAMETER a WHERE NOT EXISTS
			(SELECT 1 FROM sys.wrm$_snapshot b WHERE b.snap_id = a.snap_id AND dbid=(SELECT dbid FROM v$database)
			AND b.dbid = a.dbid AND b.instance_number = a.instance_number) AND ROWNUM< 500001;
			EXIT WHEN SQL%ROWCOUNT = 0;
                        commit;
                END LOOP;
		execute immediate 'ALTER TABLE sys.WRH$_PARAMETER ENABLE ROW MOVEMENT';
                execute immediate 'ALTER TABLE sys.WRH$_PARAMETER shrink space';

        END IF;
end;
/

