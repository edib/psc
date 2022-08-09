#!/bin/bash


export cls=$1

[[ $PSC_RUN_COMMON != yes ]] && source /opt/psc/desktop/common.sh

echo "------"
for hst in ${hosts[@]};do
	echo "try $hst"
	ssh ${host_ip[$hst]} echo "hello $hst ok"
	echo "------"  
done

