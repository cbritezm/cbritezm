--------------------------------------------------------------------------------
-- ACL management
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--                  ACL VIEWS
--------------------------------------------------------------------------------

* dba_network_acl_privileges -------> Assigned privileges
* dba_network_acls -----------> acl info.

select a.acl,a.principal,a.privilege,a.is_grant,a.start_date,a.end_date,b.host,b.lower_port,upper_port 
from dba_network_acl_privileges a,dba_network_acls b 
where a.acl=b.acl;

--------------------------------------------------------------------------------
--							Create ACL					 
--------------------------------------------------------------------------------

BEGIN
  DBMS_NETWORK_ACL_ADMIN.create_acl (
    acl          => 'https_acl.xml', 
    description  => 'Connect to GSS WebService',
    principal    => 'USER_WEBLINK',
    is_grant     => TRUE, 
    privilege    => 'connect',
    start_date   => SYSTIMESTAMP,
    end_date     => NULL);

  COMMIT;
END;
/

--##############################################################
-- 				Assign privilege to ACL		
--##############################################################


BEGIN
  DBMS_NETWORK_ACL_ADMIN.add_privilege ( 
    acl         => 'https_acl.xml', 
    principal   => 'USER_WEBLINK',
    is_grant    => TRUE, 
    privilege   => 'resolve', 
    position    => NULL, 
    start_date  => NULL,
    end_date    => NULL);

  COMMIT;
END;
/

--------------------------------------------------------------------------------
--				   Assign ACL to host/service		
--------------------------------------------------------------------------------


BEGIN
  DBMS_NETWORK_ACL_ADMIN.assign_acl (
    acl         => 'https_acl.xml',
    host        => '30.32.3.15', 
    lower_port  => 3128,
    upper_port  => null); 


  COMMIT;
END;
/

--------------------------------------------------------------------------------
--					Assign WALLET to ACL					
--------------------------------------------------------------------------------

BEGIN 
  DBMS_NETWORK_ACL_ADMIN.ASSIGN_WALLET_ACL(
    acl         => 'http_acl.xml',
    wallet_path => 'file:/u01/app/certificates/test1/');
  COMMIT;
END;
/

--------------------------------------------------------------------------------
--				Delete privilege from ACL		
--------------------------------------------------------------------------------

BEGIN
  DBMS_NETWORK_ACL_ADMIN.delete_privilege ( 
    acl         => 'http_acl.xml', 
    principal   => 'USER_DBLINK',
    is_grant    => FALSE, 
    privilege   => 'resolve');
  COMMIT;
END;
/

--------------------------------------------------------------------------------
--						Test ACL				
--------------------------------------------------------------------------------

select utl_http.request('URL','PROXY/NULL','WALLET PATH','WALLET PASSWORD') FROM dual;


declare  
    lo_req    utl_http.req;  
    lo_resp   utl_http.resp;  
begin  
    utl_http.set_wallet ('file:/home/oracle/Certificates', 'Oracle123');
	utl_http.set_proxy('http://30.32.3.15:3128');
    lo_req := utl_http.begin_request ('https://clientes.grupogss.net/RACC_CallMe_AUTO/');  
    lo_resp := utl_http.get_response ( lo_req );  
    dbms_output.put_line ( lo_resp.status_code );  
    utl_http.end_response ( lo_resp );  
end;  
/ 


EX:

select utl_http.request('https://preproduccio.aplicacions.ensenyament.gencat.cat/e13_WSGIP/ComunicacioGIP?nif=#1&dataConsulta=#2&cos=#3&entorn=#4',NULL,'file:/opt/oracle/app/oracle/admin/e13bda/wallets','0r4cl3123') FROM dual@BETTY.WORLD;

https://integracio.aplicacions.ensenyament.gencat.cat/e13_WSGIP/ComunicacioGIP?nif=#1&dataConsulta=#2&cos=#3&entorn=#4



--------------------------------------------------------------------------------
--				WALLET CREATED IN RACC
--------------------------------------------------------------------------------
select acl , principal , privilege , is_grant from DBA_NETWORK_ACL_PRIVILEGES;
CREATE USER USER_WEBLINK IDENTIFIED BY W3BR4CC DEFAULT TABLESPACE TOOLS ACCOUNT UNLOCK;
Or4cl3123
/opt/oracle/app/wallet
 CREATE PUBLIC DATABASE LINK "WEBGSS.RACC" CONNECT TO "USER_WEBLINK" IDENTIFIED BY "Or4cl3123" USING 'WEBGSS.RACC'
WEBGSS.RACC =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = 30.32.63.21)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = RACC)
    )
  )3ns3ny4m3nt 
