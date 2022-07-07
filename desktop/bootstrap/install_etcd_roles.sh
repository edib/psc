#!/bin/bash

export cls=$1

[[ $PSC_RUN_COMMON != yes ]] && source /opt/psc/desktop/common.sh

for hst in ${hosts[@]};do
	
	[[ "${host_role[$hst]}" ]] || (echo 'This host does not have any role, exits'; exit 1; )
	
	rl=${host_role[$hst]}
	
	if [[ "$rl" =~ "etcd" ]]; then
		cecho "Installing etcd at host: $hst"
		ssh ${host_ip[$hst]} "sudo -S apt-get -q -y install etcd-server"
		ssh ${host_ip[$hst]} "sudo -S systemctl stop etcd"
		ssh ${host_ip[$hst]} "sudo -S chgrp postgres /etc/default/etcd"
		ssh ${host_ip[$hst]} "sudo -S chmod g+w /etc/default/etcd"

		ip=${host_ip[$hst]};

		tmpfile=${PSC_SESSION_DIR}/etcd.tmp
	
		echo "Generating etcd configuration in: $tmpfile"
		echo "ETCD_NAME=\"$hst\"" > $tmpfile
		echo "ETCD_INITIAL_CLUSTER_TOKEN=\"etcd-welcome\"" >> $tmpfile
		echo "ETCD_DATA_DIR=\"/var/lib/etcd/pcs\"" >> $tmpfile
		
		echo "ETCD_INITIAL_ADVERTISE_PEER_URLS=\"http://${ip}:2380\"" >> $tmpfile
		echo "ETCD_LISTEN_PEER_URLS=\"http://${ip}:2380\"" >> $tmpfile
		
		echo "ETCD_ADVERTISE_CLIENT_URLS=\"http://${ip}:2379\""  >> $tmpfile 
		echo "ETCD_LISTEN_CLIENT_URLS=\"http://${ip}:2379,http://localhost:2379\"" >> $tmpfile
		
		echo "ETCD_INITIAL_CLUSTER=\"$(find_etcd_hosts_with_name)\"" >> $tmpfile
		echo "ETCD_INITIAL_CLUSTER_STATE=\"new\"" >> $tmpfile
		echo "ETCD_DEBUG=true" >> $tmpfile
		
		
		scp $tmpfile ${host_ip[$hst]}:/tmp/etcd.tmp
		echo "Appending etcd configuration to: /etc/default/etcd"
		ssh ${host_ip[$hst]} "sudo -S -u root -s eval 'cat /tmp/etcd.tmp >> /etc/default/etcd'"
		ssh ${host_ip[$hst]} "sudo -S systemctl enable etcd"
		ssh ${host_ip[$hst]} "sudo -S systemctl start etcd"
		echo "Done"
	fi
	echo "Done all"
done

exit