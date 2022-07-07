#!/bin/bash

[[ $PSC_RUN_COMMON != yes ]] && source /opt/psc/desktop/common.sh

hst=$(hostname)

#friends=(${host_friends[$hst]})

#echo "Verifying host keys for host=$hst for friends ${friends[*]}"
#echo "checking $hst"
#ssh -o StrictHostKeyChecking=no $hst "echo 'geldim'"
for h in ${hosts[@]}; do
	echo "checking $h"
	ssh -o StrictHostKeyChecking=no $h "echo 'geldim'"
	echo "ok"
done
echo "Verify succeeded for host $hst"

echo "Success"
exit