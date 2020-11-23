#!/bin/bash
# encoding: UTF-8

set -e

echo '[Entrypoint] Start consul agent.'

envsubst < "/etc/consul.d/config.json" | sponge "/etc/consul.d/config.json"

consul agent -config-file=/etc/consul.d/config.json &

deregister_node() {
    echo "Deregistering Node!!"
	consul leave
    exit
}

trap deregister_node SIGINT SIGQUIT SIGTERM

echo '[Entrypoint] Start ProxySQL!'

/usr/bin/proxysql --initial -f -c /etc/proxysql.cnf 


