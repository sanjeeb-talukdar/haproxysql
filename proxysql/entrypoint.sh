#!/bin/bash
# encoding: UTF-8

# set -e

echo '[Entrypoint] Start consul agent.'

cat /etc/consul.d/config.json

LOCAL_IP=$(hostname -I)

echo '[Entrypoint] 1. Local IP $LOCAL_IP'

LOCAL_IP=$(awk 'END{print $1}' /etc/hosts)

echo '[Entrypoint] 2. Local IP $LOCAL_IP'

envsubst < "/etc/consul.d/config.json" | sponge "/etc/consul.d/config.json"

cat /etc/consul.d/config.json

consul agent -config-file=/etc/consul.d/config.json &

echo '[Entrypoint] Start ProxySQL!'

/usr/bin/proxysql --initial -f -c /etc/proxysql.cnf 


