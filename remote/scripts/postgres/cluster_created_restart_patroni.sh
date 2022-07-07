#!/bin/bash

export cls=$1
[[ $PSC_RUN_COMMON != yes ]] && source /var/lib/psc/scripts/common.sh

cecho ">>>>>>>>>>Restarting patroni @$(hostname)"
sudo -S systemctl restart patroni

echo "Success"
exit