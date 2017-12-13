set echo off verify off showmode off feedback off;
prompt En el directorio actual se creara el archivo hints_SCHEMA.lst
prompt
prompt Seleccione el esquema donde se realizara la busqueda de los hints
prompt -----------------------------------------------------------------  
prompt
prompt &&schema

begin
  if '&&schema' is null then
    raise_application_error(-20101, 'Debe especificar el esquema.');
  end if;
end;
/

set lines 125
set pages 30
col owner format a10
col name format a20
col text format a85
col line format a5

spool hints_&schema

select owner,name,to_char(line) line,text
  from dba_source
 where owner= upper('&schema')
   and regexp_like(text,'(select|update|insert|delete)*./\*\+.*(all_rows|first_rows|first_rows_1|first_rows_100|choose|rule|full|rowid|cluster|hash|hash_aj|index|no_index|index_asc|index_combine|index_join|index_desc|index_ffs|no_index_ffs|index_ss|index_ss_asc|index_ss_desc|no_index_ss|no_query_transformation|use_concat|no_expand|rewrite|norewrite|no_rewrite|merge|no_merge|fact|no_fact|star_transformation|no_star_transformation|unnest|no_unnest|leading|ordered|use_nl\*/)','i');

select owner,name,to_char(line) line,text
  from dba_source
 where owner= upper('&schema')
   and regexp_like(text,'(select|update|insert|delete)*./\*\+.*(no_use_nl|use_nl_with_index|use_merge|no_use_merge|use_hash|no_use_hash|parallel|noparallel|no_parallel|pq_distribute|no_parallel_index|noparallel_index|append|noappend|cache|nocache|push_pred|no_push_pred|push_subq|no_push_subq|qb_name|cursor_sharing_exact|driving_site|dynamic_sampling|spread_min_analysis|merge_aj|and_equal|star|bitmap|hash_sj|nl_sj|nl_aj|ordered_predicates|expand_gset_to_un\*/)','i');

undefine schema

spool off

set echo on feedback on;
