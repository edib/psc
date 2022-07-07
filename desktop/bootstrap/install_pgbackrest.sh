#!/bin/bash

export cls=$1

[[ $PSC_RUN_COMMON != yes ]] && source /opt/psc/desktop/common.sh


for hst in ${hosts[@]};do
	
	[[ "${host_role[$hst]}" ]] || (echo 'This host does not have any role, exits'; exit 1; )
	
	rl=${host_role[$hst]}
	
	if [[ "$rl" =~ "pgserver" || "$rl" =~ "backup" ]]; then
		cecho ">>>>>Install pgbackrest $hst"
		ssh ${host_ip[$hst]} "sudo -S apt-get -q -y install pgbackrest"
		echo ">>>>> make owner of pgbackrest.conf file postgres"
		ssh ${host_ip[$hst]} "sudo -S chown postgres:postgres /etc/pgbackrest.conf"
	fi
	echo "Done all"
done