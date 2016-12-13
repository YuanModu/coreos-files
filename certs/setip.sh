#!/bin/bash

set -e

if [[ $EUID -ne 0 ]]; then
   echo -e "\e[31mThis script must run as root\e[0m" 1>&2
   exit 1
fi

WORKDIR=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)

set -a
source /etc/environment
set +a

echo -e "\e[34m\tEnableing peer IPs...\e[0m"
while read line; do
    SERVER_PRIVATE_IP=$(echo $line | awk '{print $4}')
    if ! [ "$SERVER_PRIVATE_IP" = "$COREOS_PRIVATE_IPV4" ]; then
        systemctl enable iptables-private\@$SERVER_PRIVATE_IP
    fi
done < $WORKDIR/iplist.txt
systemctl restart iptables-private.target
echo -e "\e[34m\tDone\e[0m"
