CONNECT system/manager

CREATE OR REPLACE PROCEDURE show_dumpfile_info(
  p_dir  VARCHAR2 DEFAULT 'DATA_PUMP_DIR',
  p_file VARCHAR2 DEFAULT 'EXPDAT.DMP')
AS
-- p_dir        = directory object where dump file can be found
-- p_file       = simple filename of export dump file (case-sensitive)
  v_separator   VARCHAR2(80) := '--------------------------------------' ||
                                '--------------------------------------';
  v_path        all_directories.directory_path%type := '?';
  v_filetype    NUMBER;                 -- 0=unknown 1=expdp 2=exp 3=ext
  v_fileversion VARCHAR2(15);           -- 0.1=10gR1 1.1=10gR2 (etc.)
  v_info_table  sys.ku$_dumpfile_info;  -- PL/SQL table with file info
  type valtype  IS VARRAY(23) OF VARCHAR2(2048);
  var_values    valtype := valtype();
  no_file_found EXCEPTION;
  PRAGMA        exception_init(no_file_found, -39211);

BEGIN

-- Dump file details:
-- ==================
-- For Oracle10g Release 2 and higher:
--    dbms_datapump.KU$_DFHDR_FILE_VERSION        CONSTANT NUMBER := 1;
--    dbms_datapump.KU$_DFHDR_MASTER_PRESENT      CONSTANT NUMBER := 2;
--    dbms_datapump.KU$_DFHDR_GUID                CONSTANT NUMBER := 3;
--    dbms_datapump.KU$_DFHDR_FILE_NUMBER         CONSTANT NUMBER := 4;
--    dbms_datapump.KU$_DFHDR_CHARSET_ID          CONSTANT NUMBER := 5;
--    dbms_datapump.KU$_DFHDR_CREATION_DATE       CONSTANT NUMBER := 6;
--    dbms_datapump.KU$_DFHDR_FLAGS               CONSTANT NUMBER := 7;
--    dbms_datapump.KU$_DFHDR_JOB_NAME            CONSTANT NUMBER := 8;
--    dbms_datapump.KU$_DFHDR_PLATFORM            CONSTANT NUMBER := 9;
--    dbms_datapump.KU$_DFHDR_INSTANCE            CONSTANT NUMBER := 10;
--    dbms_datapump.KU$_DFHDR_LANGUAGE            CONSTANT NUMBER := 11;
--    dbms_datapump.KU$_DFHDR_BLOCKSIZE           CONSTANT NUMBER := 12;
--    dbms_datapump.KU$_DFHDR_DIRPATH             CONSTANT NUMBER := 13;
--    dbms_datapump.KU$_DFHDR_METADATA_COMPRESSED CONSTANT NUMBER := 14;
--    dbms_datapump.KU$_DFHDR_DB_VERSION          CONSTANT NUMBER := 15;
-- For Oracle11gR1:
--    dbms_datapump.KU$_DFHDR_MASTER_PIECE_COUNT  CONSTANT NUMBER := 16;
--    dbms_datapump.KU$_DFHDR_MASTER_PIECE_NUMBER CONSTANT NUMBER := 17;
--    dbms_datapump.KU$_DFHDR_DATA_COMPRESSED     CONSTANT NUMBER := 18;
--    dbms_datapump.KU$_DFHDR_METADATA_ENCRYPTED  CONSTANT NUMBER := 19;
--    dbms_datapump.KU$_DFHDR_DATA_ENCRYPTED      CONSTANT NUMBER := 20;
-- For Oracle11gR2:
--    dbms_datapump.KU$_DFHDR_COLUMNS_ENCRYPTED   CONSTANT NUMBER := 21;
--    dbms_datapump.KU$_DFHDR_ENCRIPTION_MODE     CONSTANT NUMBER := 22;
-- For Oracle12cR1:
--    dbms_datapump.KU$_DFHDR_COMPRESSION_ALG     CONSTANT NUMBER := 23;

-- For Oracle10gR2: KU$_DFHDR_MAX_ITEM_CODE       CONSTANT NUMBER := 15;
-- For Oracle11gR1: KU$_DFHDR_MAX_ITEM_CODE       CONSTANT NUMBER := 20;
-- For Oracle11gR2: KU$_DFHDR_MAX_ITEM_CODE       CONSTANT NUMBER := 22;
-- For Oracle12cR1: KU$_DFHDR_MAX_ITEM_CODE       CONSTANT NUMBER := 23;

