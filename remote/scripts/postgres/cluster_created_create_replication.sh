#!/bin/bash

export cls=$1
[[ $PSC_RUN_COMMON != yes ]] && source /var/lib/psc/scripts/common.sh

cls=$1
hst=$2
pv=$3
leader=$4

cecho "Checking replication for leader:$leader"

if [ "$leader" == "$hst" ]; then
	echo "Same machine return"
	exit 0
fi

if [ "${pg_follows}" != "$leader" ]; then
	echo "This pgserver $hst do not follow $leader"
	exit 0
fi

cecho "Replica pgbackrest configuratin: $hostname"
/var/lib/psc/scripts/postgres/render_template.sh $cls pgbackrest-db-site.conf.ctpl "/etc/pgbackrest.conf"

cecho "Replica patroni configuratin: $hostname"
/var/lib/psc/scripts/postgres/render_template.sh $cls patroni-config.yml.ctpl "/etc/patroni/config.yml"

cecho ">>>>>>>>>>postgres_cluster_created_pgserver $hst leader is $leader"

/var/lib/psc/scripts/postgres/cluster_basebackup.sh $cls $hst $pv $leader

cecho ">>>>>>>>>>Host: $hst cluster_created: Check nested replications: "
for h in ${pgserver_hosts[@]};do
	if [ "$h" == "$hst" ]; then
		continue
	fi
	ssh $h /var/lib/psc/scripts/postgres/cluster_created_create_replication.sh  $cls $h $pv $hst
done

echo "Success"
exit