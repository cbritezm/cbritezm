#!/bin/bash
script_dir="/home/oracle/cbritez/purge";
cd $script_dir
./purge.sh>>$script_dir/logs/purge_sysaux_`date '+%d%m%y'`.log
zip -m $script_dir/logs/purge_sysaux_`date '+%d%m%y'`.zip $script_dir/logs/*.log
