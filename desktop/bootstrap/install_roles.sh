#!/bin/bash

export cls=$1

[[ $PSC_RUN_COMMON != yes ]] && source /opt/psc/desktop/common.sh

/opt/psc/desktop/bootstrap/install_etcd_roles.sh $cls
/opt/psc/desktop/bootstrap/install_pgserver_roles.sh $cls
/opt/psc/desktop/bootstrap/install_pgbackrest.sh $cls
/opt/psc/desktop/bootstrap/install_pgbouncer.sh $cls
/opt/psc/desktop/bootstrap/install_elastic.sh $cls
/opt/psc/desktop/bootstrap/install_kibana.sh $cls
