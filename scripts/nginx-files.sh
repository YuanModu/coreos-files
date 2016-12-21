#!/bin/bash

set -e -o pipefail

export ETCDCTL_OPTS="\
    --endpoint https://127.0.0.1:2379 \
    --cert-file /etc/ssl/self-signed/client.pem \
    --key-file /etc/ssl/self-signed/client-key.pem \
    --ca-file /etc/ssl/self-signed/ca.pem"

export RSYNC_COMMON_OPTS="\
    -avzP \
    --rsh 'ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'"

export SSH_OPTS="\
    -n \
    -o StrictHostKeyChecking=no \
    -o UserKnownHostsFile=/dev/null"

NGINX_DOMAIN=$(echo "$ETCD_WATCH_KEY" | cut -d "/" -f5)
UWSGI_SERVERS=($(etcdctl $ETCDCTL_OPTS ls /services/uwsgi))
UPSTREAMS=()
case "$ETCD_WATCH_ACTION" in
    set)
        for SERVER in "${UWSGI_SERVERS[@]##*/}"; do
            UWSGI_DOMAIN=$(etcdctl $ETCDCTL_OPTS get /services/uwsgi/$SERVER/server)
            if [[ $UWSGI_DOMAIN = $NGINX_DOMAIN ]]; then
                UPSTREAMS+=($(etcdctl $ETCDCTL_OPTS get /services/uwsgi/$SERVER/ip))
            fi
        done
        if [[ "${#UPSTREAMS[@]}" -gt "0" ]]; then
            mkdir -p /var/www/$NGINX_DOMAIN/static
            UPSTREAM=${UPSTREAMS[$RANDOM % ${#UPSTREAMS[@]}]}
               ssh ${SSH_OPTS} core@$UPSTREAM "\
                   docker exec uwsgi \
                       python /usr/share/webapp/manage.py collectstatic --noinput"
               rsync --force --delete ${RSYNC_COMMON_OPTS} \
                   core@$UPSTREAM:/mnt/uwsgi-1/static/ /var/www/$NGINX_DOMAIN/static
        fi;;
    delete)
        rm -r /var/www/$NGINX_DOMAIN;;
esac
