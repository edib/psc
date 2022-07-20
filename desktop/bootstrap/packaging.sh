#!/bin/bash

export cls=$1

[[ $PSC_RUN_COMMON != yes ]] && source /opt/psc/desktop/common.sh


for hst in ${hosts[@]};do
	cecho "Checking packaging ${host_path[$hst]}/packaging.sh"
	if [ -f "${host_path[$hst]}/packaging.sh" ]; then
		echo "custom packaging exists"
		scp "${host_path[$hst]}/packaging.sh" @"$hst:/tmp/packaging.sh"
		ssh ${host_ip[$hst]} "sudo -S bash /tmp/packaging.sh"
	fi
	ssh ${host_ip[$hst]} "sudo -S apt update"
	echo "Done"
done


exit