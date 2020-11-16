#!/bin/bash
# encoding: UTF-8

exec >> /root/proxysql-handler.log

[ $# -ge 1 -a -f "$1" ] && INPUT="$1" || INPUT="-"

JSON=$(cat $INPUT)

if [[ -n "${JSON}" &&  "${JSON}" -eq "null" ]]
then
  echo "No data"
  exit 1
fi

VALUES=$(echo $JSON | jq -r '.Value' | base64 --decode)
ARRAY=(${VALUES//,/ })

for IP in "${ARRAY[@]}"
do
  echo $IP
  mysql -h 127.0.0.1 -u admin -padmin -P 6032 --force --execute="
    INSERT INTO proxysql_servers (
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
done

mysql -h 127.0.0.1 -u admin -padmin -P 6032 --execute="
  LOAD PROXYSQL SERVERS TO RUNTIME;
  SAVE PROXYSQL SERVERS TO DISK;
"
