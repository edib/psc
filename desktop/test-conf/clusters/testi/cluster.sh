


cluster_master[testi]=m2
cluster_follows[testi-m1]=m2
#cluster_follows[testi-m3]=m2

#cluster_hosts[testi]="m1 m2 m3 b1 b2 p1 p2"
cluster_hosts[testi]="m1 m2 b1 b2 p1 e1"


cluster_port[testi]=5432
cluster_local_haproxy_port[testi]=55432
cluster_role_version[testi]=14


cluster_postgres_pass[testi]="94949"
cluster_replica_user[testi]="rep"
cluster_replica_user_pass[testi]="repwd"
cluster_pool_auth_user[testi]="kontrolcu"
cluster_pool_auth_user_pass[testi]="kontrolcu"

cluster_pgbackrest_retention_full[testi]=2
cluster_pgbackrest_repo1[testi]=b1
cluster_pgbackrest_repo2[testi]=b2

cluster_haproxy_weight[testi-m1]=1
cluster_haproxy_weight[testi-m2]=2
#cluster_haproxy_weight[testi-m3]=3

cluster_elastic[testi]=e1
cluster_elastic_psc_user[testi]="pscpwd"
