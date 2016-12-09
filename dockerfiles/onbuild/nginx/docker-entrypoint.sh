#!/bin/bash

set -e

: ${ETCD_PORT:=2379}
: ${HOST_IP:=172.17.0.1}
: ${ETCD:=${HOST_IP}:${ETCD_PORT}}
: ${COREOS_HOSTNAME:=hostname}

function confd {
    command confd -node https://$ETCD \
        -config-file /etc/confd/conf.d/nginx.conf.toml \
        -client-ca-keys /etc/confd/ssl/ca.pem \
        -client-cert /etc/confd/ssl/client.pem \
        -client-key /etc/confd/ssl/client-key.pem \
        "$@";
}

function render {
    : > $2
    while IFS= read line ; do
        while [[ "$line" =~ (\$\{[a-zA-Z_][a-zA-Z_0-9]*\}) ]] ; do
            LHS=${BASH_REMATCH[1]}
            RHS="$(eval echo "\"$LHS\"")"
            line=${line//$LHS/$RHS}
        done
        echo "$line" >> $2
    done < $1
}

if [ "$1" = 'nginx' ]; then
    TOML=$(mktemp)
    TMPL=$(mktemp)
    render /etc/confd/conf.d/nginx.conf.toml $TOML
    render /etc/confd/templates/nginx.conf.tmpl $TMPL
    mv $TOML /etc/confd/conf.d/nginx.conf.toml
    mv $TMPL /etc/confd/templates/nginx.conf.tmpl

    # Try to make initial configuration every 5 seconds until successful
    until confd -onetime; do
        echo "[confd] waiting for confd to create initial nginx configuration"
        sleep 5
    done

    # Put a continual polling `confd` process into the background to watch
    # for changes every 10 seconds
    confd -interval 10 &
    echo "[confd] confd is now monitoring etcd for changes on nginx configuration..."
fi

exec "$@"
