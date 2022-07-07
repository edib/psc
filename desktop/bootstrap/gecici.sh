#!/bin/bash

export cls=$1

[[ $PSC_RUN_COMMON != yes ]] && source /opt/psc/desktop/common.sh


for hst in ${hosts[@]};do
	
	cecho ">>>>>>>>>Install ctpl"
	ssh ${host_ip[$hst]}  "sudo -S apt-get -q -y install ctpl"
	
done