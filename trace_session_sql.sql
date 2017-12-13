-- Trace session at session level
--------------------------------------------------------------------------------

alter session set tracefile_identifier='10046';
alter session set timed_statistics = true;
alter session set statistics_level=all;
alter session set max_dump_file_size = unlimited;
ALTER SESSION SET TRACEFILE_IDENTIFIER = "MY_BAD_SQL";

Start trace:

    alter session set events '10046 trace name context forever,level 12';

Stop trace:

    alter session set events '10046 trace name context off';


-- Trace session at db level
--------------------------------------------------------------------------------

-- Add event to init file
    event="1000 trace name errorstack level 3"
-- to set timed statistics
    exec dbms_system.set_bool_param_in_session(27,7180,'timed_statistics',true);
-- to set maximum trace file size
    exec dbms_system.set_int_param_in_session(27,7180,'max_dump_file_size',2147483647);
-- to start trace
    exec dbms_system.set_sql_trace_in_session(27,7180,true);
-- to stop trace
    exec dbms_system.set_sql_trace_in_session(27,7180,false);
