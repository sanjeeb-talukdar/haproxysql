#!/bin/bash
# encoding: UTF-8

exec >> /var/log/mysql-handler.log

[ $# -ge 1 -a -f "$1" ] && INPUT="$1" || INPUT="-"

LOCAL_IP=$(awk 'END{print $1}' /etc/hosts)

echo "MySQL-Handler Start ${LOCAL_IP} :: ************************************************"

JSON=$(cat $INPUT)

echo "MySQL-Json :: ${JSON}"

if [[ -n "${JSON}" &&  "${JSON}" -eq "null" ]]
then
  echo "MySQL-Handler Exit 1 :: No data"
  exit 1
fi

VALUES=$(echo $JSON | jq -r '.[] | select(.Checks[0].Status != "passing") | .Node | .Address')

echo "MySQL-Json INVALID IPS :: ${VALUES[@]}"

ARRAY=(${VALUES//,/ })

for IP in "${ARRAY[@]}"
do
  echo "MySQL-Handler :: MySQL Server INVALID IP Found :: ${IP}"
  
  mysql -h 127.0.0.1 -u admin -padmin -P 6032 --force --execute="
    DELETE FROM mysql_servers WHERE 
      hostname = '${IP}' AND
      port = 3306	
	;"
	
done

###########################################

VALUES=$(echo $JSON | jq -r '.[] | select(.Checks[0].Status == "passing") | .Node | .Address')

echo "MySQL-Json VALUES :: ${VALUES[@]}"

ARRAY=(${VALUES//,/ })

echo "MySQL-Json ARRAY :: ${ARRAY[@]}"

for IP in "${ARRAY[@]}"
do
  echo "MySQL-Handler :: MySQL Server VALID IPS Found :: ${IP}"
  
  mysql -h 127.0.0.1 -u admin -padmin -P 6032 --force --execute="
    INSERT OR REPLACE INTO mysql_servers (
      hostgroup_id,
      hostname,
      port,
      max_connections,
      max_replication_lag
    ) VALUES (
      1,
      '${IP}',
      3306,
      10,
      60
    );"
done

mysql -h 127.0.0.1 -u admin -padmin -P 6032 --execute="
  LOAD MYSQL SERVERS TO RUNTIME;
  SAVE MYSQL SERVERS TO DISK;
"

echo "MySQL-Handler End :: ************************************************"

consul kv put proxysql/${LOCAL_IP}/logs/mysql-handler @/var/log/mysql-handler.log > /dev/null 2>&1

