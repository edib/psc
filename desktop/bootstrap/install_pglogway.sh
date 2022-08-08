#!/bin/bash
export cls=$1

[[ $PSC_RUN_COMMON != yes ]] && source /opt/psc/desktop/common.sh


eserver=$2
euser=$3
epwd=$4


cecho ">>>>>>>>>Installing PgLogWay"

for hst in ${hosts[@]};do
	hr="${host_role[$hst]}"
	
	
	if [[ "${hr}" =~ "pgserver" ]]; then
		echo ">>> To $hst"
		
		cecho ">>>>>>>>>Copy files to /var/lib/psc"
		ssh ${host_ip[$hst]} "sudo -S rm -rf /tmp/psc /var/lib/psc/scripts /var/lib/psc/service /var/lib/psc/lib"
		scp -r -q /opt/psc/remote ${host_ip[$hst]}:/tmp/psc
		ssh ${host_ip[$hst]} "sudo -S mv /tmp/psc/scripts /var/lib/psc"
		ssh ${host_ip[$hst]} "sudo -S mv /tmp/psc/service /var/lib/psc"
		ssh ${host_ip[$hst]} "sudo -S mv /tmp/psc/lib /var/lib/psc"
		ssh ${host_ip[$hst]} "sudo -S chown -R postgres:postgres /var/lib/psc"
		echo ">>>pglogway service: config start"
		
		ssh ${host_ip[$hst]} "sudo -S sed -i s/PRM_CLUSTER/${cls}/g /var/lib/psc/service/pglogway.ini"
		ssh ${host_ip[$hst]} "sudo -S sed -i s/PRM_PRM_ELASTIC_SERVER/${eserver}/g /var/lib/psc/service/pglogway.ini"
		ssh ${host_ip[$hst]} "sudo -S sed -i s#PRM_ELASTIC_USER_PWD#${epwd}#g /var/lib/psc/service/pglogway.ini"
		ssh ${host_ip[$hst]} "sudo -S sed -i s/PRM_ELASTIC_USER/${euser}/g /var/lib/psc/service/pglogway.ini"
		logdir="${host_path_log[$hst]}/${cls}_${cluster_role_version[$cls]}"
		ssh ${host_ip[$hst]} "sudo -S sed -i s#PRM_PG_LOG_DIR#${logdir}#g /var/lib/psc/service/pglogway.ini"
		
		ssh ${host_ip[$hst]} "sudo -S ln -fs /var/lib/psc/service/pglogway.service  /lib/systemd/system"
		ssh ${host_ip[$hst]} "sudo -S ln -fs /var/lib/psc/service/pglogway.ini /etc/"
		ssh ${host_ip[$hst]} "sudo -S ln -fs /var/lib/psc/service/pglogway-log4j2.properties /etc/"
		
		ssh ${host_ip[$hst]} "sudo -S systemctl daemon-reload"
		ssh ${host_ip[$hst]} "sudo -S systemctl enable pglogway.service "
		ssh ${host_ip[$hst]} "sudo -S systemctl restart pglogway.service "
		
		echo ">>>pglogway installation completed"
	fi
	
done

echo "success"
exit 0

#	ssh ${host_ip[$etcdhost]} "rm -rf /tmp/psc-templates"	