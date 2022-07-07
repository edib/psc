#!/bin/bash

export cls=$1

[[ $PSC_RUN_COMMON != yes ]] && source /opt/psc/desktop/common.sh

cecho ">>>>>>>>>etchosts $hst"

#friends=(${host_friends[$hst]})

cecho ">>>>>>>>>Prepare etc hosts file"
etchosts="${PSC_SESSION_DIR}/etchosts.tmp"
echo "##PCSSTART" > ${etchosts}
for ahst in ${hosts[@]}; do
	echo "${host_ip[$ahst]} $ahst" >> ${etchosts}
done
echo "##PCSEND" >> ${etchosts}


for hst in ${hosts[@]};do
	
	cecho ">>>>>>>>>Generate etc hosts file from prepared etc hosts file"
	scp ${etchosts} @${host_ip[$hst]}:/tmp/etchost.tmp
	ssh ${host_ip[$hst]} 'sudo -S -s -u root  eval "cat /tmp/etchost.tmp >> /etc/hosts"'
	
done