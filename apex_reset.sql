--------------------------------------------------------------------------------
--              Apex user reset 
--------------------------------------------------------------------------------


-- Get user info
--------------------------------------------------------------------------------

User table: APEX_040200.WWV_FLOW_FND_USER (apex users and workspace)  --> col: security_group_id (default group id of admin: 10). 
                
select security_group_id,USER_ID,USER_NAME,ACCOUNT_LOCKED,to_char(LAST_FAILED_LOGIN,'DD/MM/YYYY HH24:MI:SS') as LAST_FAILED,to_char(LAST_UPDATE_DATE,'DD/MM/YYYY HH24:MI:SS') as LAST_UPDATE from APEX_040200.WWV_FLOW_FND_USER where user_name = 'ADMIN';

--Reset password
--------------------------------------------------------------------------------

1.	En la documentación de oracle indica se que:
Run apxchpwd.sql from $ORACLE_HOME/apex. 

If doesn't work: run this

## http://oracle-noob.blogspot.com/2014/05/unlock-apex-admin-user.html

update APEX_040200.WWV_FLOW_FND_USER set web_password = 'password' where user_name = 'ADMIN' and user_id = 56502607595642;
commit;

2.	Unlock the account
alter session set current_schema = APEX_040200;
begin
wwv_flow_security.g_security_group_id := 10;
wwv_flow_fnd_user_api.UNLOCK_ACCOUNT('ADMIN');
commit;
end;


