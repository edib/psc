#!/bin/bash


export cls=$1

[[ $PSC_RUN_COMMON != yes ]] && source /opt/psc/desktop/common.sh


for hst in ${hosts[@]};do
	echo "Getting host public keys"
	scp "${host_ip[$hst]}:/var/lib/psc/id_rsa.pub" "${PSC_SESSION_DIR}/$hst" 
done

echo "Generating and putting authorized keys"
for hst in ${hosts[@]};do
	echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
	echo ">>>>>>>>>>>>>>$hst"
	#[[ "${host_friends[$hst]}" ]] || (echo 'This host does not belogn to any cluster, exits'; exit 1; )
	
	
	authorized_keys="${PSC_SESSION_DIR}/authorized_keys.${hst}"
	
#	cat "${PSC_SESSION_DIR}/$hst"  >> "$authorized_keys"
	
	for h in "${hosts[@]}"; do
		cat "${PSC_SESSION_DIR}/$h"  >> "$authorized_keys"
	done
	
	echo "Copying authorized keys for $hst"
	scp ${authorized_keys} "${host_ip[$hst]}:/tmp/authorized_keys"
	echo "Copying authorized keys done"
	ssh ${host_ip[$hst]} "sudo -S cp /tmp/authorized_keys /var/lib/postgresql/.ssh/authorized_keys; sudo -S chmod 644 /var/lib/postgresql/.ssh/authorized_keys; sudo -S chown postgres:postgres /var/lib/postgresql/.ssh/authorized_keys" 

done

#echo "Verifying host access"
#for hst in ${hosts[@]};do
#	echo "Verifying host access for host $hst"
#	ssh ${host_ip[$hst]} "sudo -S -u postgres /opt/psc/bootstrap/verifyhostkeys.sh" 
#done