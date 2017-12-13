#!/bin/bash
	cd /root/home/hpscrbri/cbritez/read_mail
	day=$(date +'%A');
	mail_q=0;
	f_name="log_mail.txt";
	if [ $day == "Friday" ];
	then
		while read line
		do
			mail_q=$(ssh -n -q ${line} 'grep -e "^Subject: " /var/spool/mail/hpscrbri | wc -l' 2>&1);
			if [ $mail_q -gt 0 ];
			then
				ssh -n -q $line mail -H | awk '{print $10}'  2>&1 >> log_mail.txt;
			#	ssh -n -q $line cat /var/spool/mail/hpscrbri | grep Subject | awk '{print $2}'  2>&1 >> log_mail.txt;
				ssh -n -q $line 'echo "d *" | mail'>>/dev/null;
			fi;
		done<hosts.lst;

		echo "				++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++";
		echo "							TODAY THE SYSAUX PURGE MUST RUN. THE RESULT IS BELOW			";
		echo "				++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++";
		if [ -e "$f_name" ];
		then
			
			while read line
			do
				echo "								Please Verify: 		`echo $line| tr -d '"'`";
			done<log_mail.txt
		else
			echo "							NO ERRORS FOUND IN THE PURGE OPERATION";
		fi
	fi
