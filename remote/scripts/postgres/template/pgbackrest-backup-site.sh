export cls=$1
[[ $PSC_RUN_COMMON != yes ]] && source /var/lib/psc/scripts/common.sh

hst=$(hostname)
key="/psc/${cls}/psc/templates/pgbackrest-backup-site.conf.ctpl" 

f=${PSC_SESSION_DIR}/template.txt

etcdctl get $key > $f 

ilk=$(stat -c %Y $f)

vi $f

son=$(stat -c %Y $f)

echo "$ilk"
echo "$son"


if [[ "$ilk" == "$son" ]]; then
	echo "No change"
	exit 0;
fi
echo "Changed; updating key"

etcdctl set $key < $f 

for hst in ${backup_hosts[@]};do
	echo "update template in hst:$hst"
	ssh $hst /var/lib/psc/scripts/postgres/render_template.sh $cls pgbackrest-backup-site.conf.ctpl "/etc/pgbackrest.conf"
done