-- Show header output info:
-- ========================

  dbms_output.put_line(v_separator);
  dbms_output.put_line('Purpose..: Obtain details about export ' ||
        'dumpfile.        Version: 18-DEC-2013');
  dbms_output.put_line('Required.: RDBMS version: 10.2.0.1.0 or higher');
  dbms_output.put_line('.          ' ||
        'Export dumpfile version: 7.3.4.0.0 or higher');
  dbms_output.put_line('.          ' ||
        'Export Data Pump dumpfile version: 10.1.0.1.0 or higher');
  dbms_output.put_line('Usage....: ' ||
        'execute show_dumfile_info(''DIRECTORY'', ''DUMPFILE'');');
  dbms_output.put_line('Example..: ' ||
        'exec show_dumfile_info(''MY_DIR'', ''expdp_s.dmp'')');
  dbms_output.put_line(v_separator);
  dbms_output.put_line('Filename.: ' || p_file);
  dbms_output.put_line('Directory: ' || p_dir);

-- Retrieve Export dumpfile details:
-- =================================

  SELECT directory_path INTO v_path FROM all_directories
   WHERE directory_name = p_dir
      OR directory_name = UPPER(p_dir);

  dbms_datapump.get_dumpfile_info(
           filename   => p_file,       directory => UPPER(p_dir),
           info_table => v_info_table, filetype  => v_filetype);

  var_values.EXTEND(23);
  FOR i in 1 .. 23 LOOP
    BEGIN
      SELECT value INTO var_values(i) FROM TABLE(v_info_table)
       WHERE item_code = i;
    EXCEPTION WHEN OTHERS THEN var_values(i) := '';
    END;
  END LOOP;

  dbms_output.put_line('Disk Path: ' || v_path);

  IF v_filetype >= 1 THEN
    -- Get characterset name:
    BEGIN
      SELECT var_values(5) || ' (' || nls_charset_name(var_values(5)) ||
        ')' INTO var_values(5) FROM dual;
    EXCEPTION WHEN OTHERS THEN null;
    END;
    IF v_filetype = 2 THEN
      dbms_output.put_line(
         'Filetype.: ' || v_filetype || ' (Original Export dumpfile)');
      dbms_output.put_line(v_separator);
      SELECT DECODE(var_values(13), '0', '0 (Conventional Path)',
        '1', '1 (Direct Path)', var_values(13))
        INTO var_values(13) FROM dual;
      dbms_output.put_line('...Characterset ID of source db..: ' || var_values(5));
      dbms_output.put_line('...Direct Path Export Mode.......: ' || var_values(13));
      dbms_output.put_line('...Export Version................: ' || var_values(15));
    ELSIF v_filetype = 1 OR v_filetype = 3 THEN
      SELECT SUBSTR(var_values(1), 1, 15) INTO v_fileversion FROM dual;
      SELECT DECODE(var_values(1),
                    '0.1', '0.1 (Oracle10g Release 1: 10.1.0.x)',
                    '1.1', '1.1 (Oracle10g Release 2: 10.2.0.x)',
                    '2.1', '2.1 (Oracle11g Release 1: 11.1.0.x)',
                    '3.1', '3.1 (Oracle11g Release 2: 11.2.0.x)',
                    '4.1', '4.1 (Oracle12c Release 1: 12.1.0.x)',
        var_values(1)) INTO var_values(1) FROM dual;
      SELECT DECODE(var_values(2), '0', '0 (No)', '1', '1 (Yes)',
        var_values(2)) INTO var_values(2) FROM dual;
      SELECT DECODE(var_values(14), '0', '0 (No)', '1', '1 (Yes)',
        var_values(14)) INTO var_values(14) FROM dual;
      SELECT DECODE(var_values(18), '0', '0 (No)', '1', '1 (Yes)',
        var_values(18)) INTO var_values(18) FROM dual;
      SELECT DECODE(var_values(19), '0', '0 (No)', '1', '1 (Yes)',
        var_values(19)) INTO var_values(19) FROM dual;
      SELECT DECODE(var_values(20), '0', '0 (No)', '1', '1 (Yes)',
        var_values(20)) INTO var_values(20) FROM dual;
      SELECT DECODE(var_values(21), '0', '0 (No)', '1', '1 (Yes)',
        var_values(21)) INTO var_values(21) FROM dual;
      SELECT DECODE(var_values(22),
                    '1', '1 (Unknown)',
                    '2', '2 (None)',
                    '3', '3 (Password)',
                    '4', '4 (Password and Wallet)',
                    '5', '5 (Wallet)',
        var_values(22)) INTO var_values(22) FROM dual;
      SELECT DECODE(var_values(23),
                    '2', '2 (None)',
                    '3', '3 (Basic)',
                    '4', '4 (Low)',
                    '5', '5 (Medium)',
                    '6', '6 (High)',
        var_values(23)) INTO var_values(23) FROM dual;
      IF v_filetype = 1 THEN
        dbms_output.put_line(
           'Filetype.: ' || v_filetype || ' (Export Data Pump dumpfile)');
        dbms_output.put_line(v_separator);
        dbms_output.put_line('...Database Job Version..........: ' || var_values(15));
        dbms_output.put_line('...Internal Dump File Version....: ' || var_values(1));
        dbms_output.put_line('...Creation Date.................: ' || var_values(6));
        dbms_output.put_line('...File Number (in dump file set): ' || var_values(4));
        dbms_output.put_line('...Master Present in dump file...: ' || var_values(2));
        IF dbms_datapump.KU$_DFHDR_MAX_ITEM_CODE > 15 AND v_fileversion >= '2.1' THEN
          dbms_output.put_line('...Master in how many dump files.: ' || var_values(16));
          dbms_output.put_line('...Master Piece Number in file...: ' || var_values(17));
        END IF;
        dbms_output.put_line('...Operating System of source db.: ' || var_values(9));
        IF v_fileversion >= '2.1' THEN
          dbms_output.put_line('...Instance Name of source db....: ' || var_values(10));
        END IF;
        dbms_output.put_line('...Characterset ID of source db..: ' || var_values(5));
        dbms_output.put_line('...Language Name of characterset.: ' || var_values(11));
        dbms_output.put_line('...Job Name......................: ' || var_values(8));
        dbms_output.put_line('...GUID (unique job identifier)..: ' || var_values(3));
        dbms_output.put_line('...Block size dump file (bytes)..: ' || var_values(12));
        dbms_output.put_line('...Metadata Compressed...........: ' || var_values(14));
        IF dbms_datapump.KU$_DFHDR_MAX_ITEM_CODE > 15 THEN
          dbms_output.put_line('...Data Compressed...............: ' || var_values(18));
          IF dbms_datapump.KU$_DFHDR_MAX_ITEM_CODE > 22 AND v_fileversion >= '4.1' THEN
            dbms_output.put_line('...Compression Algorithm.........: ' || var_values(23));
          END IF;
          dbms_output.put_line('...Metadata Encrypted............: ' || var_values(19));
          dbms_output.put_line('...Table Data Encrypted..........: ' || var_values(20));
          dbms_output.put_line('...Column Data Encrypted.........: ' || var_values(21));
          dbms_output.put_line('...Encryption Mode...............: ' || var_values(22));
        END IF;
      ELSE
        dbms_output.put_line(
           'Filetype.: ' || v_filetype || ' (External Table dumpfile)');
        dbms_output.put_line(v_separator);
        dbms_output.put_line('...Database Job Version..........: ' || var_values(15));
        dbms_output.put_line('...Internal Dump File Version....: ' || var_values(1));
        dbms_output.put_line('...Creation Date.................: ' || var_values(6));
        dbms_output.put_line('...File Number (in dump file set): ' || var_values(4));
        dbms_output.put_line('...Operating System of source db.: ' || var_values(9));
        IF v_fileversion >= '2.1' THEN
          dbms_output.put_line('...Instance Name of source db....: ' || var_values(10));
        END IF;
        dbms_output.put_line('...Characterset ID of source db..: ' || var_values(5));
        dbms_output.put_line('...Language Name of characterset.: ' || var_values(11));
        dbms_output.put_line('...GUID (unique job identifier)..: ' || var_values(3));
        dbms_output.put_line('...Block size dump file (bytes)..: ' || var_values(12));
        IF dbms_datapump.KU$_DFHDR_MAX_ITEM_CODE > 15 THEN
          dbms_output.put_line('...Data Compressed...............: ' || var_values(18));
          IF dbms_datapump.KU$_DFHDR_MAX_ITEM_CODE > 22 AND v_fileversion >= '4.1' THEN
            dbms_output.put_line('...Compression Algorithm.........: ' || var_values(23));
          END IF;
          dbms_output.put_line('...Table Data Encrypted..........: ' || var_values(20));
          dbms_output.put_line('...Encryption Mode...............: ' || var_values(22));
        END IF;
      END IF;
      dbms_output.put_line('...Internal Flag Values..........: ' || var_values(7));
      dbms_output.put_line('...Max Items Code (Info Items)...: ' ||
                  dbms_datapump.KU$_DFHDR_MAX_ITEM_CODE);
    END IF;
  ELSE
    dbms_output.put_line('Filetype.: ' || v_filetype);
    dbms_output.put_line(v_separator);
    dbms_output.put_line('ERROR....: Not an export dumpfile.');
  END IF;
  dbms_output.put_line(v_separator);

