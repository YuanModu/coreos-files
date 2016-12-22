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
    SERVER_TYPE=$(echo $line | awk '{print $1}')
    SERVER_NAME=$(echo $line | awk '{print $2}')
    SERVER_PUBLIC_IP=$(echo $line | awk '{print $3}')
    SERVER_PRIVATE_IP=$(echo $line | awk '{print $4}')

    echo; echo -e "\e[34mSetting server $SERVER_NAME@$SERVER_PUBLIC_IP...\e[0m"
    case "$SERVER_TYPE" in
        app)
            ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -n \
            core@$SERVER_PUBLIC_IP "\
                sudo $SERVER_NAME/setetcd.sh; \
                sudo $SERVER_NAME/setip.sh; \
                cp $SERVER_NAME/id_rsa{,.pub} ~/.ssh/";;
        dat)
            ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -n \
            core@$SERVER_PUBLIC_IP "\
                sudo $SERVER_NAME/setip.sh; \
                cp $SERVER_NAME/id_rsa{,.pub} ~/.ssh/";;
    esac

    TMP=$(mktemp)
    while read line; do
        SUB_SERVER_NAME=$(echo $line | awk '{print $2}')
        SUB_SERVER_PUBLIC_IP=$(echo $line | awk '{print $3}')
        SUB_SERVER_PRIVATE_IP=$(echo $line | awk '{print $4}')
        SUB_SERVER_DIR=$WORKDIR/upload/$SUB_SERVER_NAME
        if [[ $SERVER_NAME != $SUB_SERVER_NAME ]]; then
            cat $SUB_SERVER_DIR/id_rsa.pub >> $TMP
        fi
    done < $WORKDIR/iplist.txt
    cat $TMP | ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
        core@$SERVER_PUBLIC_IP "cat >> ~/.ssh/authorized_keys"
    rm -f $TMP
    echo -e "\e[34mDone\e[0m"; echo
done < $WORKDIR/iplist.txt
