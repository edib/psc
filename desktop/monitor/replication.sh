#!/bin/bash

[[ $PSC_RUN_COMMON != yes ]] && source /opt/psc/private/common.sh

cls=$1

ssh ${cluster_master[$cls]} sudo -S -u postgres $PSC/postgres/monitor/replication.sh $cls



echo "Success"
exit