--------------------------------------------------------------------------------
-- Gather stats
--------------------------------------------------------------------------------

--Disable automatic statistics
--------------------------------------------------------------------------------
EXEC DBMS_SCHEDULER.DISABLE('GATHER_STATS_JOB');


-- Create/drop stat table
--------------------------------------------------------------------------------

exec dbms_stats.create_stat_table(ownname => 'SAGAN2',stattab => 'SAGAN2_STATS',tblspace => 'SAGA_DATOS');
exec DBMS_STATS.DROP_STAT_TABLE (ownname => 'SAGAN2', stattab=> 'SAGAN2_STATS');


-- Export table stats
--------------------------------------------------------------------------------

exec dbms_stats.export_table_stats ( ownname => 'SAGAN2' , stattab => 'SAGAN2_STATS' , tabname => 'ALUMNEGRUP' , statid => 'ST_ALUMNEGRUP_1' );
exec dbms_stats.export_table_stats ( ownname => 'SAGAN2' , stattab => 'SAGAN2_STATS' , tabname => 'ALUMNECENTRE' , statid => 'ST_ALUMNECENTRE_1' );

exec dbms_stats.delete_table_stats(ownname=>'SAGAN2', tabname=>'ALUMNEGRUP');
exec dbms_stats.delete_table_stats(ownname=>'SAGAN2', tabname=>'ALUMNECENTRE');


--Gather stats
--------------------------------------------------------------------------------
exec dbms_stats.gather_table_stats( ownname => 'SAGAN2',tabname => 'ALUMNEGRUP',method_opt => 'for all columns size auto',cascade => TRUE);
exec dbms_stats.gather_table_stats( ownname => 'SAGAN2',tabname => 'ALUMNECENTRE',method_opt => 'for all columns size auto',cascade => TRUE);



How To Diagnose Why an Identical Query Has Different Plans (and Performance) in Different Environments (Doc ID 1671642.1)

