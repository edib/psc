#!/bin/bash

export cls=$1

[[ $PSC_RUN_COMMON != yes ]] && source /opt/psc/desktop/common.sh

for hst in ${hosts[@]};do
	
	echo "Restart service at $hst: psc-conf-updater"
	ssh ${host_ip[$hst]}  "sudo -S systemctl restart psc-conf-updater"
	
done

exit