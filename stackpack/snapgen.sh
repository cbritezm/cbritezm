#!/bin/ksh
PERFSTAT=${1:-perfstat}
PERFPASS=${2:-perfstat}
SWAP_FILE=./list_level.lst
SPREPORT=$ORACLE_HOME/rdbms/admin/spreport.sql

echo "Enter              dbid:"
read dbid

echo "Enter  instance number:"
read instnum

echo "Enter        snap level:"
read snap_level

echo "Enter the first snap id:"
read first

echo "Enter the  last snap id:"
read last

export PERFSTAT PERFPASS  dbid instnum instnam snap_level \
       first last

sqlplus -s ${PERFSTAT}/${PERFPASS} <<EOF
set pages 0
set termout on ;
set head off
set feed off
column instart_fmt noprint;
column versn noprint    heading 'Release'  new_value versn;
column host_name noprint heading 'Host'    new_value host_name;
column para  noprint    heading 'OPS'      new_value para;
column level format 99  heading 'Snap|Level';
column snap_id          heading 'Snap|Id' format 999990;
column snapdat          heading 'Snap Started' just c   format a17;
column comment          heading 'Comment' format a22;
break on inst_name on db_name on instart_fmt;
ttitle lef 'Completed Snapshots' skip 2;
spool ${SWAP_FILE}
select di.version                                        versn
     , di.parallel                                       para
     , to_char(s.startup_time,' dd Mon "at" HH24:mi:ss') instart_fmt
     , s.snap_id
     , to_char(s.snap_time,'dd Mon YYYY HH24:mi')       snapdat
     , s.snap_level                                      "level"
     , substr(s.ucomment, 1,60)                          "comment"
  from stats\$snapshot s
     , stats\$database_instance di
 where s.dbid              = $dbid
   and di.dbid             = $dbid
   and s.instance_number   = $instnum
   and di.instance_number  = $instnum
   and di.startup_time     = s.startup_time
   and s.snap_level = $snap_level
 order by db_name, instance_name, snap_id;
exit;
EOF


echo "Gen Arrary"
cat ${SWAP_FILE} | awk ' BEGIN { D1=0 }
    {
      if(D1!=0)
        if(D1 >= '$first' && $1 <= '$last' )
          printf("%s %s\n",D1,$1);
          D1=$1;
       }'| while read Record
do
set -A Element $(echo $Record)
echo Working on  [${Element[0]},${Element[1]}]
sqlplus ${PERFSTAT}/${PERFPASS} @${SPREPORT} <<EOF 2>/dev/null 1>&2
${Element[0]}
${Element[1]}

exit
EOF
done

rm  ${SWAP_FILE}
