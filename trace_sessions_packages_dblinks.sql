Trace session with logon trigger
--------------------------------

create trigger trace_SAGA_NODE
after logon on SAGA_NODE.schema
begin
 execute immediate 'alter session set events ''10046 trace name context forever, level 12''';
 execute immediate 'alter session force parallel query';
end;
/

drop trigger trace_SAGA_NODE;
drop trigger trace_SAGAN1;



--TRACE PACKAGE WITH DB LINK



	How To Trace A Dblink (Database Link) Activity (On Local And Remote Sides) (Doc ID 422455.1)


--# CREATE TABLE FOR LOGS

	CREATE TABLE HPLOG(momento timestamp,mensaje varchar(500));

--# CREATE PROCEDURE TO INSERT DATA TO TABLE LOGON

	PROCEDURE debug (p_texto IN VARCHAR2) IS
	  PRAGMA AUTONOMOUS_TRANSACTION;
	BEGIN
	  INSERT INTO hplog (MOMENTO,LOG)
	  VALUES (SYSTIMESTAMP, p_texto);
	  COMMIT;
	END;

--# CREATE TEST PROCEDURE

	CREATE OR REPLACE PACKAGE pkg_importacioBOPersonalHP IS

		PROCEDURE test_trace;

	END;
	/

	CREATE OR REPLACE PACKAGE BODY pkg_importacioBOPersonalHP IS

	PROCEDURE debug (p_texto IN VARCHAR2) IS
	  PRAGMA AUTONOMOUS_TRANSACTION;
	BEGIN
	  INSERT INTO hplog (MOMENTO,LOG)
	  VALUES (SYSTIMESTAMP, p_texto);
	  COMMIT;
	END;

	PROCEDURE test_trace IS
	  v_foo BINARY_INTEGER;
	  v_sid BINARY_INTEGER;
	  v_texto VARCHAR2(500);
	  V_TIME timestamp;
	  v_time2 timestamp;
	BEGIN
	  SELECT SID into v_sid FROM V$MYSTAT WHERE ROWNUM=1;
	  SELECT INSTANCE_NUMBER INTO v_texto FROM V$INSTANCE;
	  debug('Comienzo, soy sesión '||v_sid||' en la instancia local '||v_texto);

	  SELECT SID into v_sid FROM V$MYSTAT@XTEC WHERE ROWNUM=1;
	  SELECT INSTANCE_NUMBER INTO v_texto FROM V$INSTANCE@XTEC;
	  debug('El database link ha establecido conexión con la instancia remota '||v_texto||' con sid '||v_sid);

	  debug('Activo trazas');
	  v_time:=SYSTIMESTAMP;
	  execute immediate 'alter session set TRACEFILE_IDENTIFIER = ''LOCAL_SESSION'' '; 
	  execute immediate 'alter session set max_dump_file_size=''6144M'''; 
	  execute immediate 'alter session set statistics_level=ALL';
	  execute immediate 'alter session set events ''10046 trace name context forever, level 12'' '; 
	  set_trace@xtec;
	  v_time2:=SYSTIMESTAMP;
	  debug('ha tardado '||to_char(v_time2-v_time));
	  select 123 into v_foo from dual@xtec;
	  debug('Query interna');
	  select 456 into v_foo from dual;
	  debug('Finalizo');
	END;

END;
/
EXEC pkg_importacioBOPersonalHP.TEST_TRACE;