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

folders=("ca" "client" "server" "peer" "ssh" "upload")
for i in "${folders[@]}"
do
	echo -e "\e[34mRemoving $i folder...\e[0m"
	rm -f -r $WORKDIR/$i
done

echo -e "\e[34mDone\e[0m"; echo

