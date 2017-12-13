set serverout on;
col owner format a30;
select count(*) INVALIDS,owner from dba_objects where status='INVALID' group by owner;
declare
        cursor c1 is SELECT 'ALTER '||CASE object_type when 'PACKAGE BODY' THEN 'PACKAGE' ELSE OBJECT_TYPE END||' '||owner||'.'||object_name||CASE object_Type when 'PACKAGE BODY' THEN ' COMPILE BODY' ELSE ' COMPILE' END as statement from dba_objects where status='INVALID' order by object_id;
BEGIN
        FOR data in c1
        LOOP
                BEGIN
                        --dbms_output.put_line(data.statement);
                        execute immediate data.statement;
                EXCEPTION
                        WHEN OTHERS THEN
                                dbms_output.put_line(SQLERRM);
                                CONTINUE;
                END;
        END LOOP;
END;
/
select count(*) INVALIDS,owner from dba_objects where status='INVALID' group by owner;