EXCEPTION
  WHEN no_data_found THEN
    dbms_output.put_line('Disk Path: ?');
    dbms_output.put_line('Filetype.: ?');
    dbms_output.put_line(v_separator);
    dbms_output.put_line('ERROR....: Directory Object does not exist.');
    dbms_output.put_line(v_separator);
  WHEN no_file_found THEN
    dbms_output.put_line('Disk Path: ' || v_path);
    dbms_output.put_line('Filetype.: ?');
    dbms_output.put_line(v_separator);
    dbms_output.put_line('ERROR....: File does not exist.');
    dbms_output.put_line(v_separator);
END;
/
 


Note that this procedure can only be used in an Oracle10g Release 2 or any higher release database. The procedure makes a call to DBMS_DATAPUMP.GET_DUMPFILE_INFO which was introduced in release 10.2.0.1.0.
For details about the minimum requirements to run an Data Pump job, see:
Note 351598.1 - Export/Import DataPump: The Minimum Requirements to Use Export DataPump and Import DataPump (System Privileges)

Also note that the user SYSTEM should have been granted access to the referenced directory object if the SYSTEM user did not create the directory object. If the default Data Pump directory is used or if a user (like SYS) created a different directory object, then access should be granted, e.g.:
-- grant access to directory object:

CONNECT / as sysdba
GRANT read, write ON DIRECTORY my_dir TO system;


