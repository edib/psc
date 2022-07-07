#!/bin/bash

[[ $PSC_RUN_COMMON != yes ]] && source /opt/psc/private/common.sh


[[ "${host_cluster[$(hostname)]}" ]] || (echo 'This host does not belogn to any cluster, exits'; exit 1; )

mycluster=${host_cluster[$(hostname)]}

myclusterhosts=${cluster_hosts[$mycluster]}




for hst in $myclusterhosts; do
	echo "${host_ip[$hst]} $hst"
done
