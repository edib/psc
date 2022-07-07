#!/bin/bash

ip="10.140.10.2";
cls="testi";
hostname="m1";


pg_follows=""
replica=["m2","m3"];
backup=["b1","b2"];
gate=["p1","p2"];
gateips=["p1","p2"];
etcd_hosts="b1:2379,p1:2379,p2:2379";
pgserver=["m1","m2","m3"];
pgserverips=["10.140.10.2","10.140.10.3","10.140.10.4"];


#/psc/${cls}/psc/members
members=["m1","m2","m3","p1","p2","b1","b2"]

#/psc/${cls}/psc/members/$hst/log_dir
log_dir="/log/testi_14";
#/psc/${cls}/psc/members/$hst/pg_log_dir
pg_log_dir="/log/testi_14";
#/psc/${cls}/psc/members/$hst/data_dir
data_dir="${host_path_data[$hst]}/${cls}_${pv}"
#/psc/${cls}/psc/members/$hst/pg_data_dir
pg_data_dir="/data/testi_14";
#/psc/${cls}/psc/members/$hst/host_role
host_role="pgserver"

#/psc/${cls}/psc/master_pg_data_dir
master_pg_data_dir="/data/testi_14";
#/psc/${cls}/psc/master
master="m1";
#/psc/${cls}/psc/repo1_path
repo1_path="/data/repo1";
#/psc/${cls}/psc/repo2_path
repo2_path="/data/repo2";
#/psc/${cls}/psc/repo1_host
repo1_host="b1";
#/psc/${cls}/psc/repo2_host
repo2_host="b2";
#/psc/${cls}/psc/pgver
pgver="14";
#/psc/${cls}/psc/pgport
pgport=5432;
#/psc/${cls}/psc/replica_user
replica_user="rep";
#/psc/${cls}/psc/replica_user_pwd
replica_user_pwd="rep";
#/psc/${cls}/psc/auth_user
auth_user="kontrolcu";
#/psc/${cls}/psc/auth_user_pwd
auth_user_pwd="kontrolcu";




