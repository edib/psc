export cls=$1
[[ $PSC_RUN_COMMON != yes ]] && source /var/lib/psc/scripts/common.sh

cls=$1
hst=$2
pv=$3
leader=$4

cecho ">>>>>>>>>Basebackup"

echo ">>>>>>>>>Creating log directory"
mkdir -p $pg_log_dir

/var/lib/psc/scripts/postgres/pgpass.sh $cls

echo ">>>>>>>>>Creating cluster" 
pg_createcluster -d ${pg_data_dir} -l "${pg_log_dir}/postgresql-%Y.%m.%d.%H.log" -p $pgport $pgver $cls

pg_ctlcluster $pv $cls stop

echo ">>>>>>>>>Deleting cluster data ${pg_data_dir}/*"
rm -rf ${pg_data_dir}/*

export slotname=$(echo "$hst" | sed "s|[^(a-z)^(0-9)]||g")

echo ">>>>>>>>>Taking basebackup in host:$1 -D $pg_data_dir --create-slot --slot=$slotname -c fast -X stream -Fp -h $leader -U $replica_user "
pg_basebackup --no-password -D $pg_data_dir --create-slot --slot=$slotname -c fast -X stream -Fp -h $leader -U $replica_user --progress

touch $pg_data_dir/standby.signal

/var/lib/psc/scripts/postgres/render_template.sh $cls pgserver-replica.conf.ctpl "${pg_data_dir}/postgresql.auto.conf"
/var/lib/psc/scripts/postgres/render_template.sh $cls pgserver-pg_hba.conf.ctpl "/etc/postgresql/$pv/$cls/pg_hba.conf"


pg_ctlcluster $pv $cls start