set serverout on
set feedback off
declare
        v_used integer(10);
        v_total integer(10);
        v_free integer(10);
begin
	DBMS_OUTPUT.ENABLE (buffer_size => NULL);
        select t.totalspace,round((t.totalspace-fs.freespace),2),fs.freespace into v_total,v_used,v_free
        from
                (select round(sum(d.bytes)/(1024*1024)) as totalspace, d.tablespace_name tablespace from dba_data_files d group by d.tablespace_name) t,
                (select round(sum(f.bytes)/(1024*1024)) as freespace,
                f.tablespace_name tablespace
        from dba_free_space f
        group by f.tablespace_name) fs
        where t.tablespace=fs.tablespace and t.tablespace='SYSAUX';
	dbms_output.put_line('	.TOTAL : '||v_total||'(MB)');
	dbms_output.put_line('	.USED  : '||v_used||'(MB) '||round((v_used/v_total)*100)||'%');
	dbms_output.put_line('	.FREE  : '||v_free||'(MB)');
end;
/
exit
