#!/bin/bash

set -e

if [[ $EUID -ne 0 ]]; then
   echo -e "\e[31mThis script must run as root\e[0m" 1>&2
   exit 1
fi

WORKDIR=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)

echo -e "\e[34m\tCopying SSL certficates and keys...\e[0m"
CERTGROUP=cert
CERTDIR=/etc/ssl/self-signed
mkdir -p $CERTDIR
cp $WORKDIR/{ca,client,client-key,server,server-key,peer,peer-key}.pem $CERTDIR/
groupadd -f $CERTGROUP
gpasswd -a etcd $CERTGROUP
gpasswd -a fleet $CERTGROUP
chgrp -R  $CERTGROUP $CERTDIR/
chmod 0440 $CERTDIR/{ca,client,server,peer}.pem
chmod 0440 $CERTDIR/{client,server,peer}-key.pem
echo -e "\e[34m\tDone\e[0m"
