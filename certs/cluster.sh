#!/bin/bash

set -e -o pipefail

if [[ $EUID -ne 0 ]]; then
   echo -e "\e[31mThis script must run as root\e[0m" 1>&2
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

    echo; echo -e "\e[34mRunning the command at $SERVER_NAME@$SERVER_PUBLIC_IP...\e[0m"
    ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -n \
        core@$SERVER_PUBLIC_IP "${@:-":"}"
    echo -e "\e[34mDone\e[0m"; echo
done < $WORKDIR/iplist.txt
