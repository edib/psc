export cls=$1
[[ $PSC_RUN_COMMON != yes ]] && source /var/lib/psc/scripts/common.sh

hst=$(hostname)

if [[ "$host_role" =~ "gate" ]]; then
	/var/lib/psc/scripts/postgres/render_template.sh $cls pgbouncer.ini.ctpl "/etc/pgbouncer/pgbouncer.ini"
	/var/lib/psc/scripts/postgres/render_template.sh $cls pgbouncer-userlist.txt.ctpl "/etc/pgbouncer/userlist.txt"
	/var/lib/psc/scripts/postgres/render_template.sh $cls pgbouncer-pg_hba.conf.ctpl "/etc/pgbouncer/pg_hba.conf"
	/var/lib/psc/scripts/postgres/render_template.sh $cls haproxy.cfg.ctpl "/etc/haproxy/haproxy.cfg"
	sudo systemctl reload haproxy
	sudo systemctl reload pgbouncer
fi

if [[ "$host_role" =~ "backup" ]]; then
	/var/lib/psc/scripts/postgres/render_template.sh $cls pgbackrest-backup-site.conf.ctpl "/etc/pgbackrest.conf"
fi