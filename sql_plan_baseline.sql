--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--			Get SQL handle and SQL plan from query  			 +
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

SELECT sql_handle, plan_name, enabled, accepted 
FROM   dba_sql_plan_baselines
WHERE  sql_text LIKE '%FROM DAPR01_MT_DATA_LOAD_PROCESS DLP, DAPR_CP_RAW_VW CRV%'
AND    sql_text NOT LIKE '%dba_sql_plan_baselines%';

SQL_HANDLE                     PLAN_NAME                      ENA ACC
------------------------------ ------------------------------ --- ---
SQL_1503cff550452ca2           SQL_PLAN_1a0ygyp84ab522c6f5179 YES YES
SQL_1503cff550452ca2           SQL_PLAN_1a0ygyp84ab52496cce15 NO  YES

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--				Load sql plan from cursor cache					 +
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

SET SERVEROUTPUT ON
DECLARE
  l_plans_loaded  PLS_INTEGER;
BEGIN
  l_plans_loaded := DBMS_SPM.load_plans_from_cursor_cache(
    sql_id => '2z3thj9db8pct');
    
  DBMS_OUTPUT.put_line('Plans Loaded: ' || l_plans_loaded);
END;
/

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--				envolve sql plan								 +
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

SET SERVEROUTPUT ON
SET LONG 10000
DECLARE
    x clob;
BEGIN
x := dbms_spm.evolve_sql_plan_baseline
('SQL_1503cff550452ca2',
 'SQL_PLAN_1a0ygyp84ab522c6f5179',
 VERIFY=>'YES' ,
 COMMIT=>'YES');
DBMS_OUTPUT.PUT_LINE(x);
END;
/

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--				Display sql plan baseline						 +
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

SELECT *
FROM   TABLE(DBMS_XPLAN.display_sql_plan_baseline(plan_name=>'SQL_PLAN_1a0ygyp84ab52496cce15'));


--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--				Create sql plan table for export				 +
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
BEGIN
  DBMS_SPM.CREATE_STGTAB_BASELINE(
    table_name      => 'spm_stageing_tab',
    table_owner     => 'dapr',
    tablespace_name => 'dapr');
END;
/

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--				Pack sql plan to table							 +
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

SET SERVEROUTPUT ON
DECLARE
  l_plans_packed  PLS_INTEGER;
BEGIN
	l_plans_packed := DBMS_SPM.pack_stgtab_baseline(
    table_name      => 'spm_stageing_tab',
    table_owner     => 'dapr',
	sql_handle		=> 'SQL_1503cff550452ca2',
	plan_name		=> 'SQL_PLAN_1a0ygyp84ab522c6f5179');

  DBMS_OUTPUT.put_line('Plans Packed: ' || l_plans_packed);
END;
/


--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--				Unpack sql plan from table						 +
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
SET SERVEROUTPUT ON
DECLARE
  l_plans_unpacked  PLS_INTEGER;
BEGIN
  l_plans_unpacked := DBMS_SPM.unpack_stgtab_baseline(
    table_name      => 'spm_stageing_tab',
    table_owner     => 'DAPR',
	sql_handle		=> 'SQL_1503cff550452ca2',
	plan_name		=> 'SQL_PLAN_1a0ygyp84ab522c6f5179');

  DBMS_OUTPUT.put_line('Plans Unpacked: ' || l_plans_unpacked);
END;
/

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--				Alter sql plan baseline							 +
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
declare
myplan pls_integer;
begin
	myplan:=DBMS_SPM.ALTER_SQL_PLAN_BASELINE (
	sql_handle => 'SQL_1503cff550452ca2',
	plan_name  => 'SQL_PLAN_1a0ygyp84ab52496cce15',
	attribute_name => 'ENABLED',
	attribute_value => 'YES');
end;
/

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--				Drop sql plan baseline							 +
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

declare
myplan pls_integer;
begin
	myplan:=DBMS_SPM.DROP_SQL_PLAN_BASELINE (
    sql_handle => 'SQL_1503cff550452ca2',
	plan_name  => 'SQL_PLAN_1a0ygyp84ab522c6f5179');
end;
/

