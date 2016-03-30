create or replace
  procedure truncate_partition(
                               p_owner varchar2,
                               p_tbl   varchar2,
                               p_ts    timestamp,
                               p_opt   number
                              )
    is
        v_high_val  timestamp;
    begin
        for v_rec in (select partition_name,high_value,PARTITION_POSITION from dba_tab_partitions where table_owner = p_owner and table_name = p_tbl) loop
          if v_rec.high_value != 'MAXVALUE' and v_rec.PARTITION_POSITION != 1
            then
              execute immediate 'begin :1 := ' || v_rec.high_value || '; end;'
                using out v_high_val;
              if v_high_val < p_ts
                then
                if p_opt = 1 then
                  dbms_output.put_line(p_tbl || ':' || v_rec.partition_name);
                elsif p_opt = 2 then
                  dbms_output.put_line('ALTER TABLE ' || p_owner || '.' || p_tbl || ' TRUNCATE PARTITION ' || v_rec.partition_name);
                  execute immediate 'ALTER TABLE ' || p_owner || '.' || p_tbl || ' TRUNCATE PARTITION ' || v_rec.partition_name;
                  commit;
                elsif p_opt = 3 then
                  dbms_output.put_line('ALTER TABLE ' || p_owner || '.' || p_tbl || ' DROP PARTITION ' || v_rec.partition_name);
                  execute immediate 'ALTER TABLE ' || p_owner || '.' || p_tbl || ' DROP PARTITION ' || v_rec.partition_name;
                  commit;
                end if;
              end if;
          end if;
        end loop;
end;
/ 