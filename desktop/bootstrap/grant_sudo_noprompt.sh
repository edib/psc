#!/bin/bash

export cls=$1

[[ $PSC_RUN_COMMON != yes ]] && source /opt/psc/desktop/common.sh

cecho ">>>>>>>>>grant sudo no prompt $hst"


for hst in ${hosts[@]};do
	
	ssh ${host_ip[$hst]} "sudo -S -s -u root  eval 'echo \"%pgdb ALL=(ALL) NOPASSWD: ALL\" > /etc/sudoers.d/pgdb' "   
	
done