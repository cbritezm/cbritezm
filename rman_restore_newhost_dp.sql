SET UNTIL SCN  12936910169152

Find out where the files should be placed:

select name from v$tempfile
union
select member from v$logfile
union
select name from v$datafile
union
select name from v$controlfile;


Create directories for the database files (these ones already with the new db name):

Create a temporary pfile for the new database (use the old DEVDB-pfile e.g.).

Make a list of all the datafiles of DEVDB, and where these files should be on ELLISON.
You may use something like this:

+++++++++++++++++++++++++++++++++++++++++++
select 'set newname for datafile '||file#||' to "'||replace(name,'/bdd/REMDOX0/datos/','/BKP_DUP/REMDOXDUP/REMDOX0_DATA/')||'";'
from v$datafile where name like '%/bdd/REMDOX0/datos/%'
union all
select 'set newname for datafile '||file#||' to "'||replace(name,'/bdd/REMDOX0/datos/','/BKP_DUP/REMDOXDUP/REMDOX0_DATA/')||'";'
from v$datafile where name not like '%/bdd/REMDOX0/datos/%';

select 'sql "alter database rename file '''''||member||''''' to '''''||replace(member,'/bdd/','/BKP_DUP/REMDOXDUP/')||'''''";'
from v$logfile;
+++++++++++++++++++++++++++++++++++++++++++

For the duplicate, create  a script like this:

Restore_DEVDB.rman.
++++++++++++++++++++++++++++++++++++++++++++
RUN
{
allocate channel c2 device type disk;
# rename the datafiles and online redo logs
set newname for datafile 1 to ‘/data10/oradata/DEVDBNEW/system01.dbf’;
set newname for datafile 2 to ‘/data10/oradata/DEVDBNEW/undotbs01.dbf’;
set newname for datafile 3 to ‘/data10/oradata/DEVDBNEW/sysaux01.dbf’;
set newname for datafile 4 to ‘/data10/oradata/DEVDBNEW/users01.dbf’;
set newname for datafile 5 to ‘/data10/oradata/DEVDBNEW/ODIN_DATA1.dbf’;
set newname for datafile 6 to ‘/data10/oradata/DEVDBNEW/ODIN_INDEX1.dbf’;
set newname for datafile 7 to ‘/data10/oradata/DEVDBNEW/ESDNW_DATA.dbf’;
etc…
set newname for datafile 25 to ‘/data10/oradata/DEVDBNEW/inet_lob3.dbf’;
set newname for datafile 26 to ‘/data10/oradata/DEVDBNEW/inet_lob4.dbf’;
sql “alter database rename file ”/local/data/oracle/DEVDB/redo/redo04a.log” to ”/data10/oradata/DEVDBNEW/redo04a.log””;
sql “alter database rename file ”/local/data/oracle/DEVDB/redo/redo04b.log”
to ”/data10/oradata/DEVDBNEW/redo04b.log””;
sql “alter database rename file ”/local/data/oracle/DEVDB/redo/redo03a.log”
to ”/data10/oradata/DEVDBNEW/redo03a.log””;
sql “alter database rename file ”/local/data/oracle/DEVDB/redo/redo03b.log”
to ”/data10/oradata/DEVDBNEW/redo03b.log””;
sql “alter database rename file ”/local/data/oracle/DEVDB/redo/redo02a.log”
to ”/data10/oradata/DEVDBNEW/redo02a.log””;
sql “alter database rename file ”/local/data/oracle/DEVDB/redo/redo02b.log”
to ”/data10/oradata/DEVDBNEW/redo02b.log””;
sql “alter database rename file ”/local/data/oracle/DEVDB/redo/redo01a.log”
to ”/data10/oradata/DEVDBNEW/redo01a.log””;
sql “alter database rename file ”/local/data/oracle/DEVDB/redo/redo01b.log”
to ”/data10/oradata/DEVDBNEW/redo01b.log””;
# PUT SCN OR TIME RESTORE POINT

# restore the database and switch the datafile names
RESTORE DATABASE;
SWITCH DATAFILE ALL;
# recover the database
RECOVER DATABASE;
}
+++++++++++++++++++++++++++++++++++++++++


RMAN> set DBID 173282285;
RMAN> start force nomount pfile=’/home/oracle/dba/rob/pfileDEVDB.ora’;
RMAN> restore controlfile from ‘/local/data/oracle/rman/DEVDB/ora_cfc-173282285-20091012-00’;
RMAN> alter database mount;
RMAN> @restore_DEVDB.rman

