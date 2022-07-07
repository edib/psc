#!/bin/bash

export cls=$1

[[ $PSC_RUN_COMMON != yes ]] && source /opt/psc/desktop/common.sh


pgv=${cluster_role_version[$cls]}

for hst in ${hosts[@]};do
	
	[[ "${host_role[$hst]}" ]] || (echo 'This host does not have any role, exits'; exit 1; )
	
	rl=${host_role[$hst]}
	
	if [[ "$rl" =~ "pgserver" ]]; then
		cecho ">>>>>>>>>install postgresql-${pgv} $hst"
		ssh ${host_ip[$hst]} "sudo -S apt-get -y -q install 'postgresql-${pgv}'"
		ssh ${host_ip[$hst]} "sudo -S apt-get -y -q install postgresql-contrib"
	
		echo ">>>>>>>>>stop cluster postgresql@${pgv}-main $hst"
		ssh ${host_ip[$hst]} "sudo -S systemctl stop 'postgresql@${pgv}-main'"
		
		echo ">>>>>>>>>drop cluster postgresql@${pgv}-main $hst"
		ssh ${host_ip[$hst]} "sudo -S pg_dropcluster '${pgv}' main"
		
		cecho ">>>>>>>>>install patroni $hst"
		ssh ${host_ip[$hst]} "sudo -S apt-get -y -q install patroni"
		ssh ${host_ip[$hst]} "sudo -S systemctl stop patroni"
		ssh ${host_ip[$hst]} "sudo -S sed -i 's/^#ExecStartPre/ExecStartPre/g' /lib/systemd/system/patroni.service"
		ssh ${host_ip[$hst]} "sudo -S systemctl daemon-reload"
		ssh ${host_ip[$hst]} "sudo -S touch /etc/patroni/config.yml"
		ssh ${host_ip[$hst]} "sudo -S chown postgres:postgres /etc/patroni/config.yml"
	fi
done
echo "Done"
exit