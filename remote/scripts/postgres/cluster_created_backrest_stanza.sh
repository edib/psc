#!/bin/bash

export cls=$1
[[ $PSC_RUN_COMMON != yes ]] && source /var/lib/psc/scripts/common.sh

cls=$1
hst=$2
pv=$3
master=$4

cecho ">>> Sleep for 5 seconds"
sleep 5

cecho ">>>>>>>>>>Pgbackrest server create stanza $hst"
if ! pgbackrest --log-level-file=detail --stanza=$cls stanza-create; then
	echo ">>>Failed to create stanza; sleep for 10 seconds and try again"
	sleep 10	
	if ! pgbackrest --log-level-file=detail --stanza=$cls stanza-create; then
		echo ">>>Failed to create stanza; sleep for 30 seconds and try again"
		sleep 30
		if ! pgbackrest --log-level-file=detail --stanza=$cls stanza-create; then
			echo ">>>Can not create stanza; Exiting"
			exit 1
		fi
	fi
fi 


cecho ">>>>>>>>>>Pgbackrest server backup"
pgbackrest --log-level-file=detail --stanza=$cls backup

echo "Success"
exit