#!/bin/bash

export cls=$1
[[ $PSC_RUN_COMMON != yes ]] && source /var/lib/psc/scripts/common.sh

cecho ">>>>>>>>>>>Pgbackrest backup configuration $hostname"

/var/lib/psc/scripts/postgres/render_template.sh $cls pgbackrest-backup-site.conf.ctpl "/etc/pgbackrest.conf"

if [[ $hostname == $repo1_host ]]; then
	mkdir -p $repo1_path
elif [[ $hostname == $repo2_host ]]; then
	mkdir -p $repo2_path
fi
