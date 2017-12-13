#!/bin/bash
. ~/entorn_e13bd01
sqlplus -s system/hpinvent01 <<EOF
 alter session set current_schema=SAGA_CENTRAL;
 select sys_context( 'userenv', 'current_schema' )as "Current USER" from dual;
 @/home/oracle/tiquets/TAS000000014616/refresc.sql;
EOF

exit;
