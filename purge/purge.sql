set serveroutput on;
set feedback off;
declare
	v_latch integer(10);
	v_sysstat integer(10);
	v_parameter integer(10);
	v_sqlplan integer(10);
	v_rowcount integer(10);
	v_qty integer(10) :=0;
begin
	DBMS_OUTPUT.ENABLE (buffer_size => NULL);
	/*  **************************************************************************************
	 				GET ORPHAN ROWS QUANTITY			       
	************************************************************************************** */

	SELECT count(*) into v_latch from  sys.WRH$_LATCH a 
		WHERE NOT EXISTS 
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

	SELECT count(*) into v_sqlplan FROM wrh$_sql_plan 
		WHERE trunc(TIMESTAMP) < (SELECT min(BEGIN_INTERVAL_TIME) FROM dba_hist_snapshot);

	/*  **************************************************************************************
                                      STARTING DELETE  
		RUNNING SIX TIMES AND DELETING 500000 ROWS PER EXECUTION
        ************************************************************************************** */

	IF v_latch > 0 THEN
		dbms_output.put_line('		Deleting '||v_latch||' records from sys.WRH$_LATCH');
		FOR i IN 1..6 LOOP
			DELETE FROM sys.WRH$_LATCH a WHERE NOT EXISTS
                        	(SELECT 1 FROM sys.wrm$_snapshot b WHERE b.snap_id = a.snap_id AND dbid=(SELECT dbid FROM v$database)
                        	AND b.dbid = a.dbid AND b.instance_number = a.instance_number) AND ROWNUM< 500001;
			v_rowcount := SQL%ROWCOUNT;	
			IF v_rowcount >0 THEN
				commit;
				v_qty := v_qty + v_rowcount;
			END IF;
			EXIT WHEN v_rowcount=0;
		END LOOP;
				dbms_output.put_line('			Deleted '||v_qty||' records from sys.WRH$_LATCH');
				v_qty :=0;
	END IF;

	IF v_sysstat > 0 THEN
		dbms_output.put_line('		Deleting '||v_sysstat||' records from sys.WRH$_SYSSTAT');

                FOR i IN 1..6 LOOP
                       DELETE FROM sys.WRH$_SYSSTAT a WHERE NOT EXISTS
                        (SELECT 1 FROM sys.wrm$_snapshot b WHERE b.snap_id = a.snap_id AND dbid=(SELECT dbid FROM v$database)
                        AND b.dbid = a.dbid AND b.instance_number = a.instance_number) AND ROWNUM< 500001;

			v_rowcount := SQL%ROWCOUNT;

                        IF v_rowcount >0 THEN
                                commit;
				v_qty := v_qty + v_rowcount;
                        END IF;
                        EXIT WHEN v_rowcount=0;
                END LOOP;
			dbms_output.put_line('			Deleted '||v_qty||' records from sys.WRH$_SYSSTAT');
			v_qty :=0;

        END IF;

	IF v_parameter > 0 THEN
		dbms_output.put_line('		Deleting '||v_parameter||' records from sys.WRH$_PARAMETER');
                FOR i IN 1..6 LOOP
                       DELETE FROM sys.WRH$_PARAMETER a WHERE NOT EXISTS
                        (SELECT 1 FROM sys.wrm$_snapshot b WHERE b.snap_id = a.snap_id AND dbid=(SELECT dbid FROM v$database)
                        AND b.dbid = a.dbid AND b.instance_number = a.instance_number) AND ROWNUM< 500001;

			v_rowcount := SQL%ROWCOUNT;
                        IF v_rowcount >0 THEN
                                commit;
				v_qty := v_qty + v_rowcount;
                        END IF;
                        EXIT WHEN v_rowcount=0;
                END LOOP;
			dbms_output.put_line('	               	Deleted '||v_qty||' records from sys.WRH$_PARAMETER');
			v_qty :=0;

        END IF;

	IF v_sqlplan > 0 THEN
                dbms_output.put_line('		Deleting '||v_sqlplan||' records from sys.WRH$_SQL_PLAN');
                FOR i IN 1..6 LOOP
                       	DELETE from wrh$_sql_plan 
			WHERE (trunc(TIMESTAMP) < (SELECT min(BEGIN_INTERVAL_TIME) FROM dba_hist_snapshot)) AND ROWNUM< 500001; 

			v_rowcount := SQL%ROWCOUNT;
                        IF v_rowcount >0 THEN
                                commit;
				v_qty := v_qty + v_rowcount;
                        END IF;
                        EXIT WHEN v_rowcount=0;
                END LOOP;
			dbms_output.put_line(' 	               	Deleted '||v_qty||' records from sys.WRH$_SQL_PLAN');
			v_qty :=0;
        END IF;

end;
/
exit
