set lines 132
set pages 200
COL HANDLE FORMAT A30 TRUNC
COL TAG FORMAT A20
COL COMPLETION_TIME FORMAT A20
COL START_TIME FORMAT A20
COL INCR_LEVEL FORMAT A2 HEAD 'L'
COL CONTROLFILE_INCLUDED FORMAT A3 HEAD 'CTL'

select BASET.BCK_TYPE, 
decode(BASET.CONTROLFILE_INCLUDED,'BACKUP','YES','NO') as CONTROLFILE_INCLUDED, 
BASET.INCR_LEVEL, bapiece.tag, bapiece.handle, bapiece.start_time, bapiece.completion_time, 
round(bapiece.bytes/1024/1024,2) as Mb
from rman.bp bapiece, 
        rman.dbinc d,
        rman.bs baset,
        rman.db b
where BAPIECE.DB_KEY=D.DB_KEY
   and D.DB_NAME='SAGA'
   and BASET.DB_KEY=D.DB_KEY
   and BASET.BS_KEY = BAPIECE.BS_KEY
   and bapiece.handle='m0qj596k_1_2'
   and B.DB_KEY=D.DB_KEY
order by  bapiece.start_time desc  
/



select BASET.BCK_TYPE, 
decode(BASET.CONTROLFILE_INCLUDED,'BACKUP','YES','NO') as CONTROLFILE_INCLUDED, 
BASET.INCR_LEVEL, bapiece.tag, bapiece.handle, bapiece.start_time, bapiece.completion_time, 
round(bapiece.bytes/1024/1024,2) as Mb
from rman.bp bapiece, 
        rman.dbinc d,
        rman.bs baset,
        rman.db b
where BAPIECE.DB_KEY=D.DB_KEY
   and D.DB_NAME='SAGA'
   and BASET.DB_KEY=D.DB_KEY
   and BASET.BS_KEY = BAPIECE.BS_KEY
   and trunc(bapiece.start_time)=to_date('25/11/2015','dd/mm/yyyy')
  and baset.completion_time <= to_date('26-12-2015 01','dd-mm-yyyy hh24')
   and B.DB_KEY=D.DB_KEY
order by  bapiece.start_time desc  
/
