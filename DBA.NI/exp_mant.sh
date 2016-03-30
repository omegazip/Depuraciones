#!/bin/bash

function create_dir_mant(){
path_act=`pwd`
cd ${part_path}
rm current
name_dir=`date +"%Y%m%d"`
mkdir ${name_dir}
ln -s ${name_dir} current
cd ${path_act}
}

function comp(){
gzip ${part_path}*dmp
}

function exportar(){
expdp parfile=${1}.${2}.ctl
comp
}

function create_ctl(){

#Se pide lista de tablas con su particion para crear el ctl (opcion 1)
echo exit | sqlplus '/ as sysdba' @exp_mant.sql exp_mant.out ${part_schema} ${2} 1
part_num=`cat exp_mant.out|wc -l`

echo "USERID=${part_schema}/${part_pass}" > ${1}.${2}.ctl
echo "DUMPFILE=${part_dir}:${1}.${2}.dmp" >> ${1}.${2}.ctl
echo "LOGFILE=${part_dir}:${1}.${2}.log" >> ${1}.${2}.ctl
echo "TABLES=" >> ${1}.${2}.ctl

if [ "${part_num}" = "0" ]; then
        rm -f ${1}.${2}.ctl
else
        if [ "${part_num}" != "1" ]; then
                sed '$d' exp_mant.out|sed -n '{1,$ s/$/, /p}' >> ${1}.${2}.ctl
                sed -n '$ p' exp_mant.out >> ${1}.${2}.ctl
                rm -f exp_mant.out
        else
                cat exp_mant.out >> ${1}.${2}.ctl
                rm -f exp_mant.out
        fi
fi
}

function list_tables(){
part_lst=`cat exp_mant.lst|wc -l`
a=0

until [ ! $a -lt ${part_lst} ]
do
   a=`expr $a + 1`
   #part_order es solo el incremental de la tabla a dar mantenimiento
   part_order=`sed -n ''"$a"' p' exp_mant.lst|awk '{print $1}'`
   #part_table es el nombre de la tabla a dar mantenimiento
   part_table=`sed -n ''"$a"' p' exp_mant.lst|awk '{print $2}'`
   #part_manipul indica si todos los indices se la tabla estan particionados para poder realizar truncate y drop a la particion
   part_manipul=`sed -n ''"$a"' p' exp_mant.lst|awk '{print $3}'`
   create_ctl ${part_order} ${part_table}
   if [ -e ${part_order}.${part_table}.ctl ]; then
        exportar ${part_order} ${part_table}
        part_exp_status=`grep "terminado correctamente" ../depuracion/current/${part_order}.${part_table}.log|wc -l`
        if [ "${part_exp_status}" = "1" ]; then
            if [ "${part_manipul}" = "a" ]; then
                #Se manda a truncar la particion
                echo exit | sqlplus '/ as sysdba' @exp_mant.sql exp_mant.out ${part_schema} ${part_table} 2
                #Se manda a dropear la particion
                echo exit | sqlplus '/ as sysdba' @exp_mant.sql exp_mant.out ${part_schema} ${part_table} 3
            fi
        fi
   fi
done
}


part_schema=`sed -n '1 p' exp_mant.conf`
part_pass=`sed -n '2 p' exp_mant.conf`
part_dir=`sed -n '3 p' exp_mant.conf`
part_path=`sed -n '4 p' exp_mant.conf`

create_dir_mant
list_tables