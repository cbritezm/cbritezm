echo "Seleccione el tipo de objeto para realizar la busqueda de hints..."
echo "1) form..."
echo "2) menu..."
echo "3) report..."
echo "4) library..."
echo ""
echo -n "Seleccione una opcion: "

read obj

echo " "

if [ "$obj" ]
then
  case $obj in
    1) type=form
       ext=fmb
    ;; 
    2) type=menu
       ext=mmb
    ;;
    3) type=report
       ext=rdf
    ;;
    4) type=library
       ext=pll
    ;;
    *)
      echo "Opcion Invalida..."
      break
      exit
  esac
else
  echo "Debe seleccionar uno de los numeros indicados en el menu..."
  break
  exit
fi

echo "$type"

echo " "

echo -n "Ingrese el path de los fuentes: "
read path

echo " "

if [ "$path" ]
then
  echo "Path : $path"
else
  echo "Debe indicar el path de los fuentes..."
  break
  exit
fi

egrep -ai "(select|insert|update|delete)*./\*\+.*(all_rows|first_rows|first_rows_1|first_rows_100|choose|rule|full|rowid|cluster|hash|hash_aj|index|no_index|index_asc|index_combine|index_join|index_desc|index_ffs|no_index_ffs|index_ss|index_ss_asc|index_ss_desc|no_index_ss|no_query_transformation|use_concat|no_expand|rewrite|norewrite|no_rewrite|merge|no_merge|fact|no_fact|star_transformation|no_star_transformation|unnest|no_unnest|leading|ordered|use_nl|no_use_nl|use_nl_with_index|use_merge|no_use_merge|use_hash|no_use_hash|parallel|noparallel|no_parallel|pq_distribute|no_parallel_index|noparallel_index|append|noappend|cache|nocache|push_pred|no_push_pred|push_subq|no_push_subq|qb_name|cursor_sharing_exact|driving_site|dynamic_sampling|spread_min_analysis|merge_aj|and_equal|star|bitmap|hash_sj|nl_sj|nl_aj|ordered_predicates|expand_gset_to_un\*/)" $path/*.$ext > $path/hints_$type.txt

echo " "

if [ -f $path/hints_$type.txt ] 
then
  echo "   ==> $path/hints_$type.txt CREADO "  
else
  echo "   ====> $path/hints_$type.txt NO CREADO <==== "
fi 
