#!/bin/bash
# encoding: UTF-8

exec >> /var/log/proxysql-handler.log

[ $# -ge 1 -a -f "$1" ] && INPUT="$1" || INPUT="-"

LOCAL_IP=$(awk 'END{print $1}' /etc/hosts)

echo "ProxySQL-Handler Start ${LOCAL_IP} :: ************************************************"

JSON=$(cat $INPUT)

echo "ProxySQL-Json :: ${JSON}"

if [[ -n "${JSON}" &&  "${JSON}" -eq "null" ]]
then
  echo "ProxySQL-Handler Exit 1 :: No data"
  exit 1
fi

VALUES=$(echo $JSON | jq -r '.[] | .Node | .Address')

echo "ProxySQL-Json VALUES :: ${VALUES[@]}"

ARRAY=(${VALUES//,/ })

echo "ProxySQL-Json ARRAY :: ${ARRAY[@]}"

for IP in "${ARRAY[@]}"
do
  echo "ProxySQL-Handler :: ProxySQL Server IP Found :: ${IP}"
  
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
      'ProxySQL Server ${IP}'
    );"
done

mysql -h 127.0.0.1 -u admin -padmin -P 6032 --execute="
  LOAD PROXYSQL SERVERS TO RUNTIME;
  SAVE PROXYSQL SERVERS TO DISK;
"

echo "ProxySQL-Handler End :: ************************************************"

consul kv put proxysql/${LOCAL_IP}/logs/proxysql-handler @/var/log/proxysql-handler.log > /dev/null 2>&1