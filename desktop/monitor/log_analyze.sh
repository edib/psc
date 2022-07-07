#!/bin/bash


export PSC_SESSION_DIR=$(mktemp -d -t pcs.XXXXXXXXXX)
echo "Temp directory is ${PSC_SESSION_DIR}"
trap  " echo 'Exiting'; rm -rf  ${PSC_SESSION_DIR}; unset PSC_SESSION_DIR " EXIT

[[ $PSC_RUN_COMMON != yes ]] && source /opt/psc/private/common.sh

#sudo apt-get install libjson-xs-perl

echo "Enter..."
echo "...hostname:" &&  read hst
echo "...cluster name:" &&  read cls
echo "...cluster version:" &&  read pv
echo "...year:" &&  read year
echo "...month:" &&  read month
echo "...day:" &&  read day
echo "...hour:" &&  read hour

clogdir="${host_path_log[$hst]}/${cls}_${pv}"
logfile="postgresql-${year}-${month}-${day}_${hour}_00_00.l.csv"
logpath="${clogdir}/${logfile}"
echo "Log file:${logpath}"
locallog=${desktop_dir_temp}/${logfile}
echo "Local log file:${locallog}"

ssh $hst "sudo -S cat ${logpath}" > ${locallog}

pgbadger -j 4 $locallog

echo "Success"
exit