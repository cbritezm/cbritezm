--------------------------------------------------------------------------------
-- dba dependencies
--------------------------------------------------------------------------------

SElect owner,name,type,dependency_type,referenced_name,referenced_type,referenced_owner,referenced_link_name
from dba_dependencies 
where owner='E13_FDC' AND name=upper('FDC_V_CENTRE_DADES') and referenced_owner='SAGA_CENTRAL'
/
