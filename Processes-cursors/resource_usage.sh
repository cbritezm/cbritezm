#!/bin/bash
. ~/entorn_BDRPALAU

bandera="true";
while [ $bandera = "true" ];
do
	atim=$(date +%H);
	if [[ "$atim" -ge 12 || "$atim" -lt 6 ]] ;
	then
		echo "">>resources_usage.txt;
		echo "Open cursor usage at `date`">>resources_usage.txt;
		sqlplus -s sys/presi123 as sysdba @open_cursor.sql;
		echo "">>resources_usage.txt;
		echo "Resource usage at `date`">>resources_usage.txt;
		sqlplus -s sys/presi123 as sysdba @resource_usage.sql;
	else
		bandera="false";
	fi
	sleep 900;
done;
echo "">>resources_usage.txt;
echo "Resource usage end at `date`">>resources_usage.txt;
