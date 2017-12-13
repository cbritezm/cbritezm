--------------------------------------------------------------------------------
-- FS usage EM
--------------------------------------------------------------------------------

set lines 200;
col hostname format a38;
col fs_type format a8;
col filesystem format a38;
col mountpoint format a30;

SELECT target_name as Hostname,filesystem_type as "Fs_type",filesystem as Filesystem, mountpoint as Mountpoint,round((sizeb/1073741824)) as "Size_GB", round((usedb/1073741824),1) as "Used_GB",round((freeb/1048576)) as "Free_MB"
from MGMT$STORAGE_REPORT_LOCALFS
WHERE round((freeb/1048576))<=300 AND filesystem NOT LIKE '%.iso' AND mountpoint NOT IN('/boot');
exit;
