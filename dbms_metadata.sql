--------------------------------------------------------------------------------
-- dbms_metadata
--------------------------------------------------------------------------------

set long 1000000 longc 32000 lin 32000 trims on hea off pages 0 newp none emb on tab off feed off echo off verify off
accept obj_name prompt 'Object name:';
accept obj_type prompt 'Object type:';
accept obj_owner prompt 'Object owner:';
exec DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'SQLTERMINATOR',true);
spool bkp_&obj_type._&obj_name..sql;
SELECT DBMS_METADATA.GET_DDL(upper('&obj_type'),upper('&obj_name'),upper('&obj_owner')) from dual;
spool off
exit
