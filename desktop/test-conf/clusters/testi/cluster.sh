

cluster_master[testi]=m2
cluster_follows[testi-m1]=m2
#cluster_follows[testi-m3]=m2


#cluster_hosts[testi]="m1 m2 m3 b1 b2 p1 p2"
cluster_hosts[testi]="m1 m2 b1 b2 p1"

#cluster_ro[testi]=m3

cluster_port[testi]=5432
cluster_local_haproxy_port[testi]=55432
cluster_role_version[testi]=14


cluster_postgres_pass[testi]="94949"
cluster_replica_user[testi]="rep"
cluster_replica_user_pass[testi]="repwd"
cluster_pool_auth_user[testi]="kontrolcu"
cluster_pool_auth_user_pass[testi]="kontrolcu"

cluster_conf_session_preload_libraries[testi]="auto_explain"
cluster_conf_explain_log_min_duration[testi]="2s"
cluster_conf_work_mem[testi]="28MB"
cluster_conf_shared_buffers[testi]="30MB"
cluster_conf_max_wal_size[testi]="16GB"
cluster_conf_max_parallel_workers[testi]=8
#cluster_conf_max_parallel_maintenance_workers[testi]=4 

cluster_pgbackrest_retention_full[testi]=2
cluster_pgbackrest_repo1[testi]=b1
cluster_pgbackrest_repo2[testi]=b2

cluster_haproxy_weight[testi-m1]=1
cluster_haproxy_weight[testi-m2]=2
#cluster_haproxy_weight[testi-m3]=3

