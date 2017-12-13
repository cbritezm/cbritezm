--------------------------------------------------------------------------------------
--Problem: the application encounters an ORA-01578 runtime error because there are one or 
--more corrupt blocks in a table it is reading.
--------------------------------------------------------------------------------------
First of all we have two diffent kinds of block corruption:
- physical corruption (media corrupt) : can be caused by defected memory boards, controllers or broken sectors on a hard disk.
- logical corruption (soft corrupt) :  can amoung other reasons be caused by an attempt to recover through a NOLOGGING action.


--There are two initialization parameters for dealing with block corruption:

- DB_BOCK_CHECKSUM (calculates a checksum for each block before it is written to disk, every time) causes 1-2% performance overhead
- DB_BLOCK_CHECKING (serverprocess checks block for internal consistency after every DML) causes 1-10% performance overhead
If performance is not a big issue then you should use these!
Normally RMAN checks only for physically corrupt blocks with every backup it takes and every image copy it makes.
This is a common misunderstanding amoung a lot of DBAs. RMAN doesn not automatically detect logical corruption by default!
--We have to tell it to do so by using CHECK LOGICAL!

---------------------------------------------------------------------------------------------
--The info about corruptions can be found in the following views
---------------------------------------------------------------------------------------------

select * from v$backup_corruption;

RECID STAMP SET_STAMP SET_COUNT PIECE# FILE# BLOCK# BLOCKS CORRUPTION_CHANGE# MAR CORRUPTIO
———- ———- ———- ———- ———- ———- ———- ———- —————— — ———
1 586945441 586945402 3 1 5 81 4 0 YES CORRUPT

select * from v$copy_corruption;

---------------------------------------------------------------------------------------------
-- Study Case
---------------------------------------------------------------------------------------------

select last_name, salary from employees;

ERROR at line 2:
ORA-01578: ORACLE data block corrupted (file # 5, block # 83)
# this could be an ORA-26040 in Oracle 8i! and before
ORA-01110: data file 5: ‘/u01/app/oracle/oradata/orcl/example01.dbf’


This is what you find in the alert_.log:
Wed Apr 5 08:17:40 2006
Hex dump of (file 5, block 83) in trace file
/u01/app/oracle/admin/orcl/udump/orcl_ora_14669.trc
Corrupt block relative dba: 0×01400053 (file 5, block 83)
Bad header found during buffer read
Data in bad block:
type: 67 format: 7 rdba: 0x0a545055
last change scn: 0×0000.0006d162 seq: 0×1 flg: 0×04
spare1: 0×52 spare2: 0×52 spare3: 0×0
consistency value in tail: 0xd1622301
check value in block header: 0x63be
computed block checksum: 0xe420
Reread of rdba: 0×01400053 (file 5, block 83)
found same corrupted data
Wed Apr 5 08:17:41 2006
Corrupt Block Found
TSN = 6, TSNAME = EXAMPLE
RFN = 5, BLK = 83, RDBA = 20971603
OBJN = 51857, OBJD = 51255, OBJECT = , SUBOBJECT =
SEGMENT OWNER = , SEGMENT TYPE =


---------------------------------------------------------------------------------------------
-- Check with RMAN
---------------------------------------------------------------------------------------------
Starting with Oracle 9i we can use RMAN to check a database for both physically and logically corrupt blocks.


RMAN> backup validate check logical database;
Starting backup at 05-04-2006:08:23:20
allocated channel: ORA_DISK_1
channel ORA_DISK_1: sid=136 devtype=DISK
channel ORA_DISK_1: starting full datafile backupset
channel ORA_DISK_1: specifying datafile(s) in backupset
input datafile fno=00001 name=/u01/app/oracle/oradata/orcl/system01.dbf
input datafile fno=00003 name=/u01/app/oracle/oradata/orcl/sysaux01.dbf
input datafile fno=00005 name=/u01/app/oracle/oradata/orcl/example01.dbf
input datafile fno=00002 name=/u01/app/oracle/oradata/orcl/undotbs01.dbf
input datafile fno=00004 name=/u01/app/oracle/oradata/orcl/users01.dbf
channel ORA_DISK_1: backup set complete, elapsed time: 00:00:45
channel ORA_DISK_1: starting full datafile backupset
channel ORA_DISK_1: specifying datafile(s) in backupset
including current control file in backupset
including current SPFILE in backupset
channel ORA_DISK_1: backup set complete, elapsed time: 00:00:03
channel ORA_DISK_1: starting full datafile backupset
channel ORA_DISK_1: specifying datafile(s) in backupset
including current control file in backupset
including current SPFILE in backupset
channel ORA_DISK_1: backup set complete, elapsed time: 00:00:03
Finished backup at 05-04-2006:08:24:10

-- *** RMAN does not physically backup the database with this command but it reads all blocks and checks for corruptions.
If it finds corrupted blocks it will place the information about the corruption into a view:

select * from v$database_block_corruption;
FILE# BLOCK# BLOCKS CORRUPTION_CHANGE# CORRUPTIO
———- ———- ———- —————— ———
5 81 4 0 CORRUPT


---------------------------------------------------------------------------------------------
--tell RMAN to recover all the blocks
---------------------------------------------------------------------------------------------

RMAN> blockrecover corruption list;
# (all blocks from v$database_block_corruption)
Starting blockrecover at 05-04-2006:10:09:15
using channel ORA_DISK_1
channel ORA_DISK_1: restoring block(s) from datafile copy /u01/app/oracle/flash_recovery_area/ORCL/datafile/o1_mf_example_236tmb1c_.dbf
starting media recovery
archive log thread 1 sequence 2 is already on disk as file /u01/app/oracle/flash_recovery_area/ORCL/archivelog/2006_04_05/o1_mf_1_2_236wxbsp_.arc
archive log thread 1 sequence 1 is already on disk as file/u01/app/oracle/oradata/orcl/redo01.log
media recovery complete, elapsed time: 00:00:01
Finished blockrecover at 05-04-2006:10:09:24
this is in the alert_.log:
Starting block media recovery
Wed Apr 5 10:09:22 2006
Media Recovery Log /u01/app/oracle/flash_recovery_area/ORCL/archivelog/2006_04_05/o1_mf_1_2_%u_.arc
Wed Apr 5 10:09:23 2006
Media Recovery Log /u01/app/oracle/flash_recovery_area/ORCL/archivelog/2006_04_05/o1_mf_1_2_236wxbsp_.arc ( restored)
Wed Apr 5 10:09:23 2006
Recovery of Online Redo Log: Thread 1 Group 1 Seq 1 Reading mem 0
Mem# 0 errs 0: /u01/app/oracle/oradata/orcl/redo01.log
Wed Apr 5 10:09:23 2006
Completed block media recovery


Subject: Handling Oracle Block Corruptions in Oracle7/8/8i/9i/10g
Doc ID: Note:28814.1 Type: BULLETIN
Last Revision Date: 26-MAR-2006 Status: PUBLISHED
connect lutz hartmann as sysdba

