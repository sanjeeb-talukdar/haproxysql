#!/bin/bash
# encoding: UTF-8

exec >> /root/proxysql-handler.log

set admin-cluster_username = 'user1'; 
set admin-cluster_password = 'pass1';
set admin-admin_credentials = 'admin:admin;user1:pass1;user2:pass2';

mysql -h 127.0.0.1 -u admin -padmin -P 6032 --execute="
  SAVE admin variables to DISK;
  LOAD admin variables to RUNTIME;
"

IPS=$(curl --silent http://127.0.0.1:8500/v1/catalog/nodes | jq -r '.[] | select(.Meta.service == "proxysql") | .Address')

echo $IPS

LOCAL_IP=$(awk 'END{print $1}' /etc/hosts)

echo $LOCAL_IP

for IP in "${IPS[@]}"
do
  if [ "$IP" != "$LOCAL_IP" ]
  then
  echo $IP
  mysql -h 127.0.0.1 -u admin -padmin -P 6032 --force --execute="
    INSERT OR REPLACE INTO proxysql_servers (
      hostname,
      port,
      weight,
      comment
    ) VALUES (
      '${IP}',
      6032,
      0,
      'ProxySql Servers'
    );"
  fi 
done

mysql -h 127.0.0.1 -u admin -padmin -P 6032 --execute="
  LOAD PROXYSQL SERVERS TO RUNTIME;
  SAVE PROXYSQL SERVERS TO DISK;
"

