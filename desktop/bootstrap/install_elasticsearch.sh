#!/bin/bash

export cls=$1

[[ $PSC_RUN_COMMON != yes ]] && source /opt/psc/desktop/common.sh


for hst in ${hosts[@]};do
	
	[[ "${host_role[$hst]}" ]] || (echo 'This host does not have any role, exits'; exit 1; )
	
	rl=${host_role[$hst]}
	tmpfile=${PSC_SESSION_DIR}/es.tmp
	ktmpfile=${PSC_SESSION_DIR}/ek.tmp
	
	
	
	if [[ "$rl" =~ "elasticsearch" ]]; then

		cecho ">>>>>Install elasticsearch $hst"
		ssh ${host_ip[$hst]} "sudo -S apt-get -q -y install elasticsearch"

		tdatadir="${host_path_data[$hst]}/elasticsearch"
		tlogdir="${host_path_log[$hst]}/elasticsearch"
		
		ssh ${host_ip[$hst]} "sudo -S mkdir $tdatadir $tlogdir"
		ssh ${host_ip[$hst]} "sudo -S chown elasticsearch:elasticsearch $tdatadir $tlogdir"
		
		echo "cluster.name: \"$cls\"" > $tmpfile
		echo "path.data: \"$tdatadir\"" >> $tmpfile
		echo "path.logs: \"$tdatadir\"" >> $tmpfile
		echo "xpack.security.enabled: true" >> $tmpfile
		echo "xpack.security.enrollment.enabled: true" >> $tmpfile
		echo "xpack.security.http.ssl:" >> $tmpfile
		echo "    enabled: false" >> $tmpfile
		echo "xpack.security.transport.ssl:" >> $tmpfile
		echo "    enabled: false" >> $tmpfile
		echo "cluster.initial_master_nodes: [\"$hst\"]" >> $tmpfile
		echo "http.host: 0.0.0.0" >> $tmpfile

		scp $tmpfile ${host_ip[$hst]}:/tmp/eyml.tmp
		echo "Backing up elasticsearch configuration files"
		ssh ${host_ip[$hst]} "sudo -S cp /etc/elasticsearch/elasticsearch.yml /etc/elasticsearch/elasticsearch.yml.old"
		
		
		echo "Make elasticsearch config"
		ssh ${host_ip[$hst]} "sudo -S -u root -s eval 'cat /tmp/eyml.tmp > /etc/elasticsearch/elasticsearch.yml'"
		ssh ${host_ip[$hst]} "sudo -S -u root -s eval 'echo \"-Xms500m\" >> /etc/elasticsearch/jvm.options'"
		ssh ${host_ip[$hst]} "sudo -S -u root -s eval 'echo \"-Xmx1g\" >> /etc/elasticsearch/jvm.options'"
		ssh ${host_ip[$hst]} "sudo -S systemctl daemon-reload"
		ssh ${host_ip[$hst]} "sudo -S systemctl enable elasticsearch"
		
		echo "Starting elasticsearch"
		ssh ${host_ip[$hst]} "sudo -S systemctl start elasticsearch"
		
		echo "Starting elasticsearch-done"
		elastic_pwd=$(ssh ${host_ip[$hst]} "sudo -S /usr/share/elasticsearch/bin/elasticsearch-reset-password -u elastic -s -f -b")
		echo "elastic user pwd=$elastic_pwd"
		kibana_pwd=$(ssh ${host_ip[$hst]} "sudo -S /usr/share/elasticsearch/bin/elasticsearch-reset-password -u kibana_system -s -f -b")
		echo "kibana user pwd=$kibana_pwd"
		beat_pwd=$(ssh ${host_ip[$hst]} "sudo -S /usr/share/elasticsearch/bin/elasticsearch-reset-password -u beats_system -s -f -b")
		echo "beat user pwd=$beat_pwd"
		
		cecho ">>>> kibana installation starting"
		ssh ${host_ip[$hst]} "sudo -S apt-get -q -y install kibana"

		echo "server.host: \"0.0.0.0\"" > $ktmpfile
		echo "elasticsearch.username: \"kibana_system\"" >> $ktmpfile
		echo "elasticsearch.password: \"$kibana_pwd\"" >> $ktmpfile
		echo "pid.file: /run/kibana/kibana.pid" >> $ktmpfile
		echo "logging:" >> $ktmpfile
		echo "  appenders:" >> $ktmpfile
		echo "    file:" >> $ktmpfile
		echo "      type: file" >> $ktmpfile
		echo "      fileName: /var/log/kibana/kibana.log" >> $ktmpfile
		echo "      layout:" >> $ktmpfile
		echo "        type: json" >> $ktmpfile
		echo "  root:" >> $ktmpfile
		echo "    appenders:" >> $ktmpfile
		echo "      - default" >> $ktmpfile
		echo "      - file" >> $ktmpfile
		
		scp $ktmpfile ${host_ip[$hst]}:/tmp/kyml.tmp
		echo "Backing up kibana configuration files"
		ssh ${host_ip[$hst]} "sudo -S cp /etc/kibana/kibana.yml /etc/kibana/kibana.yml.old"
		ssh ${host_ip[$hst]} "sudo -S -u root -s eval 'cat /tmp/kyml.tmp > /etc/kibana/kibana.yml'"
		ssh ${host_ip[$hst]} "sudo -S -u root -s eval 'echo \"--max-old-space-size=300\" >> /etc/kibana/node.options'"
		
		ssh ${host_ip[$hst]} "sudo -S systemctl daemon-reload"
		ssh ${host_ip[$hst]} "sudo -S systemctl enable kibana"
		ssh ${host_ip[$hst]} "sudo -S systemctl start kibana"
		
		for bhst in ${hosts[@]};do
			cecho ">>>>>>>>> metricbeat installation in $bhst"
			echo ">>>>>generate config file"
			btmpfile=${PSC_SESSION_DIR}/bk.tmp
			echo "metricbeat.config.modules:" > $btmpfile
			echo "  path: \${path.config}/modules.d/*.yml" >> $btmpfile
			echo "  reload.enabled: false" >> $btmpfile
			echo "setup.template.settings:" >> $btmpfile
			echo "  index.number_of_shards: 1" >> $btmpfile
			echo "  index.codec: best_compression" >> $btmpfile
			echo "setup.kibana:" >> $btmpfile
			echo "  host: \"$hst:5601\"" >> $btmpfile
			echo "output.elasticsearch:" >> $btmpfile
			echo "  hosts: [\"$hst:9200\"]" >> $btmpfile
			echo "  username: \"elastic\"" >> $btmpfile
			echo "  password: \"$elastic_pwd\"" >> $btmpfile
			echo "processors:" >> $btmpfile
			echo "  - add_host_metadata: ~" >> $btmpfile
			echo "  - add_cloud_metadata: ~" >> $btmpfile
			echo "  - add_docker_metadata: ~" >> $btmpfile
			echo "  - add_kubernetes_metadata: ~" >> $btmpfile
		
			scp $btmpfile ${host_ip[$bhst]}:/tmp/byml.tmp
				
			ssh ${host_ip[$bhst]} "sudo -S apt-get -q -y install metricbeat"
			ssh ${host_ip[$bhst]} "sudo -S systemctl enable metricbeat"
		
			ssh ${host_ip[$bhst]} "sudo -S cp /etc/metricbeat/metricbeat.yml /etc/metricbeat/metricbeat.yml.old"	
			ssh ${host_ip[$bhst]} "sudo -S -u root -s eval 'cat /tmp/byml.tmp > /etc/metricbeat/metricbeat.yml'"
			
			ssh ${host_ip[$bhst]} "sudo -S mv /etc/metricbeat/modules.d/linux.yml.disabled /etc/metricbeat/modules.d/linux.yml"
