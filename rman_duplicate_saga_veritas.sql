run {
  allocate auxiliary channel cinta1 device type sbt_tape;
  send 'NB_ORA_CLIENT=racsaga1.admin,NB_ORA_POLICY=oracle_agents';

  set until time "TO_DATE('13/11/2015 12:55:00','dd/mm/yyyy hh24:mi:ss')";
  SET NEWNAME FOR TEMPFILE 1 TO '/mnt/temporal/saga/datos/oradata/temp01.dbf';
  SET NEWNAME FOR TEMPFILE 2 TO '/mnt/temporal/saga/datos/oradata/temp02.dbf';
  duplicate target database to "SAGA"
  DB_FILE_NAME_CONVERT '+DG_SAGA_DADES','/mnt/temporal/saga/datos/oradata';
  LOGFILE
    GROUP 1 ('/mnt/temporal/saga/datos/onlinelog/REDO_G01_M01.rdo') SIZE 150M,
    GROUP 2 ('/mnt/temporal/saga/datos/onlinelog/REDO_G02_M01.rdo') SIZE 150M;

  release channel cinta1;
}
