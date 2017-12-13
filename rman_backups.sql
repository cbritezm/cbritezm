
#-------------------------------------------#
#											#
#	RMAN BACKUP ARCHIVELOG WITH CATALOG		#
#											#
#-------------------------------------------#

rman rcvcat rman/rman@rmancat
connect target;

run {
  allocate channel D1 type disk format '/BACKUP/$JTSTCRN/brman_%d_arch_%s' ;
  backup archivelog all delete input;
  release channel D1;
}

#-------------------------------------------#
#											#
#	RMAN BACKUP ARCHIVELOG FROM SEQUENCE	#
#											#
#-------------------------------------------#

run {
  allocate channel D1 type disk format '/BACKUP/JTSTCRN/brman_%d_arch_%s' ;
  backup archivelog from sequence  38000 until sequence 38050 thread 1 ;
  release channel D1;
}

#-------------------------------------------#
#											#
#	RMAN BACKUP ARCHIVELOG DELETE INPUT		#
#											#
#-------------------------------------------#

run {
  allocate channel D1 type disk format '/BACKUP/JTSTCRN/brman_%d_arch_%s' ;
  backup archivelog all skip inaccessible delete input;
  release channel D1;
}

#-------------------------------------------#
#											#
#	RMAN DELETE ARCHIVELOG FROM SEQUENCE	#
#											#
#-------------------------------------------#


DELETE NOPROMPT ARCHIVELOG from sequence  38050 until sequence 38720 thread 1;


#-------------------------------------------#
#											#
#	RMAN BACKUP ARCHIVELOG AND BACKUPSET	#
#											#
#-------------------------------------------#


rman rcvcat rman/rman@rmancat 
connect target sys/purecitos2012@JTSTCRN;

run {
  allocate channel D1 type disk rate 10M
  ;
  sql 'alter system archive log current';
  backup as compressed backupset
    full
    filesperset 10
    format '/BACKUP/JTSTCRN/brman_%d_db_%s'
    (database)
    ;
  backup as compressed backupset
    filesperset 50
    format '/BACKUP/JTSTCRN/brman_%d_arch_%s'
    (archivelog all skip inaccessible delete input)
    ;
  release channel D1
  ;
}

#-------------------------------------------#
#											#
#			RMAN SELECT WORK STATUS			#
#											#
#-------------------------------------------#

select sid,start_time,totalwork sofar,(sofar/totalwork) * 100 pct_done
from
   v$session_longops
where
   totalwork > sofar
AND
   opname NOT LIKE '%aggregate%'
AND
   opname like 'RMAN%';

select
   sid,
   spid,
   client_info,
   event,
   seconds_in_wait,
   p1, p2, p3
 from
   v$process p,
   v$session s
 where
   p.addr = s.paddr
 and
   client_info like 'rman channel=%';

