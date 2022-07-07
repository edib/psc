#!/bin/bash

array_intersaction(){
	a=$1
	b=$2
	
	l2=" ${list2[*]} "                    # add framing blanks
	for item in ${list1[@]}; do
	  if [[ $l2 =~ " $item " ]] ; then    # use $item as regexp
	    result+=($item)
	  fi
	done
	echo  ${result[@]} 	
}

PSC=/opt/psc
PSC_GEN_LIB_DIR=/var/lib/psc
PSC_GEN_LOG_DIR=/var/log/psc
PSC_NOPASSWD_USERS=(ybavci)
PSC_NOPASSWD_GROUP=(pgdb)


declare -A cluster_hosts
declare -A cluster_port
declare -A cluster_local_haproxy_port
declare -A cluster_replica_user
declare -A cluster_replica_user_pass
declare -A cluster_postgres_pass
declare -A cluster_master
declare -A cluster_ro
declare -A cluster_follows

declare -A cluster_logrepo_host
declare -A cluster_logrepo_dir

declare -A cluster_role_version

declare -A host_ip
declare -A host_role
declare -A host_available_pg_versions
declare -A host_site


declare -A host_path_data
declare -A host_path_log


#pgbackrest
declare -A cluster_pgbackrest_retention_full
declare -A cluster_pgbackrest_repo1
declare -A cluster_pgbackrest_repo2
declare -A host_path_pgbackrest

#pgbouncer
declare -A cluster_pool_auth_user
declare -A cluster_pool_auth_user_pass

allclusters=($(find -L /opt/psc-conf/  -mindepth 3 -maxdepth 3 -type d -path '*/clusters/*'  -not -path '*/.*'  -printf '%f '))
allhosts=($(find -L /opt/psc-conf/  -mindepth 3 -maxdepth 3 -type d -path '*/hosts/*'  -not -path '*/.*'  -printf '%f '))
allsites=($(find -L /opt/psc-conf/  -mindepth 3 -maxdepth 3 -type d -path '*/sites/*'  -not -path '*/.*'  -printf '%f '))

allclusterswp=($(find -L /opt/psc-conf/  -mindepth 3 -maxdepth 3 -type d -path '*/clusters/*'  -not -path '*/.*'))
allhostswp=($(find -L /opt/psc-conf/  -mindepth 3 -maxdepth 3 -type d -path '*/hosts/*'  -not -path '*/.*'))
allsiteswp=($(find -L /opt/psc-conf/  -mindepth 3 -maxdepth 3 -type d -path '*/sites/*'  -not -path '*/.*'))


for it in ${allclusterswp[@]}; do
	source ${it}/cluster.sh
done

for it in $(allhostswp[@]); do
	source ${it}/host.sh
done

for it in $(allsiteswp); do
	source ${it}/site.sh
done

hostname=$(hostname)


#function find_host_friends(){
#	hst=$1
#	local hstfriends=()
#	for bhst in ${hosts[@]}; do
#		if [ $hst == $bhst ]; then
#			continue;
#		fi
#		ac="${host_clusters[$hst]}"
#		bc="${host_clusters[$bhst]}"
#		ret=$(array_intersaction "$ac" "$bc")
#		if [ "$ret" != '' ]; then
#			hstfriends=( $bhst "${hstfriends[@]}" )
#		fi
#	done
#	host_friends[$hst]="${hstfriends[@]}"
#	echo "$hst ${hstfriends[*]}"
	
	
	#host_clusters[$hst]="${hstcluster[@]}"
	#son=${host_clusters[$hst]};
	#echo "$son"
#}

#if [ -f /usr/bin/java ]; then
#	echo "========We have friends "
#	for ahst in ${hosts[@]}; do
#		find_host_friends $ahst	
#	done
#else
#	echo "FAILLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL"
#	echo "FAILLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL"
#	exit 1
#fi

function find_etcd_http_hosts(){
	local result=""
	for h in ${hosts[@]}; do
		if [[ ${host_role[$h]} =~ "etcd" ]]; then
			if [ "$result" == "" ]; then
				result="http://${h}:2379"
			else
				result="${result},http://${h}:2379"
			fi
		fi
	done
	echo $result;
}

function find_etcd_hosts(){
	local result=""
	for h in ${hosts[@]}; do
		if [[ ${host_role[$h]} =~ "etcd" ]]; then
			if [ "$result" == "" ]; then
				result="${h}:2379"
			else
				result="${result},${h}:2379"
			fi
		fi
	done
	echo $result;
}

function find_etcd_hosts_with_name(){
	local result=""
	for h in ${hosts[@]}; do
		ip=${host_ip[$h]};
		if [[ ${host_role[$h]} =~ "etcd" ]]; then
			if [ "$result" == "" ]; then
				result="${h}=http://${ip}:2380"
			else
				result="${result},${h}=http://${ip}:2380"
			fi
		fi
	done
	echo $result;
}

#echo "m1 friends ${host_friends[m1]}"

