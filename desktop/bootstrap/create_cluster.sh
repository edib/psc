#!/bin/bash

export cls=$1

[[ $PSC_RUN_COMMON != yes ]] && source /opt/psc/desktop/common.sh

master=${cluster_master[$cls]}

ssh ${host_ip[$master]} "sudo -S -u postgres /var/lib/psc/scripts/postgres/create_cluster.sh $1"


exit