#!/bin/bash

export cls=$1

[[ $PSC_RUN_COMMON != yes ]] && source /opt/psc/desktop/common.sh


for hst in ${hosts[@]};do
	echo ">>>> Copying my public key to $hst ${host_ip[$hst]}"
	ssh-copy-id ${host_ip[$hst]}
	ssh ${host_ip[$hst]} "echo 'geldim'; exit;"
	echo ">>>>>>> Done $hst"
done
