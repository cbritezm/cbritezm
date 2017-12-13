#!/bin/bash
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#					SET VARIABLES
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

script_home="/home/oracle/cbritez/purge";
db_name="e13bdi01";
grid_env="GRID";
dp_string="USGD_ACR_GENCAT_e13bdibck_ORA_E13BDI_ARC";
dp_bin="$script_home/omnib/omnib";
arc_type="ASM";		# Only FS/ASM
arc_name="DG_E13BDI_FRA";

# Process variables

orphan_qty=0;
arc_usage=80;	# Set to max umbral for force exit in case that the archiver usage fails
bkp_out=1;
bandera=1; 	# Binary variable, 0 for continue and 1 for stop (Stop if archiver dest > 80 [bkp fail] or purge return 0 rows).
count=0;

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#			FUNCTIONS DECLARATION
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function sysaux_usage() {
	. ~/entorn_$db_name
	sqlplus -s / as sysdba @sys_aux_usage.sql
}

function archiver_usage() {
	local total=0;
	local used=0;
	case "$arc_type" in
		"FS")
			arc_usage=`df -h | grep $arc_name | awk '{print $5}' | tr -d %`
			;;
		"ASM")
			arc_usage=`df -h | grep $arc_name | awk '{print $5}' | tr -d %`
			. ~/entorn_$grid_env
			total=`asmcmd -p lsdg $arc_name | grep $arc_name | awk '{print $7}'`;
			used=`asmcmd -p lsdg $arc_name | grep $arc_name | awk '{print $8}'`;
			arc_usage=$(((($total - $used) * 100) / $total));
			;;
		*)
			echo "ERROR PARSING ARCHIVER STORAGE TYPE"
			exit 1
	esac
}

function orphan_counter() {
	. ~/entorn_$db_name
	orphan_qty=`sqlplus -s / as sysdba @get_orphans_count.sql`;
	if [ -z $orphan_qty ];
	then
		orphan_qty=0;
	fi;
}

function run_bkp() {
      $dp_bin -oracle8_list $dp_string -barmode -full > $script_home/logs/dp_bkp_$db_name_`date '+%d%m%y-%H%M'`.log 2>&1;
      bkp_out=$?;
}

function delete_orphans() {
 . ~/entorn_$db_name
 sqlplus -s / as sysdba @purge.sql;
}

function shrink_tables() {
 . ~/entorn_$db_name
 sqlplus -s / as sysdba @shrink_tables.sql;

}

function send_mail(){
	echo "Error! $db_name_$HOSTNAME" | mail -s "$db_name-$HOSTNAME" hpscrbri ;
}

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#					MAIN STARTS
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++





#
# GET QUANTITY OF ORPHAN ROWS
#

orphan_counter
echo "* Quantity of orphan rows is: $orphan_qty";
if [ $orphan_qty -gt 0 ];
then
	echo "* SYSAUX usage before start is:";
	sysaux_usage
	echo "* Running backup before start";
	run_bkp
	if [ $bkp_out -eq 0 ];
	then
		bandera=0;
		echo "----------------------------------------------------------------------------";
		echo "Starting SYSAUX purge at `date`";
		echo "----------------------------------------------------------------------------";
	else
		bandera=1;
		send_mail
		echo "----------------------------------------------------------------------------";
		echo "!ERROR. Can't proceed, the backup has failed";
		echo "----------------------------------------------------------------------------";
	fi;

	while [ $bandera -eq 0 ];
	do
		let count++;
		echo "	+ Deleting orphan rows Fase: $count";
		echo "";
		delete_orphans
		orphan_counter
		archiver_usage	
		echo "";
		echo "		. Archiver destination usage is: $arc_usage% and there is `echo $orphan_qty|xargs` orphan rows";
		echo "";
		#
		#	ANALIZE FS USAGE (RUN BACKUP IF NECESSARY AND VERIFY BKP RETURN VALUE)
		#

		if [ $arc_usage -gt 50 ];
		then
			run_bkp

			#
			# CHECK IF BACKUP WAS OK ( RETURN STATUS 0) OTHERWISE FORCE EXIT
			#

	                if [ $bkp_out -eq 0 ];
       		        then
                        	archiver_usage	
                	else
                        	bandera=1;
				archiver_usage	
				send_mail
				echo "		. !ERROR making backup. The archiver now is: $arc_usage. Bandera is: $bandera";
                	fi;
			echo "		. Backup was running. Exit status was: $bkp_out. The archiver now is: $arc_usage. Bandera is: $bandera";
			echo "";
		fi;

		#
		# ANALIZE QTY OF ORPHAN ROWS (IF 0 FORCE EXIT) AND RUN BKP FOR FREE ARCHIVER DEST
		#
		
		if [ $orphan_qty -eq 0 ];
		then
			bandera=1;	
			echo "		. The orphan quantity is: `echo $orphan_qty|xargs`. Bandera is: $bandera";
			echo "";
			run_bkp
			if [ $bkp_out -eq 0 ];
                        then
                                archiver_usage
                        	echo "          . Backup before shrink tables. Exit status was: $bkp_out. The archiver now is: $arc_usage. ";
                        	echo "";
                        else
                                archiver_usage
                                echo "          . !ERROR making backup before shrink tables. The archiver now is: $arc_usage.";
				send_mail
                        fi;


		fi;	
	
	done;	
	
	#
	# SHRINK TABLES
	#
	if [ $orphan_qty -eq 0 ] && [ $count -gt 0 ];
	then
		echo "";
		echo "	+ Shrinking tables";
		echo "";
		shrink_tables
		run_bkp
                if [ $bkp_out -eq 0 ];
                then
                       archiver_usage
		       echo "";
                       echo "          	. Backup after shrink tables. Exit status was: $bkp_out. The archiver now is: $arc_usage.";
                       echo "";
                else
                       archiver_usage
                       echo "          . !ERROR making backup after shrink tables. The archiver now is: $arc_usage.";
			send_mail
                fi;

		echo "----------------------------------------------------------------------------";
		echo "End SYSAUX purge operation at `date`";
		echo "----------------------------------------------------------------------------";
		echo "";
		echo "* SYSAUX usage after purge is:";
		sysaux_usage
	fi;
		
else
	echo "No orphan rows exists";
fi;
