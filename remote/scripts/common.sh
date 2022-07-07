#!/bin/bash

PSC_RUN_COMMON=yes

if [[ -z ${cls} ]]; then
	echo "!!!!!!!!!!!!!!!!!!!!!Cluster undefined... exiting. "
	echo "!!!!!!!!!!!!!!!!!!!!!Cluster undefined... exiting. "
	echo "!!!!!!!!!!!!!!!!!!!!!Cluster undefined... exiting. "
	exit 1
fi

export PSC_SESSION_DIR=$(mktemp -d -t pcs.XXXXXXXXXX)
trap  " echo '<<<<<'; rm -rf  ${PSC_SESSION_DIR}; unset PSC_SESSION_DIR " EXIT

export PSC_TEXT_COLOR=1

clsdir=/var/lib/psc/$cls
templatedir=/var/lib/psc/$cls/templates
scriptdir=/var/lib/psc/scripts

cecho(){
	
	#if [ -z "$TERM" ]; then
	#	echo "$1"
	#else
		PSC_TEXT_COLOR=$(( (1 + $PSC_TEXT_COLOR) % 6 ))
		yazirengi=$(( 9 + $PSC_TEXT_COLOR ))
		tput -T xterm-256color setaf ${yazirengi}; echo "$USER@$(hostname)->$1" 
	#fi
	
}




source "/var/lib/psc/${cls}.sh"

