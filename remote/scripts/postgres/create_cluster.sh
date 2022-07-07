#!/bin/bash

export cls=$1
[[ $PSC_RUN_COMMON != yes ]] && source /var/lib/psc/scripts/common.sh

hst=$(hostname)

cecho ">>>>>>>>>Creating log directory: $pg_log_dir"
mkdir -p $pg_log_dir

/var/lib/psc/scripts/postgres/pgpass.sh $cls

cecho ">>>>>>>>>>Creating cluster $cls"
pg_createcluster -d ${pg_data_dir} -l /tmp/create_cluster.log -p $pgport $pgver $cls 

cecho ">>>>>>>>>>Rendering templates $cls"
/var/lib/psc/scripts/postgres/render_template.sh $cls pgserver-master.conf.ctpl "${pg_data_dir}/postgresql.auto.conf"
/var/lib/psc/scripts/postgres/render_template.sh $cls pgserver-pg_hba.conf.ctpl "/etc/postgresql/$pgver/$cls/pg_hba.conf"
/var/lib/psc/scripts/postgres/render_template.sh $cls pgbackrest-db-site.conf.ctpl "/etc/pgbackrest.conf"
/var/lib/psc/scripts/postgres/render_template.sh $cls patroni-config.yml.ctpl "/etc/patroni/config.yml"

cecho ">>>>>>>>>>Starting cluster $cls"
pg_ctlcluster "$pgver" "$cls" start

cecho ">>>>>>>>>>Creating pool auth user"
psql -p $pgport postgres -c "create user $auth_user with password '$auth_user_pwd'";

cecho ">>>>>>>>>>Creating replication user"
psql -p $pgport postgres -c "create role $replica_user with replication password '$replica_user_pwd' login"; 

for h in ${backup_hosts[@]};do
	ssh $h /var/lib/psc/scripts/postgres/cluster_created_backrest_conf.sh $cls
done

for h in ${pgserver_hosts[@]};do
	if [ "$h" == "$hst" ]; then
		continue
	fi
	ssh $h /var/lib/psc/scripts/postgres/cluster_created_create_replication.sh $cls $h $pgver $hst
done

for h in ${gate_hosts[@]};do
	ssh $h /var/lib/psc/scripts/postgres/cluster_created_pgbouncer_conf.sh $cls
done

for h in ${backup_hosts[@]};do
	ssh $h /var/lib/psc/scripts/postgres/cluster_created_backrest_stanza.sh $cls $h $pgver $hst
done

#patroni /etc/patroni/config.yaml 
/var/lib/psc/scripts/postgres/cluster_created_restart_patroni.sh $cls
echo "Start patroni successfull."

echo "Now importing configuration"
echo "Sleep 45 seconds for patroni to be ready"
sleep 45

echo "Importing config done!"

if ! patronictl edit-config --force -q --replace /etc/patroni/config.yml; then
	echo ">>>Failed to import config"
	/var/lib/psc/scripts/postgres/cluster_created_restart_patroni.sh $cls
	sleep 10	
	if ! patronictl edit-config --force -q --replace /etc/patroni/config.yml; then
		echo ">>>Failed to import config"
		/var/lib/psc/scripts/postgres/cluster_created_restart_patroni.sh $cls
		sleep 10
		if ! patronictl edit-config --force -q --replace /etc/patroni/config.yml; then
			echo ">>>Can not import config; please import it manually and reload/restart patroni nodes..."
			exit 1
		fi
	fi
fi 


echo "Sleep 10 seconds for patroni to be ready"
sleep 10

for h in ${pgserver_hosts[@]};do
	if [ "$h" == "$hst" ]; then
		continue
	fi
	sleep 10
	echo "Restarting patroni: $h"
	ssh $h /var/lib/psc/scripts/postgres/cluster_created_restart_patroni.sh $cls
	echo "Done: $h"
done

echo "Success"
exit