#			ssh ${host_ip[$bhst]} "sudo -S mv /etc/metricbeat/modules.d/system.yml.disabled /etc/metricbeat/modules.d/system.yml"
			
			if [[ "${host_role[$bhst]}" =~ "gate" ]]; then
				ssh ${host_ip[$bhst]} "sudo -S mv /etc/metricbeat/modules.d/haproxy.yml.disabled /etc/metricbeat/modules.d/haproxy.yml"
			fi
			if [[ "${host_role[$bhst]}" =~ "pgserver" ]]; then
				ssh ${host_ip[$bhst]} "sudo -S mv /etc/metricbeat/modules.d/postgresql.yml.disabled /etc/metricbeat/modules.d/postgresql.yml"
			fi
			if [[ "${host_role[$bhst]}" =~ "etcd" ]]; then
				ssh ${host_ip[$bhst]} "sudo -S mv /etc/metricbeat/modules.d/etcd.yml.disabled /etc/metricbeat/modules.d/etcd.yml"
			fi
			if [[ "${host_role[$bhst]}" =~ "elasticsearch" ]]; then
				ssh ${host_ip[$bhst]} "sudo -S mv /etc/metricbeat/modules.d/elasticsearch.yml.disabled /etc/metricbeat/modules.d/elasticsearch.yml"
			fi
			
			ssh ${host_ip[$bhst]} "sudo -S systemctl start metricbeat"
				
		done
		
		cecho "Installing pglogway to pgserver roles..."
		/opt/psc/desktop/bootstrap/install_pglogway.sh $cls $hst elastic $elastic_pwd
		
		
		echo "Done"
	fi
	echo "Done all"
done