#!/bin/bash

export cls=$1

[[ $PSC_RUN_COMMON != yes ]] && source /opt/psc/desktop/common.sh

pgv=${cluster_role_version[$cls]}

cecho ">>>>>>>>>start uninstalling"

for hst in ${hosts[@]};do
	cecho ">>>>> Uninstall host: $hst"
	
	echo ">>>>>>>>>remove services"
	ssh ${host_ip[$hst]}  "sudo -S systemctl stop pglogway"
	ssh ${host_ip[$hst]}  "sudo -S systemctl remove pglogway"
	ssh ${host_ip[$hst]}  "sudo -S systemctl stop psc-conf-updater"
	ssh ${host_ip[$hst]}  "sudo -S systemctl remove psc-conf-updater"

	
	echo ">>>>>>>>>remove packages"
	ssh ${host_ip[$hst]}  "sudo -S apt-get -y purge postgres* etcd-server etcd-client ctpl openjdk-11-jre-headless patroni pgbouncer haproxy pgbackrest"
	ssh ${host_ip[$hst]}  "sudo -S rm -rf /etc/postgresql* /etc/pgbackrest* /etc/pglogway*"
	
		
	echo ">>>>>>>>>remove sudo file"
	ssh ${host_ip[$hst]}  "sudo -S rm -f /etc/sudoers.d/psc"

	echo ">>>>>>>>>remove psc directories"
	ssh ${host_ip[$hst]}  "sudo -S rm -rf /var/lib/psc /var/log/psc"
	
	echo ">>>>>>>>>remove postgres user"
	ssh ${host_ip[$hst]}  "sudo -S killall -u postgres"
	ssh ${host_ip[$hst]}  "sudo -S userdel -f -r postgres"
	
	
done