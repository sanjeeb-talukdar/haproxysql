#!/bin/bash
# encoding: UTF-8
set -e

exec >> /var/log/provisioning.log

PIDFILE=/tmp/provisioning.pid
if [ -f $PIDFILE ]
then
  PID=$(cat $PIDFILE)
  ps -p $PID > /dev/null 2>&1
  if [ $? -eq 0 ]
  then
    echo "Process already running"
    exit 1
  else
    ## Process not found assume not running
    echo $$ > $PIDFILE
    if [ $? -ne 0 ]
    then
      echo "Could not create PID file"
      exit 2
    fi
  fi
else
  echo $$ > $PIDFILE
  if [ $? -ne 0 ]
  then
    echo "Could not create PID file"
    exit 3
  fi
fi

LOCAL_IP=$(awk 'END{print $1}' /etc/hosts)

echo "--> Local IP Address: ${LOCAL_IP}"
echo "--> Check MySQL Server in local is running..."
while ! mysqladmin ping --host=$LOCAL_IP --user="monitor" --password="monitor" --silent > /dev/null 2>&1 ; do
  sleep 10
done

MASTER_IP="172.16.238.3"
SLAVES_IP="172.16.238.2"

echo "--> MASTER_IP: ${MASTER_IP}"
echo "--> SLAVES_IP: ${SLAVES_IP[@]}"

if [ -z "$MASTER_IP" ]; then
  echo "--> Is not set variable: MASTER_IP"
  exit 4
fi

IS_MASTER="true"
HOST_IP=$MASTER_IP

if [ "$MASTER_IP" != "$LOCAL_IP" ]
then
  IS_MASTER="false"
  HOST_IP=$SLAVES_IP
fi

if [ $IS_MASTER == "true" ]
  then
    echo "--> Start backup from master: ${HOST_IP}"
    mysqldump --host=$HOST_IP \
              --user=admin \
              --password=admin \
              --all-databases \
              --triggers \
              --routines \
              --events \
              --master-data=1 \
              --single-transaction \
              --quick | mysql --force
  else
    echo "--> Start backup from slave: ${HOST_IP}"
    mysqldump --host=$HOST_IP \
              --user=admin \
              --password=admin \
              --all-databases \
              --triggers \
              --routines \
              --events \
              --dump-slave=1 | mysql --force
			  
	echo "--> Setting replication:"
    mysqlreplicate --master=admin:admin@${MASTER_IP}:3306 \
                 --slave=admin:admin@${LOCAL_IP}:3306 \
                 --rpl-user=repl:repl \
                 -vvv

	echo "--> Set slave for read only."
	mysql --execute="SET GLOBAL read_only = ON;"

fi

if [ -z $(consul kv get -recurse mysql/servers) ]
then
  consul kv put mysql/servers $LOCAL_IP > /dev/null 2>&1
else
  VALUES=$(consul kv get mysql/servers)
  VALUES+=",${LOCAL_IP}"
  VALUES=(${VALUES//,/ })
  VALUES=($(echo "${VALUES[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))
  VALUES=${VALUES[@]}
  VALUES=${VALUES// /,}

  consul kv put mysql/servers $VALUES > /dev/null 2>&1
fi

consul kv put mysql/${LOCAL_IP}/logs/provisioning @/var/log/provisioning.log > /dev/null 2>&1

