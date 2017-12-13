
SELECT DBMS_METADATA.GET_GRANTED_DDL('ROLE_GRANT','LEERAF') FROM DUAL;
SELECT DBMS_METADATA.GET_GRANTED_DDL('SYSTEM_GRANT','LEERAF') FROM DUAL;
SELECT DBMS_METADATA.GET_GRANTED_DDL('OBJECT_GRANT','LEERAF') FROM DUAL;

ROLE SYSTEM PRIVILEGES
-----------------------

SELECT role,privilege from 
role_sys_privs 
where role IN ('AUT_ROLE','CIR_ROLE','FNC_ROLE','RAF_ROLE','REM_ROLE','STW_ROLE','ERACC_ROLE','LECTURA_ROLE')

ROLE PRIVILEGES ON TABLES/PROCEDURES
------------------------------------

select role,owner,table_name,privilege 
from role_tab_privs  
where role IN ('AUT_ROLE','CIR_ROLE','FNC_ROLE','RAF_ROLE','REM_ROLE','STW_ROLE','ERACC_ROLE','LECTURA_ROLE') and owner='ADMIN_ASS';
IN ('LEERAF','AUT_ROLE','CIR_ROLE','FNC_ROLE','RAF_ROLE','REM_ROLE','STW_ROLE','ERACC_ROLE','LECTURA_ROLE') and table_schema='ADMIN_ASS';


LEERAF                         ADMIN_CIR                      CIR_TIPO_OBJ_DATOS_OBJETO      EXECUTE
LEERAF                         ADMIN_CIR                      CIR_TIPO_OBJ_DATOS_OBJETO      DEBUG
LEERAF                         ADMIN_CIR                      CIR_TIPO_OBJ_CABECERA_LOTE     EXECUTE



ROLES PRIVILEGES
-----------------------

SELECT GRANTEE,GRANTED_ROLE 
FROM dba_role_privs 
WHERE GRANTEE IN ('IMMANNAV','PETESANT','JEROFAJA') 
GROUP BY GRANTEE,GRANTED_ROLE;



