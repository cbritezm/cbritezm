--------------------------------------------------------------------------------
-- SGA and PGA total
--------------------------------------------------------------------------------

select (sga+pga)/1024/1024 as "sga_pga"
from
    (select sum(value) sga from v$sga),
    (select sum(pga_used_mem) pga from v$process);

-- SGA AND PGA usage
--------------------------------------------------------------------------------

select decode( grouping(nm), 1, 'total', nm ) nm, round(sum(val/1048576)) mb
 from
 (select 'sga' nm, sum(value) val from v$sga
  union all
  select 'pga', sum(value) from v$sysstat
  where name = 'session pga memory'
 )
group by rollup(nm);