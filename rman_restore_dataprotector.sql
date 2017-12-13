run {
 allocate  channel 'dev_0' type 'sbt_tape' parms 'SBT_LIBRARY=/opt/omni/lib/libob2oracle8_64bit.so,ENV=(OB2BARTYPE=Oracle8,OB2APPNAME=remdox0,OB2BARLIST=USGD_ACR_GENCAT_lremdox2_ORA_REMDOX0_ARC<REMDOX0_21901:935961559:1>.dbf)';
  allocate  channel 'dev_1' type 'sbt_tape' parms 'SBT_LIBRARY=/opt/omni/lib/libob2oracle8_64bit.so,ENV=(OB2BARTYPE=Oracle8,OB2APPNAME=remdox0,OB2BARLIST=USGD_ACR_GENCAT_lremdox2_ORA_REMDOX0_ARC<REMDOX0_21901:935961559:1>.dbf)';
  allocate  channel 'dev_2' type 'sbt_tape' parms 'SBT_LIBRARY=/opt/omni/lib/libob2oracle8_64bit.so,ENV=(OB2BARTYPE=Oracle8,OB2APPNAME=remdox0,OB2BARLIST=USGD_ACR_GENCAT_lremdox2_ORA_REMDOX0_ARC<REMDOX0_21901:935961559:1>.dbf)';
  allocate  channel 'dev_3' type 'sbt_tape' parms 'SBT_LIBRARY=/opt/omni/lib/libob2oracle8_64bit.so,ENV=(OB2BARTYPE=Oracle8,OB2APPNAME=remdox0,OB2BARLIST=USGD_ACR_GENCAT_lremdox2_ORA_REMDOX0_ARC<REMDOX0_21901:935961559:1>.dbf)';

SET UNTIL TIME "to_date('14/02/2017 21:20:36', 'dd/mm/yyyy hh24:mi:ss')";
restore database;
recover database;
}

rman nocatalog target=/ cmdfile=/home/oracle/cbritez/rman/restore_rman.rcv log=/home/oracle/cbritez/rman/log_restore.txt
