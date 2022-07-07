#!/bin/bash
export cls=$1

[[ $PSC_RUN_COMMON != yes ]] && source /opt/psc/desktop/common.sh


cecho ">>>>>>>>>Installing PSC"

etcdhost=""
etcdhosts=""

cecho ">>>>>>>>>Copy files to /var/lib/psc"
for hst in ${hosts[@]};do
	hr="${host_role[$hst]}"
	
	echo ">>> To $hst"
	ssh ${host_ip[$hst]} "sudo -S rm -rf /tmp/psc /var/lib/psc/scripts /var/lib/psc/service /var/lib/psc/lib"
	scp -r -q /opt/psc/remote ${host_ip[$hst]}:/tmp/psc
	ssh ${host_ip[$hst]} "sudo -S mv /tmp/psc/scripts /var/lib/psc"
	ssh ${host_ip[$hst]} "sudo -S mv /tmp/psc/service /var/lib/psc"
	ssh ${host_ip[$hst]} "sudo -S mv /tmp/psc/lib /var/lib/psc"
	ssh ${host_ip[$hst]} "sudo -S chown -R postgres:postgres /var/lib/psc"
	
	ssh ${host_ip[$hst]} "sudo -S touch /var/lib/psc/${cls}.sh"
	ssh ${host_ip[$hst]} "sudo -S chown postgres:postgres /var/lib/psc/${cls}.sh"
	ssh ${host_ip[$hst]} "sudo -S chmod +x /var/lib/psc/${cls}.sh"
	
	ssh ${host_ip[$hst]} "sudo -S touch /var/lib/psc/${cls}.ctpl.env"
	ssh ${host_ip[$hst]} "sudo -S chown postgres:postgres /var/lib/psc/${cls}.ctpl.env"
	
	if [[ "${hr}" =~ "etcd" ]]; then
		etcdhost="$hst"
		if [[ "$etcdhosts" == "" ]]; then
			etcdhosts="http://$hst:2379"
		else
			etcdhosts="http://$hst:2379,${etcdhosts}"
		fi
		
	fi

	
done

cecho ">>>>>>>>>Setup  etcd store at $etcdhost"
ssh ${host_ip[$etcdhost]} "sudo -S rm -rf /tmp/psc-templates"
scp -r -q "/opt/psc/desktop/conf/clusters/${cls}/templates" "${host_ip[$etcdhost]}:/tmp/psc-templates"
ssh ${host_ip[$etcdhost]} "etcdctl rm --recursive /psc/${cls}/psc"
ssh ${host_ip[$etcdhost]} "etcdctl mkdir /psc/${cls}/psc"
ssh ${host_ip[$etcdhost]} "etcdctl mkdir /psc/${cls}/psc/templates"

ssh ${host_ip[$etcdhost]} "etcdctl mk /psc/${cls}/psc/templates/haproxy.cfg.ctpl < /tmp/psc-templates/haproxy.cfg.ctpl"
ssh ${host_ip[$etcdhost]} "etcdctl mk /psc/${cls}/psc/templates/patroni-config.yml.ctpl < /tmp/psc-templates/patroni-config.yml.ctpl"
ssh ${host_ip[$etcdhost]} "etcdctl mk /psc/${cls}/psc/templates/pgbackrest-backup-site.conf.ctpl < /tmp/psc-templates/pgbackrest-backup-site.conf.ctpl"
ssh ${host_ip[$etcdhost]} "etcdctl mk /psc/${cls}/psc/templates/pgbackrest-db-site.conf.ctpl < /tmp/psc-templates/pgbackrest-db-site.conf.ctpl"
ssh ${host_ip[$etcdhost]} "etcdctl mk /psc/${cls}/psc/templates/pgbouncer-pg_hba.conf.ctpl < /tmp/psc-templates/pgbouncer-pg_hba.conf.ctpl"
ssh ${host_ip[$etcdhost]} "etcdctl mk /psc/${cls}/psc/templates/pgbouncer.ini.ctpl < /tmp/psc-templates/pgbouncer.ini.ctpl"
ssh ${host_ip[$etcdhost]} "etcdctl mk /psc/${cls}/psc/templates/pgbouncer-userlist.txt.ctpl < /tmp/psc-templates/pgbouncer-userlist.txt.ctpl"
ssh ${host_ip[$etcdhost]} "etcdctl mk /psc/${cls}/psc/templates/pgserver-master.conf.ctpl < /tmp/psc-templates/pgserver-master.conf.ctpl"
ssh ${host_ip[$etcdhost]} "etcdctl mk /psc/${cls}/psc/templates/pgserver-replica.conf.ctpl < /tmp/psc-templates/pgserver-replica.conf.ctpl"
ssh ${host_ip[$etcdhost]} "etcdctl mk /psc/${cls}/psc/templates/pgserver-pg_hba.conf.ctpl < /tmp/psc-templates/pgserver-pg_hba.conf.ctpl"

