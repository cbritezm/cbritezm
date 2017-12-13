----------------------------------------------------------------------------------------
--ORA-01000 maximum open cursors exceeded
----------------------------------------------------------------------------------------

-- see detailed information about opened cursors at the moment
----------------------------------------------------------------------------------------


SELECT * FROM v$open_cursor;


-- count of all currently opened cursors and cumulative amount
----------------------------------------------------------------------------------------

SELECT N.NAME, S.VALUE 
FROM V$STATNAME N , V$SYSSTAT S
WHERE N.STATISTIC# = S.STATISTIC# AND S.STATISTIC# in (2,3);


-- display a list of unique cursors within a session that are opened multiple times
----------------------------------------------------------------------------------------

-- ** Usually due to the client opening a cursor, using it (iterating through the cursor until end-of-cursor) and not closing it. 
-- ** Then it proceeds to use the same cursor again (with different criteria for the predicate bind variables) and repeat the process. 
--You will typical find this an issue with clients using ref cursors.

SELECT C.SID AS "OraSID",C.ADDRESS || ':' || C.HASH_VALUE AS "SQL Address",COUNT(C.SADDR) AS "Cursor Copies"
FROM V$OPEN_CURSOR C
GROUP BY C.SID, C.ADDRESS || ':' || C.HASH_VALUE
HAVING COUNT(C.SADDR) > 2
ORDER BY 3 DESC;


-- report the current maximum usage 
----------------------------------------------------------------------------------------

-- **SESSION_CACHED_CURSORS lets you specify the number of session cursors to cache.
-- **Repeated parse calls of the same SQL statement cause the session cursor for that statement to be moved into the session cursor cache. 
-- **Subsequent parse calls will find the cursor in the cache and do not need to reopen the cursor and even do a soft parse.

-- ***If either of the Usage column figures approaches 100%, then the corresponding parameter should normally be increased.


SELECT 'session_cached_cursors'  parameter,LPAD(value, 5)  value,DECODE(value, 0, '  n/a', to_char(100 * used / value, '990') || '%')  usage
FROM
  (SELECTMAX(s.value)  used
   FROM v$statname  n,v$sesstat  s
   WHERE n.name = 'session cursor cache count' and s.statistic# = n.statistic#
   ),
  (SELECT value
    FROM v$parameter
    WHERE name = 'session_cached_cursors'
  )
UNION ALL
SELECT 'open_cursors', LPAD(value, 5), to_char(100 * used / value,  '990') || '%'
FROM
  (SELECT MAX(sum(s.value))  used
    FROM v$statname  n,v$sesstat  s
    WHERE n.name in ('opened cursors current', 'session cursor cache count') and s.statistic# = n.statistic#
    GROUP BY s.sid
  ),
  (SELECT value
    FROM v$parameter
    WHERE name = 'open_cursors'
  )
;

-- Get userid cursor info
----------------------------------------------------------------------------------------

SELECT b.SID, UPPER(a.NAME), b.VALUE
FROM v$statname a, v$sesstat b, v$session c
WHERE a.statistic# = b.statistic# AND c.SID = b.SID AND LOWER(a.NAME) LIKE '%' || LOWER('CURSOR')||'%'AND b.SID=&USERID
UNION
SELECT SID,  'v$open_cursor opened cursor', COUNT(*)
FROM v$open_cursor
WHERE SID=&&USERID
GROUP BY SID
ORDER BY SID
;


-- percentage distribution between hard and soft parses and total parse calls satisfied by the session cursor cache.
----------------------------------------------------------------------------------------

SELECT TO_CHAR(100 * sess / calls, '999999999990.00') || '%' cursor_cache_hits,TO_CHAR (100 * (calls - sess - hard) / calls, '999990.00') || '%' soft_parses,TO_CHAR (100 * hard / calls, '999990.00') || '%' hard_parses
FROM
  (SELECT value calls FROM v$sysstat WHERE name = 'parse count (total)' ),
  (SELECT value hard  FROM v$sysstat WHERE name = 'parse count (hard)' ),
 (SELECT value sess  FROM v$sysstat WHERE name = 'session cursor cache hits' )
;


--cursors opened by all session connected to the database
----------------------------------------------------------------------------------------

ttitle 'Per Session Current Cursor Usage '
column USER_PROCESS format a25;
column "Recursive Calls" format 999,999,999;
column "Opened Cursors"  format 99,999; 
column "Current Cursors"  format 99,999;
SELECT  ss.username||'('||se.sid||') ' user_process, SUM(DECODE(name,'recursive calls',value)) "Recursive Calls", SUM(DECODE(name,'opened cursors cumulative',value)) "Opened Cursors", SUM(DECODE(name,'opened cursors current',value)) "Current Cursors"
FROM v$session ss, v$sesstat se, v$statname sn
WHERE  se.statistic# = sn.statistic# AND (name like '%opened cursors current%' OR name like '%recursive calls%' OR name like '%opened cursors cumulative%') AND se.sid = ss.sidAND ss.username is not null
GROUP BY ss.username||'('||se.sid||') ';

-- number of open cursors per user/SID
----------------------------------------------------------------------------------------

COLUMN user_name    heading Username
COLUMN num          heading "Open Cursors"
SET lines 80 pages 59
SELECT user_name, sid,COUNT (*) num
FROM v$open_cursor
GROUP BY user_name,sid;


