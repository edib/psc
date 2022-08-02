#!/bin/bash

export cls=$1

[[ $PSC_RUN_COMMON != yes ]] && source /opt/psc/desktop/common.sh

cecho ">>>>>>>>>etchosts"

#friends=(${host_friends[$hst]})

cecho ">>>>>>>>>Prepare etc hosts file"
etchosts="${PSC_SESSION_DIR}/etchosts.tmp"
echo "##PCSSTART" > ${etchosts}
for ahst in ${hosts[@]}; do
	echo "${host_ip[$ahst]} $ahst" >> ${etchosts}
done
echo "##PCSEND" >> ${etchosts}

ppwd=$(perl -e 'print crypt($ARGV[0], "password")' "${cluster_postgres_pass[$cls]}")

for hst in ${hosts[@]};do
	
	cecho ">>>>>>>>>Generate etc hosts file from prepared etc hosts file $hst"
	scp ${etchosts} @${host_ip[$hst]}:/tmp/etchost.tmp
	ssh ${host_ip[$hst]} 'sudo -S -s -u root  eval "cat /tmp/etchost.tmp >> /etc/hosts"'
	
	cecho ">>>>>>>>>Update locale $hst"
	ssh ${host_ip[$hst]}  'sudo -S locale-gen --purge "tr_TR.UTF-8"'
	ssh ${host_ip[$hst]}  'sudo -S dpkg-reconfigure --frontend noninteractive locales'
	#sudo -S update-locale LANG=tr_TR.UTF-8 LANGUAGE
	
	cecho ">>>>>>>>>Install jdk11 $hst"
	ssh ${host_ip[$hst]}  "sudo -S apt-get -q -y install openjdk-11-jre-headless"
	
	cecho ">>>>>>>>>Install ctpl $hst"
	ssh ${host_ip[$hst]}  "sudo -S apt-get -q -y install ctpl"


	cecho ">>>>>>>>>Install etcd-client $hst"
	ssh ${host_ip[$hst]}  "sudo -S apt-get -q -y install etcd-client"
	
	cecho ">>>>>>>>>Adding postgres user $hst "
	#sudo -S adduser --quiet --system --shell=/bin/bash --home=/var/lib/postgresql --group postgres -p $(perl -e 'print crypt($ARGV[0], "password")' "${cluster_postgres_pass[$cls]}")
	ssh ${host_ip[$hst]}  "sudo -S useradd --shell=/bin/bash --home=/var/lib/postgresql -m postgres -p $ppwd" 
	
	cecho ">>>>>>>>>Key generation for postgres user $hst"
	ssh ${host_ip[$hst]}  'sudo -S -u postgres ssh-keygen -t rsa -N "" -f /var/lib/postgresql/.ssh/id_rsa'
	
	cecho ">>>>>>>>>Disable host key verification in file /var/lib/postgresql/.ssh/config $hst"	
	evalstr='echo "Host *" > /var/lib/postgresql/.ssh/config'
	ssh ${host_ip[$hst]}  "sudo -S -s -u postgres eval '$evalstr'"
	evalstr='echo "   StrictHostKeyChecking no" >> /var/lib/postgresql/.ssh/config'
	ssh ${host_ip[$hst]}  "sudo -S -s -u postgres eval '$evalstr'"
	ssh ${host_ip[$hst]}  "sudo -S chown postgres:postgres /var/lib/postgresql/.ssh/config"
	ssh ${host_ip[$hst]}  "sudo -S chmod 400 /var/lib/postgresql/.ssh/config"
	
	#cecho ">>>>>>>>>Key generation for postgres user"
	#sudo -S sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
	#sudo -S systemctl reload sshd
	
	cecho ">>>>>>>>>Creating psc data folder: /var/lib/psc $hst"
	ssh ${host_ip[$hst]}  "sudo -S mkdir -m 755 -p $PSC_GEN_LIB_DIR"
	ssh ${host_ip[$hst]}  "sudo -S chown postgres:postgres $PSC_GEN_LIB_DIR"
	ssh ${host_ip[$hst]}  "sudo -S cp /var/lib/postgresql/.ssh/id_rsa.pub ${PSC_GEN_LIB_DIR}" 
	ssh ${host_ip[$hst]}  "sudo -S chmod 755 /var/lib/psc/id_rsa.pub"
	
	cecho ">>>>>>>>>Creating psc log folder: /var/log/psc $hst"
	ssh ${host_ip[$hst]}  "sudo -S mkdir -m 755 -p ${PSC_GEN_LOG_DIR}"
	ssh ${host_ip[$hst]}  "sudo -S chown postgres:postgres ${PSC_GEN_LOG_DIR}"
	
	cecho ">>>>>>>>>postgres user can reload pgbouncer and haproxy services $hst"
	if [[ "${host_os[$hst]}" == "ubuntu" ]]; then
		evalstr='echo "postgres ALL=(ALL) NOPASSWD: /usr/sbin/modprobe, /usr/bin/chown, /bin/systemctl reload pgbouncer, /bin/systemctl restart pgbouncer, /bin/systemctl reload haproxy, /bin/systemctl reload patroni, /bin/systemctl restart patroni, /bin/systemctl stop patroni, /bin/systemctl restart etcd" > /etc/sudoers.d/psc'
	else
		evalstr='echo "postgres ALL=(ALL) NOPASSWD: /sbin/modprobe, /bin/chown, /bin/systemctl reload pgbouncer, /bin/systemctl restart pgbouncer, /bin/systemctl reload haproxy, /bin/systemctl reload patroni, /bin/systemctl restart patroni, /bin/systemctl stop patroni, /bin/systemctl restart etcd" > /etc/sudoers.d/psc'
	fi

	ssh ${host_ip[$hst]}  "sudo -S -s -u root eval '$evalstr'" 
	ssh ${host_ip[$hst]}  "sudo -S chmod 0440 /etc/sudoers.d/psc"
	
	cecho ">>>>>>>>>adding environment variables $hst"
	evalstr='echo "export PATRONICTL_CONFIG_FILE=/etc/patroni/config.yml" >> /etc/environment'
	ssh ${host_ip[$hst]}  "sudo -S -s eval  '$evalstr'"
	
	
done