ssh ${host_ip[$etcdhost]} "etcdctl mkdir /psc/${cls}/psc/hosts"
ssh ${host_ip[$etcdhost]} "etcdctl mk /psc/${cls}/psc/pgport ${cluster_port[$cls]}"
ssh ${host_ip[$etcdhost]} "etcdctl mk /psc/${cls}/psc/pgver ${cluster_role_version[$cls]}"
ssh ${host_ip[$etcdhost]} "etcdctl mk /psc/${cls}/psc/repo1_host ${cluster_pgbackrest_repo1[$cls]}"
ssh ${host_ip[$etcdhost]} "etcdctl mk /psc/${cls}/psc/repo2_host ${cluster_pgbackrest_repo2[$cls]}"
ssh ${host_ip[$etcdhost]} "etcdctl mk /psc/${cls}/psc/replica_user ${cluster_replica_user[$cls]}"
ssh ${host_ip[$etcdhost]} "etcdctl mk /psc/${cls}/psc/replica_user_pwd ${cluster_replica_user_pass[$cls]}"

ssh ${host_ip[$etcdhost]} "etcdctl mk /psc/${cls}/psc/auth_user ${cluster_pool_auth_user[$cls]}"
ssh ${host_ip[$etcdhost]} "etcdctl mk /psc/${cls}/psc/auth_user_pwd ${cluster_pool_auth_user_pass[$cls]}"

cecho ">>>>>>>>>Setup  etcd store for all hosts at $etcdhost"
for hst in ${hosts[@]};do
	echo ">>>for host $hst"
	ssh ${host_ip[$etcdhost]} "etcdctl mkdir /psc/${cls}/psc/hosts/$hst"
	if [ ! -z "${host_path_data[$hst]}" ]; then
		ssh ${host_ip[$etcdhost]} "etcdctl mk /psc/${cls}/psc/hosts/$hst/data_dir ${host_path_data[$hst]}"
	fi
	if [ ! -z "${host_path_log[$hst]}" ]; then
		ssh ${host_ip[$etcdhost]} "etcdctl mk /psc/${cls}/psc/hosts/$hst/log_dir ${host_path_log[$hst]}"
	fi
	
	ssh ${host_ip[$etcdhost]} "etcdctl mk /psc/${cls}/psc/hosts/$hst/ip ${host_ip[$hst]}"
	ssh ${host_ip[$etcdhost]} "etcdctl mk /psc/${cls}/psc/hosts/$hst/host_role '${host_role[$hst]}'"
	ssh ${host_ip[$etcdhost]} "etcdctl mk /psc/${cls}/psc/hosts/$hst/site ${host_site[$hst]}"
	
	hr=${host_role[$hst]}
	
	if [[ ${cluster_pgbackrest_repo2[$cls]} == $hst  ]]; then
		ssh ${host_ip[$etcdhost]} "etcdctl mk /psc/${cls}/psc/repo1_path ${host_path_data[$hst]}/repo1"
	fi
	if [[ ${cluster_pgbackrest_repo2[$cls]} == $hst  ]]; then
		ssh ${host_ip[$etcdhost]} "etcdctl mk /psc/${cls}/psc/repo2_path ${host_path_data[$hst]}/repo2"
	fi
	if [[ ${hr} =~ "pgserver"  ]]; then
		ssh ${host_ip[$etcdhost]} "etcdctl mk /psc/${cls}/psc/hosts/$hst/pg_data_dir ${host_path_data[$hst]}/${cls}_${cluster_role_version[$cls]}"
		ssh ${host_ip[$etcdhost]} "etcdctl mk /psc/${cls}/psc/hosts/$hst/pg_log_dir ${host_path_log[$hst]}/${cls}_${cluster_role_version[$cls]}"
	fi
	if [[ "${cluster_master[$cls]}" == "$hst"  ]]; then
		ssh ${host_ip[$etcdhost]} "etcdctl mk /psc/${cls}/psc/master $hst"
		ssh ${host_ip[$etcdhost]} "etcdctl mk /psc/${cls}/psc/master_pg_data_dir ${host_path_data[$hst]}/${cls}_${cluster_role_version[$cls]}"
	fi


done

cecho ">>>>>>>>>etcd2env.sh"
for hst in ${hosts[@]};do
	echo ">>> to $hst: etcdhosts:$etcdhosts"
	ssh ${host_ip[$hst]} "sudo -S -u postgres /var/lib/psc/scripts/postgres/etcd2env.sh $cls $etcdhosts"

	echo ">>>psc-config-updater service: config start"
	ssh ${host_ip[$hst]} "sudo -S sed -i s/PRM_CLUSTER/${cls}/g /var/lib/psc/service/psc-conf-updater.service"
	ssh ${host_ip[$hst]} "sudo -S ln -fs /var/lib/psc/service/psc-conf-updater.service  /lib/systemd/system"
	
	echo ">>>pglogway service"
	ssh ${host_ip[$hst]} "sudo -S ln -fs /var/lib/psc/service/pglogway.service  /lib/systemd/system"
	ssh ${host_ip[$hst]} "sudo -S ln -fs /var/lib/psc/service/pglogway.ini /etc/pglogway.ini"
	ssh ${host_ip[$hst]} "sudo -S ln -fs /var/lib/psc/service/pglogway-log4j2.properties /etc/pglogway-log4j2.properties"
	
	
	ssh ${host_ip[$hst]} "sudo -S systemctl daemon-reload"
	ssh ${host_ip[$hst]} "sudo -S systemctl enable psc-conf-updater.service "
	ssh ${host_ip[$hst]} "sudo -S systemctl restart psc-conf-updater.service "
done

echo "success"
exit 0

#	ssh ${host_ip[$etcdhost]} "rm -rf /tmp/psc-templates"	