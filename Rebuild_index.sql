--------------------------------------------------------------------------------
-- Rebuild index
--------------------------------------------------------------------------------
set heading off
set lines 200
spool rebuild_index.sql
SELECT 'ALTER INDEX '||OWNER||'.'||INDEX_NAME|| ' REBUILD TABLESPACE MSTRMETAIDX;' FROM DBA_INDEXES WHERE TABLESPACE_NAME = 'MSTRMETADAT';
spool off
quit

