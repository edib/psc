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



cecho ">>>>>>>>>etcd2env.sh"
for hst in ${hosts[@]};do
	echo ">>> to $hst: etcdhosts:$etcdhosts"
	ssh ${host_ip[$hst]} "sudo -S -u postgres /var/lib/psc/scripts/postgres/etcd2env.sh $cls $etcdhosts"

	echo ">>>psc-config-updater service: config start"
	ssh ${host_ip[$hst]} "sudo -S sed -i s/PRM_CLUSTER/${cls}/g /var/lib/psc/service/psc-conf-updater.service"
	ssh ${host_ip[$hst]} "sudo -S ln -fs /var/lib/psc/service/psc-conf-updater.service  /lib/systemd/system"
	ssh ${host_ip[$hst]} "sudo -S systemctl daemon-reload"
	ssh ${host_ip[$hst]} "sudo -S systemctl enable psc-conf-updater.service "
	ssh ${host_ip[$hst]} "sudo -S systemctl restart psc-conf-updater.service "
	
done

echo "success"
exit 0

#	ssh ${host_ip[$etcdhost]} "rm -rf /tmp/psc-templates"	