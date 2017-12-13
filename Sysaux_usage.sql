# https://jhdba.wordpress.com/2009/05/19/purging-statistics-from-the-sysaux-tablespace/

--------------------------------------------------------------------------------
-- SYSAUX TABLESPACE USAGE AND PURGE	#
--------------------------------------------------------------------------------

set linesize 120
set pagesize 100
 
COLUMN "Item" FORMAT A25
COLUMN "Space Used (GB)" FORMAT 999.99
COLUMN "Schema" FORMAT A25
COLUMN "Move Procedure" FORMAT A40
 
SELECT  occupant_name "Item",
    space_usage_kbytes/1048576 "Space Used (GB)",
    schema_name "Schema",
    move_procedure "Move Procedure"
FROM v$sysaux_occupants
ORDER BY 1
/