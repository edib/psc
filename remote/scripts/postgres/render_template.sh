#!/bin/bash

export cls=$1
[[ $PSC_RUN_COMMON != yes ]] && source /var/lib/psc/scripts/common.sh

ctpl_item=$2
render_file=$3

templatedir="/psc/${cls}/psc/templates"

cecho "Rendering:  $hostname $ctpl_item $render_file"

etcdctl get "$templatedir/$ctpl_item" > $PSC_SESSION_DIR/tmp.cdtl

ctpl -e /var/lib/psc/${cls}.ctpl.env $PSC_SESSION_DIR/tmp.cdtl > $render_file
