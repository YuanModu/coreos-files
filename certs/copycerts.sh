#!/bin/bash

set -e

if [[ $EUID -ne 0 ]]; then
   echo -e "\e[31mThis script must be run as root\e[0m" 1>&2
   exit 1
fi

WORKDIR=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)
if [ ! -f $WORKDIR/iplist.txt ]; then
    echo "$WORKDIR/iplist.txt not found!"
    exit 1
fi

while read line; do
    SERVER_NAME=$(echo $line | awk '{print $2}')
    SERVER_PUBLIC_IP=$(echo $line | awk '{print $3}')
    SERVER_PRIVATE_IP=$(echo $line | awk '{print $4}')
    
    echo; echo -e "\e[34mUploading files for $SERVER_NAME@$SERVER_PUBLIC_IP\e[0m"
    scp -r -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $WORKDIR/upload/$SERVER_NAME core@$SERVER_PUBLIC_IP:
    echo -e "\e[34mDone\e[0m"; echo
done < $WORKDIR/iplist.txt
