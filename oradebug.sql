--	#######################################################
--		get the Oracle session ID and Find the OS process id for the session that is stuck: 
--	########################################################
select p.spid "ProcessID" 
from v$process p,v$session s 
where s.paddr = p.addr and s.sid=&Hanged_Oracle_Session_ID; 

sqlplus / as sysdba 
oradebug setospid XXXXX (This is the ProcessID from the previous SQL) 
oradebug unlimit 
oradebug dump errorstack 3 
--wait for 30 seconds 

oradebug dump errorstack 3 
--wait for 30 seconds 

oradebug dump errorstack 3 
--wait for 30 seconds 

oradebug dump errorstack 3 
--wait for 30 seconds 

oradebug dump errorstack 3 

oradebug tracefile_name 
