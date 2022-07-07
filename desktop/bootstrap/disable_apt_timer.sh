#!/bin/bash

export cls=$1

[[ $PSC_RUN_COMMON != yes ]] && source /opt/psc/desktop/common.sh


for hst in ${hosts[@]};do
	
	cecho ">>>>>>>>>Disable apt daily services for $hst in cluster $cls"
	echo ${host_ip[$hst]} 
	ssh ${host_ip["$hst"]}  'sudo -S systemctl disable --now apt-daily{,-upgrade}.{timer,service}'
	ssh ${host_ip["$hst"]}  'sudo -S apt -q -y remove unattended-upgrades'
	
done

