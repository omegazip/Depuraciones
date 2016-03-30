SET TERMOUT     OFF
SET ECHO        OFF
SET FEEDBACK    OFF
SET HEADING     ON
SET LINESIZE    180
SET PAGESIZE    50000
SET TERMOUT     ON
SET TIMING      OFF
SET TRIMOUT     ON
SET TRIMSPOOL   ON
SET VERIFY      OFF
set serveroutput on

CLEAR COLUMNS
CLEAR BREAKS
CLEAR COMPUTES

spool &1;
exec truncate_partition('&2','&3',ADD_MONTHS(sysdate - (to_number(to_char(SYSDATE,'DD'))-1), -3),&4);
spool off;
exit