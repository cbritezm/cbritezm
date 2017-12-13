--------------------------------------------------------------------------------
-- Current users command name
--------------------------------------------------------------------------------

select username,sid,serial#,event,to_char(logon_time,'dd/mm/yyyy hh24:mi:ss') logon_time,sql_id,status,
decode(command,
  1,'Create table' , 2,'Insert',
  3,'Select' , 6,'Update',
  7,'Delete' , 9,'Create index',
  10,'Drop index' ,11,'Alter index',
  12,'Drop table' ,13,'Create seq',
  14,'Alter sequence' ,15,'Alter table',
  16,'Drop sequ.' ,17,'Grant',
  19,'Create syn.' ,20,'Drop synonym',
  21,'Create view' ,22,'Drop view',
  23,'Validate index' ,24,'Create procedure',
  25,'Alter procedure' ,26,'Lock table',
  42,'Alter session' ,44,'Commit',
  45,'Rollback' ,46,'Savepoint',
  47,'PL/SQL Exec' ,48,'Set Transaction',
  60,'Alter trigger' ,62,'Analyze Table',
  63,'Analyze index' ,71,'Create Snapshot Log',
  72,'Alter Snapshot Log' ,73,'Drop Snapshot Log',
  74,'Create Snapshot' ,75,'Alter Snapshot',
  76,'drop Snapshot' ,85,'Truncate table',
  0,'No command', '? : '||command) operation
from v$session where username is not null;
