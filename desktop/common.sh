#!/bin/bash


PSC_RUN_COMMON=yes

export PSC_SESSION_DIR=$(mktemp -d -t pcs.XXXXXXXXXX)
trap  " echo '<<<<<'; rm -rf  ${PSC_SESSION_DIR}; unset PSC_SESSION_DIR " EXIT

export PSC_TEXT_COLOR=1

postgres_file_should_contain(){
	curfile=$1
	contentfile=$2
	lead="$3"
	tail="$4"
	
	java -cp /opt/psc/private/jar/pcs-jar-with-dependencies.jar psc.ReplaceFilesMarkedSection $curfile $contentfile $lead $tail 	
}

file_should_contain(){
	curfile=$1
	contentfile=$2
	lead="$3"
	tail="$4"
	
	sudo -S java -cp /opt/psc/private/jar/pcs-jar-with-dependencies.jar psc.ReplaceFilesMarkedSection $curfile $contentfile $lead $tail 	
}

source /opt/psc/desktop/bootstrap/env.sh

if [ -z $cls ]; then
	echo "vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv"
	echo "ERROR: cluster is not defined $(hostname)" 
	echo "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
	exit 1
fi
source /opt/psc/desktop/conf/desktop_env.sh

#host_friends=(${cluster_hosts[$cls]})
hosts=(${cluster_hosts[$cls]})
echo "$cls"
echo "${hosts[@]}"

#source /opt/psc/private/common_local.sh
#source /opt/psc/private/common_postgresql.sh
#source /opt/psc/private/common_desk.sh

cecho(){
	
	#if [ -z "$TERM" ]; then
	#	echo "$1"
	#else
		PSC_TEXT_COLOR=$(( (1 + $PSC_TEXT_COLOR) % 6 ))
		yazirengi=$(( 9 + $PSC_TEXT_COLOR ))
		tput -T xterm-256color setaf ${yazirengi}; echo "$USER@$(hostname)->$1" 
	#fi
	
}

# 
check_user(){
	if [ ${USER} == 'root' ]; then
		echo "Do not use root user; Please use your user"
	fi

	if [ ${USER} == 'postgres' ]; then
		echo "Do not use postgres user; Please use your user"
	fi

	sudo -S -nl > /dev/null
	if [ $? != 0 ]; then
		echo "User $USER do not have SUDO right. Exiting"
		exit 1
	fi
	echo "User $USER have sudo -S right. Continues.."
}


role_is(){
	if [ "$USER" != "$1" ];
	  then 
	  	echo "Please run as $1"; exit 1 
	  else 
	  	echo "Running as $1"
	fi
}

function finish {
	echo "dene"
	if [ "$PSC_SESSION_DIR" /tmp/pcs* ]; then
		echo "Catch"
	fi
  #rm -rf "$PSC_SESSION_DIR"
}

start_session(){
	PSC_SESSION_DIR=$(mktemp -d -t pcs.XXXXXXXXXX)
}

ls_clusters(){
	host=$1
	if [ "$host" == "$(hostname)" ]; then
		echo "hostname matches"
		pg_lsclusters -j > "$PSC_SESSION_DIR/${host}.json"
	fi	
}

