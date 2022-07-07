#!/bin/bash

export PSC_SESSION_DIR=$(mktemp -d -t pcs.XXXXXXXXXX)
echo "Temp directory is ${PSC_SESSION_DIR}"
trap  " echo 'Exiting'; rm -rf  ${PSC_SESSION_DIR}; unset PSC_SESSION_DIR " EXIT

[[ $PSC_RUN_COMMON != yes ]] && source /opt/psc/private/common.sh


desk_etchosts