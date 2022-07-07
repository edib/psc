#!/bin/bash

export cls=$1

[[ $PSC_RUN_COMMON != yes ]] && source /opt/psc/desktop/common.sh

for hst in ${hosts[@]};do
	
	[[ "${host_role[$hst]}" ]] || (echo 'This host does not have any role, exits'; exit 1; )
	
	rl=${host_role[$hst]}
	
	if [[ "$rl" =~ "gate" ]]; then
		cecho ">>>>>>>>>install haproxy on $hst"
		ssh ${host_ip[$hst]} "sudo -S apt-get -q -y install haproxy"
		ssh ${host_ip[$hst]} "sudo -S chmod g+w /etc/haproxy/haproxy.cfg "
		ssh ${host_ip[$hst]} "sudo -S chgrp postgres /etc/haproxy/haproxy.cfg"
		ssh ${host_ip[$hst]} "sudo -S systemctl enable haproxy"
		ssh ${host_ip[$hst]} "sudo -S systemctl start haproxy"
		
		
		cecho ">>>>>>>>>install pgbouncer on $hst"
		ssh ${host_ip[$hst]} "sudo -S apt-get -q -y install pgbouncer postgresql-client"
		ssh ${host_ip[$hst]} "sudo -S touch /etc/pgbouncer/pg_hba.conf"
		ssh ${host_ip[$hst]} "sudo -S chown postgres:postgres /etc/pgbouncer/*"
		ssh ${host_ip[$hst]} "sudo -S systemctl enable pgbouncer"
		ssh ${host_ip[$hst]} "sudo -S systemctl restart pgbouncer"
	fi
	echo "Done all"
done
