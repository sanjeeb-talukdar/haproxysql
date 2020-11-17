#!/bin/bash
# encoding: UTF-8

exec >> /root/mysql-handler.log

mysql -h 127.0.0.1 -u admin -padmin -P 6032 --force --execute="
    INSERT OR REPLACE INTO mysql_servers (
      hostgroup_id,
      hostname,
      port,
      max_connections,
      max_replication_lag
    ) VALUES (
      1,
      '172.16.238.7',
      3306,
      10,
      60
    );"


mysql -h 127.0.0.1 -u admin -padmin -P 6032 --force --execute="
    INSERT OR REPLACE INTO mysql_servers (
      hostgroup_id,
      hostname,
      port,
      max_connections,
      max_replication_lag
    ) VALUES (
      1,
      '172.16.238.8',
      3306,
      10,
      60
    );"

mysql -h 127.0.0.1 -u admin -padmin -P 6032 --execute="
  LOAD MYSQL SERVERS TO RUNTIME;
  SAVE MYSQL SERVERS TO DISK;
"
