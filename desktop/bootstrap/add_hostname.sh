#!/bin/bash

export cls=$1

[[ $PSC_RUN_COMMON != yes ]] && source /opt/psc/desktop/common.sh


for hst in ${hosts[@]};do
	echo ">>>> Copy hostname to $hst"
	ssh $hst "sudo -S cp /etc/hosts  /tmp/siletchosts"
	ssh $hst "sudo -S -s eval \"echo '${host_ip[$hst]} $hst'	  > /etc/hosts\""
	ssh $hst "sudo -S -s eval 'cat /tmp/siletchosts >> /etc/hosts'"
done