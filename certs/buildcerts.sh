#!/bin/bash

set -e

if [[ $EUID -ne 0 ]]; then
   echo -e "\e[31mThis script must run as root\e[0m" 1>&2
   exit 1
fi

hash expect &>/dev/null || {
	echo "\"/bin/expect\" couldn't find"
	exit 1
}

hash ssh-keygen &>/dev/null || {
	echo "\"/bin/ssh-keygen\" couldn't find"
	exit 1
}

WORKDIR=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)
if [ ! -f $WORKDIR/iplist.txt ]; then
    echo "$WORKDIR/iplist.txt not found!"
    exit 1
fi

export GOPATH=$WORKDIR/gocode
export PATH=$PATH:$GOPATH/bin
export TCLPATH=$WORKDIR/tclcode
export PATH=$PATH:$TCLPATH

render() {
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

hash cfssl &>/dev/null || {
    echo; echo -e "\e[34mDownloading and building cfssl...\e[0m"
    go get -u github.com/cloudflare/cfssl/cmd/cfssl
    chmod +x $GOPATH/bin/cfssl
    echo -e "\e[34mDone\e[0m"; echo
}

hash cfssljson &>/dev/null || {
    echo; echo -e "\e[34mDownloading and building cfssljson...\e[0m"
    go get -u github.com/cloudflare/cfssl/cmd/cfssljson
    chmod +x $GOPATH/bin/cfssljson
    echo -e "\e[34mDone\e[0m"; echo
}

echo -e "\e[34mStart building certificates\e[0m"

echo; echo -e "\e[34mGenerating the Certificate Authority...\e[0m"
mkdir -p $WORKDIR/ca
touch $WORKDIR/ca/ca-key.pem
chmod 0600 $WORKDIR/ca/ca-key.pem
cfssl gencert -initca $WORKDIR/ca-csr.json | cfssljson -bare $WORKDIR/ca/ca -
rm -f $WORKDIR/ca/ca.csr
echo -e "\e[34mDone\e[0m"; echo

echo; echo -e "\e[34mGenerating client profile certificates...\e[0m"
mkdir -p $WORKDIR/client
touch $WORKDIR/client/client-key.pem
chmod 0600 $WORKDIR/client/client-key.pem
cfssl gencert -ca=$WORKDIR/ca/ca.pem -ca-key=$WORKDIR/ca/ca-key.pem -config=$WORKDIR/ca-config.json -profile=client $WORKDIR/client.json | cfssljson -bare $WORKDIR/client/client
rm -f $WORKDIR/client/client.csr
echo -e "\e[34mDone\e[0m"; echo

while read line; do
    echo; echo -e "\e[34mGenerating server profile certificate for $SERVER_NAME@$SERVER_PUBLIC_IP...\e[0m"
    SERVER_NAME=$(echo $line | awk '{print $2}')
    SERVER_PUBLIC_IP=$(echo $line | awk '{print $3}')
    SERVER_PRIVATE_IP=$(echo $line | awk '{print $4}')

    mkdir -p $WORKDIR/server/$SERVER_NAME
    render $WORKDIR/server.json.tmpl $WORKDIR/server/$SERVER_NAME/server.json
    cfssl gencert -ca=$WORKDIR/ca/ca.pem -ca-key=$WORKDIR/ca/ca-key.pem -config=$WORKDIR/ca-config.json -profile=server $WORKDIR/server/$SERVER_NAME/server.json | cfssljson -bare $WORKDIR/server/$SERVER_NAME/server
    rm -f $WORKDIR/server/$SERVER_NAME/{server.json,server.csr}
    echo -e "\e[34mDone\e[0m"; echo
done < $WORKDIR/iplist.txt

while read line; do
    echo; echo -e "\e[34mGenerating peer profile certificate for $SERVER_NAME@$SERVER_PUBLIC_IP...\e[0m"
    SERVER_NAME=$(echo $line | awk '{print $2}')
    SERVER_PUBLIC_IP=$(echo $line | awk '{print $3}')
    SERVER_PRIVATE_IP=$(echo $line | awk '{print $4}')

    mkdir -p $WORKDIR/peer/$SERVER_NAME
    render $WORKDIR/peer.json.tmpl $WORKDIR/peer/$SERVER_NAME/peer.json
    cfssl gencert -ca=$WORKDIR/ca/ca.pem -ca-key=$WORKDIR/ca/ca-key.pem -config=$WORKDIR/ca-config.json -profile=peer $WORKDIR/peer/$SERVER_NAME/peer.json | cfssljson -bare $WORKDIR/peer/$SERVER_NAME/peer
    rm -f $WORKDIR/peer/$SERVER_NAME/{peer.json,peer.csr}
    echo -e "\e[34mDone\e[0m"; echo
done < $WORKDIR/iplist.txt

while read line; do
    echo; echo -e "\e[34mGenerating SSH keys for $SERVER_NAME@$SERVER_PUBLIC_IP...\e[0m"
    SERVER_NAME=$(echo $line | awk '{print $2}')
    SERVER_PUBLIC_IP=$(echo $line | awk '{print $3}')
    SERVER_PRIVATE_IP=$(echo $line | awk '{print $4}')

	mkdir -p $WORKDIR/ssh/$SERVER_NAME
    expect $WORKDIR/makesshkey.exp $SERVER_NAME $WORKDIR/ssh/$SERVER_NAME
    echo -e "\e[34mDone\e[0m"; echo
done < $WORKDIR/iplist.txt

while read line; do
    echo; echo -e "\e[34mCollecting files for $SERVER_NAME@$SERVER_PUBLIC_IP...\e[0m"
    SERVER_NAME=$(echo $line | awk '{print $2}')
    SERVER_PUBLIC_IP=$(echo $line | awk '{print $3}')
    SERVER_PRIVATE_IP=$(echo $line | awk '{print $4}')

	mkdir -p $WORKDIR/upload/$SERVER_NAME
    cp $WORKDIR/ca/ca.pem $WORKDIR/upload/$SERVER_NAME/
    cp $WORKDIR/client/client{.pem,-key.pem} $WORKDIR/upload/$SERVER_NAME/
    cp $WORKDIR/server/$SERVER_NAME/server{.pem,-key.pem} $WORKDIR/upload/$SERVER_NAME/
    cp $WORKDIR/peer/$SERVER_NAME/peer{.pem,-key.pem} $WORKDIR/upload/$SERVER_NAME/
    cp $WORKDIR/ssh/$SERVER_NAME/id_rsa{,.pub} $WORKDIR/upload/$SERVER_NAME/
    cp $WORKDIR/{setetcd.sh,setip.sh,iplist.txt} $WORKDIR/upload/$SERVER_NAME/
    echo -e "\e[34mDone\e[0m"; echo
done < $WORKDIR/iplist.txt

echo; echo -e "\e[34mFinished building certificates\e[0m"
