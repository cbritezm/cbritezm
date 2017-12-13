#---------------------------------------#
#										#
#	GET USER ENCRYPTED PASSWORD			#
#										#
#---------------------------------------#

select
   dbms_metadata.get_ddl('USER', '&&username') || '/' usercreate
from
   dba_users;
   

   
#---------------------------------------#
#										#
#		RESET USER  PASSWORD			#
#										#
#---------------------------------------#
   
select
'alter user "'||username||'" identified by values '''||extract(xmltype(dbms_metadata.get_xml('USER',username)),'//USER_T/PASSWORD/text()').getStringVal()||''';'  old_password
from
   dba_users
where
username = '&&SAGA';