A sample screen output of this procedure in Oracle11g for an Export DataPump dumpfile is:
-- call procedure SHOW_DUMPFILE_INFO in SQL*Plus:

SET serveroutput on SIZE 1000000  
exec show_dumpfile_info(p_dir=> 'my_dir', p_file=> 'expdp_s.dmp') 

---------------------------------------------------------------------------- 
Purpose..: Obtain details about export dumpfile.        Version: 18-DEC-2013
Required.: RDBMS version: 10.2.0.1.0 or higher
.          Export dumpfile version: 7.3.4.0.0 or higher
.          Export Data Pump dumpfile version: 10.1.0.1.0 or higher
Usage....: execute show_dumfile_info('DIRECTORY', 'DUMPFILE');
Example..: exec show_dumfile_info('MY_DIR', 'expdp_s.dmp')
----------------------------------------------------------------------------
Filename.: expdp_s.dmp
Directory: my_dir
Disk Path: /u01_sr3d7448968191/expdp
Filetype.: 1 (Export Data Pump dumpfile)
----------------------------------------------------------------------------
...Database Job Version..........: 12.01.00.00.00
...Internal Dump File Version....: 4.1 (Oracle12c Release 1: 12.1.0.x)
...Creation Date.................: Wed Dec 18 19:13:13 2013
...File Number (in dump file set): 1
...Master Present in dump file...: 1 (Yes)
...Master in how many dump files.: 1
...Master Piece Number in file...: 1
...Operating System of source db.: x86_64/Linux 2.4.xx
...Instance Name of source db....: sPc11Sa
...Characterset ID of source db..: 178 (WE8MSWIN1252)
...Language Name of characterset.: WE8MSWIN1252
...Job Name......................: "SYSTEM"."SYS_EXPORT_TABLE_01"
...GUID (unique job identifier)..: EDD4D38724A26376E0437408DC0AAE97
...Block size dump file (bytes)..: 4096
...Metadata Compressed...........: 1 (Yes)
...Data Compressed...............: 0 (No)
...Compression Algorithm.........: 3 (Basic)
...Metadata Encrypted............: 0 (No)
...Table Data Encrypted..........: 0 (No)
...Column Data Encrypted.........: 0 (No)
...Encryption Mode...............: 2 (None)
...Internal Flag Values..........: 514
...Max Items Code (Info Items)...: 23
----------------------------------------------------------------------------

PL/SQL procedure successfully completed.
