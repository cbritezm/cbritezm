create pfile='/home/oracle/pfile_before_Audit.ora' from spfile;

-- [ Sentence for create ts_audit tablespace - Verify capacity ] --
select 'CREATE TABLESPACE TS_AUDIT DATAFILE '''||SUBSTR(FILE_NAME,1,instr(FILE_NAME,'/',1,REGEXP_COUNT(FILE_NAME,'/',1,'i')))||'ts_audit_01.dbf'' SIZE 1G AUTOEXTEND OFF LOGGING ONLINE PERMANENT BLOCKSIZE 8192 EXTENT MANAGEMENT LOCAL AUTOALLOCATE DEFAULT NOCOMPRESS SEGMENT SPACE MANAGEMENT AUTO;' tbs_create from dba_data_files where tablespace_name='SYSAUX'; 

-- Change trail location, if it's ncessary.
BEGIN
  DBMS_AUDIT_MGMT.set_audit_trail_location(
    audit_trail_type           => DBMS_AUDIT_MGMT.AUDIT_TRAIL_DB_STD,
    audit_trail_location_value => 'TS_AUDIT');
END;
/

-- Verify if the audit location was changed.

SELECT table_name, tablespace_name FROM   dba_tables WHERE  table_name IN ('AUD$', 'FGA_LOG$') ORDER BY table_name;

-- Enable audit

ALTER SYSTEM SET AUDIT_TRAIL=DB,EXTENDED SCOPE=SPFILE;

-- Enable audit after bounce the db.
AUDIT SESSION;

