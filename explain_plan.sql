--------------------------------------------------------------------------------
-- Explain plan current statement
--------------------------------------------------------------------------------

select plan_table_output 
from table(dbms_xplan.display('plan_table',null,'basic'));

--------------------------------------------------------------------------------
-- Explain plan from sqlid
--------------------------------------------------------------------------------

select plan_table_output 
from table(dbms_xplan.display_cursor('fnrtqw9c233tt',null,'basic'));


from:
https://blogs.oracle.com/optimizer/how-do-i-display-and-read-the-execution-plans-for-a-sql-statement