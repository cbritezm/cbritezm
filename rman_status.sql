-- ===================================================================
--
--   Script Name:  rman_backup_progress.sql
--        Author:  Robert Taylor
--        Run as:  DBA user
--
--   Description:
--   ------------
--
--   Outputs information on RMAN backups that are currently running.
--
-- ===================================================================

col dbsize_mbytes      for 99,999,990.00 justify right head "DBSIZE_MB"
col input_mbytes       for 99,999,990.00 justify right head "READ_MB"
col output_mbytes      for 99,999,990.00 justify right head "WRITTEN_MB"
col output_device_type for a10           justify left head "DEVICE"
col complete           for 990.00        justify right head "COMPLETE %"
col compression        for 990.00        justify right head "COMPRESS|% ORIG"
col est_complete       for a20           head "ESTIMATED COMPLETION"
col recid              for 9999999       head "ID"
set lines 300
--set serverout off
--set echo off
--set termout off
ALTER SESSION SET NLS_NUMERIC_CHARACTERS = ',. ';
--spool /export/home/oracle/cbritez/rman_out.txt append

prompt
prompt  ============================================================================
prompt  . Current backup session details
prompt  ============================================================================

col event for a40
col client_info for a30
column sid format 9999
column spid format 99999
column client_info format a25
column event format a30
column secs format 9999
SELECT SID, SPID, CLIENT_INFO, event, seconds_in_wait secs, p1, p2, p3,status
  FROM V$PROCESS p, V$SESSION s
  WHERE p.ADDR = s.PADDR
  and CLIENT_INFO like 'rman channel=%';

prompt
prompt  ============================================================================
prompt  . Backup progress
prompt  ============================================================================

select recid
     , output_device_type
     , to_char(dbsize_mbytes,'999G999G999D99') dbsize_mbytes
     , to_char(input_bytes/1024/1024,'999G999G999D99') input_mbytes
     , to_char(output_bytes/1024/1024,'999G999G999D99') output_mbytes
     , (mbytes_processed/dbsize_mbytes*100) complete
     , to_char(start_time + (sysdate-start_time)/(mbytes_processed/dbsize_mbytes),'DD-MON-YYYY HH24:MI:SS') est_complete
     , to_char(sysdate,'dd/mm/yyyy hh24:mi:ss') current_date
  from v$rman_status rs
     , (select sum(bytes)/1024/1024 dbsize_mbytes from v$datafile)
 where status='RUNNING'
   and output_device_type is not null
/
--spool off
exit
