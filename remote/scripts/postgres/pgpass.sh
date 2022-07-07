export cls=$1
[[ $PSC_RUN_COMMON != yes ]] && source /var/lib/psc/scripts/common.sh

cecho ">>>>>>>>>>Creating pgpass file ${pgport}"

touch ~/.pgpass
chmod 0600 ~/.pgpass

echo "*:${pgport}:*:${replica_user}:${replica_user_pwd}" > ~/.pgpass 
