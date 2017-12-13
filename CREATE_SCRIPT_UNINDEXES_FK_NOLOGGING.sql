set echo off verify off showmode off feedback off;
set pagesize 1000;
set line 140;

prompt En el directorio actual se creara el script create_unindexes_FK.sql

Rem
Rem  Asignacion del tablespace para los indices
Rem

prompt
prompt
prompt Seleccione el tablespace para los indices
prompt ----------------------------------------------------

prompt Abajo se listan los tablespaces online en esta base de datos
prompt que pueden almacenar datos de los indices.El tablespace SYSTEM  
prompt SYSAUX,TEMP y USERS no pueden utilizarse
prompt

column tablespace_name format a28 heading 'INDEX TABLESPACE'
select tablespace_name, contents
  from sys.dba_tablespaces 
 where tablespace_name not in ('SYSTEM','SYSAUX','TEMP','USERS' )
   and contents = 'PERMANENT'
   and status = 'ONLINE'
 order by tablespace_name;

prompt
prompt Seleccione el tablespace para los indices
prompt &&index_tablespace

begin
  if upper('&&index_tablespace') in ('SYSTEM','SYSAUX','TEMP','USERS' ) then
    raise_application_error(-20101, 'Error!. Los tablespaces SYSTEM,SYSAUX,TEMP,USERS no pueden utilizarse.');
  end if;
end;
/

set heading off;

spool create_unindexes_FK.sql

select 'CREATE INDEX '||a.owner||'.'||'IND_'||a.constraint_name||' ON '|| a.owner||'.'||a.table_name ||' ( '||
        a.columns ||' ) TABLESPACE &&index_tablespace NOLOGGING PARALLEL 4;'||chr(10)||'ALTER INDEX '||a.owner||'.'||'IND_'||a.constraint_name||' LOGGING;'
  from ( select a.owner, substr(a.table_name,1,30) table_name, 
	               substr(a.constraint_name,1,30) constraint_name, 
	               max(decode(position, 1,     substr(column_name,1,30),NULL)) || 
	               max(decode(position, 2,', '||substr(column_name,1,30),NULL)) || 
	               max(decode(position, 3,', '||substr(column_name,1,30),NULL)) || 
	               max(decode(position, 4,', '||substr(column_name,1,30),NULL)) || 
	               max(decode(position, 5,', '||substr(column_name,1,30),NULL)) || 
	               max(decode(position, 6,', '||substr(column_name,1,30),NULL)) || 
	               max(decode(position, 7,', '||substr(column_name,1,30),NULL)) || 
	               max(decode(position, 8,', '||substr(column_name,1,30),NULL)) || 
	               max(decode(position, 9,', '||substr(column_name,1,30),NULL)) || 
	               max(decode(position,10,', '||substr(column_name,1,30),NULL)) || 
	               max(decode(position,11,', '||substr(column_name,1,30),NULL)) || 
	               max(decode(position,12,', '||substr(column_name,1,30),NULL)) || 
	               max(decode(position,13,', '||substr(column_name,1,30),NULL)) || 
	               max(decode(position,14,', '||substr(column_name,1,30),NULL)) || 
	               max(decode(position,15,', '||substr(column_name,1,30),NULL)) || 
	               max(decode(position,16,', '||substr(column_name,1,30),NULL)) columns
            from sys.all_cons_columns a, sys.all_constraints b
           where a.constraint_name = b.constraint_name
             and a.owner = b.owner
             and b.owner = user
             and b.constraint_type = 'R'
           group by a.owner, substr(a.table_name,1,30), substr(a.constraint_name,1,30) ) a, 
        ( select table_owner, substr(table_name,1,30) table_name, substr(index_name,1,30) index_name, 
                 max(decode(column_position, 1,substr(column_name,1,30),NULL)) || 
	               max(decode(column_position, 2,', '||substr(column_name,1,30),NULL)) || 
	               max(decode(column_position, 3,', '||substr(column_name,1,30),NULL)) || 
	               max(decode(column_position, 4,', '||substr(column_name,1,30),NULL)) || 
	               max(decode(column_position, 5,', '||substr(column_name,1,30),NULL)) || 
	               max(decode(column_position, 6,', '||substr(column_name,1,30),NULL)) || 
	               max(decode(column_position, 7,', '||substr(column_name,1,30),NULL)) || 
	               max(decode(column_position, 8,', '||substr(column_name,1,30),NULL)) || 
	               max(decode(column_position, 9,', '||substr(column_name,1,30),NULL)) || 
	               max(decode(column_position,10,', '||substr(column_name,1,30),NULL)) || 
	               max(decode(column_position,11,', '||substr(column_name,1,30),NULL)) || 
                 max(decode(column_position,12,', '||substr(column_name,1,30),NULL)) || 
	               max(decode(column_position,13,', '||substr(column_name,1,30),NULL)) || 
	               max(decode(column_position,14,', '||substr(column_name,1,30),NULL)) || 
	               max(decode(column_position,15,', '||substr(column_name,1,30),NULL)) || 
	               max(decode(column_position,16,', '||substr(column_name,1,30),NULL)) columns
            from sys.all_ind_columns 
           group by table_owner, substr(table_name,1,30), substr(index_name,1,30) ) b
   where a.owner      = b.table_owner (+)
     and a.table_name = b.table_name (+)
     and substr(a.table_name,1,4) != 'BIN$'
     and substr(a.table_name,1,3) != 'DR$'
     and b.table_name is null
     and b.columns (+) like a.columns || '%'
   order by a.owner, a.table_name, a.constraint_name;

spool off

undefine index_tablespace

set echo on feedback on;
