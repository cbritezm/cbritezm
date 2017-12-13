RMAN 11GR2 : DUPLICATE Without Target And Recovery Catalog Connection (Doc ID 874352.1)
RMAN 'Duplicate From Active Database' Feature in 11G (Doc ID 452868.1)
Creating a Duplicate Database on a New Host (non ASM). (Doc ID 388431.1)

RUN
{   
  ALLOCATE AUXILIARY CHANNEL A1 DEVICE TYPE disk;
  DUPLICATE TARGET DATABASE TO orclv2
  LOGFILE
    GROUP 1 ('/u01/app/oracle/oradata/orclv2/redo01.log') SIZE 50M,
    GROUP 2 ('/u01/app/oracle/oradata/orclv2/redo02.log') SIZE 50M,
    GROUP 3 ('/u01/app/oracle/oradata/orclv2/redo03.log') SIZE 50M;
}


RUN
{  
  ALLOCATE AUXILIARY CHANNEL newdb DEVICE TYPE sbt; 
  DUPLICATE TARGET DATABASE TO newdb
    PFILE ?/dbs/initNEWDB.ora
    UNTIL TIME 'SYSDATE-1'  # specifies incomplete recovery
    SKIP TABLESPACE example, history   # skip desired tablespaces
    DB_FILE_NAME_CONVERT ('/h1/oracle/dbs/trgt/','/h2/oracle/oradata/newdb/')
    LOGFILE
      GROUP 1 ('/h2/oradata/newdb/redo01_1.f',
               '/h2/oradata/newdb/redo01_2.f') SIZE 4M,
      GROUP 2 ('/h2/oradata/newdb/redo02_1.f',
               '/h2/oradata/newdb/redo02_2.f') SIZE 4M,
      GROUP 3 ('/h2/oradata/newdb/redo03_1.f',
               '/h2/oradata/newdb/redo03_2.f') SIZE 4M REUSE;
}


mkdir -p /opt/oracle/admin/sntprev2/adump
mkdir -p /opt/oracle/diag/rdbms/sntprev2/SNTPREV2/trace
mkdir -p /bdd/SNTPREV2/control/
mkdir -p /opt/oracle/admin/sntprev2/cdump
mkdir -p /opt/oracle/diag/rdbms/sntprev2/SNTPREV2/trace
mkdir -p /opt/oracle/admin/sntprev2/scripts/log/


set DBID=1702764890;
run {

allocate channel 'dev_0' type 'sbt_tape'
parms 'SBT_LIBRARY=/opt/omni/lib/libob2oracle8_64bit.so,ENV=(OB2BARTYPE=Oracle8,OB2APPNAME=RACC,OB2BARLIST=USGD_ACR_RACC_rcbcnoradwh01p_ORA_RACC_ARC<RACC_15738:891702109:1>.dbf)';

restore controlfile from 'USGD_ACR_RACC_rcbcnoradwh01p_ORA_RACC_ARC<RACC_15738:891702109:1>.dbf';

}


run {

allocate channel 'dev_0' type 'sbt_tape'
parms 'SBT_LIBRARY=/opt/omni/lib/libob2oracle8_64bit.so,ENV=(OB2BARTYPE=Oracle8,OB2APPNAME=RACC,OB2BARLIST= USGD_ACR_RACC_rcbcnoradwh01p_ORA_RACC_ARC<RACC_15737:891702083:1>.dbf)';

allocate channel 'dev_1' type 'sbt_tape'
parms 'SBT_LIBRARY=/opt/omni/lib/libob2oracle8_64bit.so,ENV=(OB2BARTYPE=Oracle8,OB2APPNAME=RACC,OB2BARLIST= USGD_ACR_RACC_rcbcnoradwh01p_ORA_RACC_ARC<RACC_15737:891702083:1>.dbf)';

allocate channel 'dev_2' type 'sbt_tape'
parms 'SBT_LIBRARY=/opt/omni/lib/libob2oracle8_64bit.so,ENV=(OB2BARTYPE=Oracle8,OB2APPNAME=RACC,OB2BARLIST= USGD_ACR_RACC_rcbcnoradwh01p_ORA_RACC_ARC<RACC_15737:891702083:1>.dbf)';

set until logseq 45404;

duplicate target database to "RACC2"
logfile
	group 1 ('/bdd/RACC/redo/redo01.log','/bdd/RACCP/RACC2/redo/redo01.log') size 50M,
	group 2 ('/bdd/RACC/redo/redo02.log','/bdd/RACCP/RACC2/redo/redo02.log') size 50M,
	group 3 ('/bdd/RACC/redo/redo03.log','/bdd/RACCP/RACC2/redo/redo03.log') size 50M;
	group 4 ('/bdd/RACC/redo/redo04.log','/bdd/RACCP/RACC2/redo/redo04.log') size 50M;

}

