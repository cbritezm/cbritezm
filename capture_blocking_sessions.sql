--------------------------------------------------------------------------------
--      Load blocking sessions to table
--------------------------------------------------------------------------------

CREATE TABLE HP_SESSION (
	CANTIDAD NUMBER,
	HOSTNAME VARCHAR2(64),
	USERNAME VARCHAR2(30),
	INST_ID number,
	
	)
	tablespace HP_INTERNAL;
	
CREATE TABLE HP_BLKSESSION (
	SID number,
	USERNAME VARCHAR2(30),
	INST_ID number,
	SQL_ID VARCHAR2(13),
	BLOCKING_INSTANCE NUMBER,
	BLOCKING_SESSION  NUMBER,
	EVENT VARCHAR2(64),
	LOGON_TIME DATE,
	STATUS varchar2(8)
)
	
CREATE TABLE HP_RESOURCE (
	INST_ID number,
	RESOURCE_NAME VARCHAR2(30),
	CURRENT_UTILIZATION number,
	LIMIT_VALUE number
)
tablespace HP_INTERNAL;
	
CREATE OR REPLACE PROCEDURE HP_PRCBLKSESSION
IS
BEGIN
	INSERT INTO HP_BLKSESSION(SID,USERNAME,INST_ID,SQL_ID,BLOCKING_INSTANCE,BLOCKING_SESSION,EVENT,LOGON_TIME,STATUS)
    SELECT  SID,USERNAME,INST_ID,SQL_ID,BLOCKING_INSTANCE,BLOCKING_SESSION,EVENT,LOGON_TIME,status FROM GV$SESSION where username like 'SAGA%' and blocking_session is not null;
	commit;
END;
/

CREATE OR REPLACE PROCEDURE HP_PROCEDURE
IS
BEGIN
	INSERT INTO HP_SESSION (CANTIDAD,HOSTNAME,USERNAME,INST_ID) 
	SELECT COUNT(*),MACHINE,USERNAME,INST_ID FROM GV$SESSION where username is not null group by machine,username,inst_id ;
	INSERT INTO HP_RESOURCE (INST_ID,RESOURCE_NAME,CURRENT_UTILIZATION,LIMIT_VALUE) 
	SELECT INST_ID,RESOURCE_NAME,CURRENT_UTILIZATION,LIMIT_VALUE FROM GV$RESOURCE_LIMIT where resource_name in ('processes','sessions','enqueue_locks');
	commit;
END;
/

BEGIN 
   dbms_scheduler.create_job ( 
    job_name => 'HP_JOB_BLKSESSION', 
    job_type => 'PLSQL_BLOCK', 
    job_action => 'HP_PRCBLKSESSION', 
    start_date => SYSTIMESTAMP, 
    enabled => true, 
    repeat_interval => 'FREQ=MINUTELY;INTERVAL=15',
	end_date  => SYSTIMESTAMP + 7
   ); 
END;
/
