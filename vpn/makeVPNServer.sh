#!/bin/bash

source $manageConfigPath/../dependencies/createDirectories.sh

mode=$1
serverName=openvpn-server

createDirectories

if [[ -n "$mode" && "$mode" != "default" && "$mode" != "proxy" ]]; 
then
    echo "Invalid mode: $mode. Mode must be 'proxy', 'default', or empty."
    exit 1
fi

function getServerConfName(){
    serverName=server
    defaultName=$clientName.conf
    proxyName=${clientName}Proxy.conf
    if [ "$mode" == "proxy" ]
    then
        echo $proxyName
    else
        echo $defaultName
    fi
}

# Make pki, one master ca, and one server
function makeVPNServer(){
    serverConfName=$(getServerConfName)
    cp ./templates/$serverConfName /etc/openvpn/server/
    
    cd /usr/share/easy-rsa/
    cp vars.example vars
    ./easyrsa init-pki
    ./easyrsa build-ca nopass
    ./easyrsa gen-req $serverName nopass
    ./easyrsa sign-req server $serverName
    ./easyrsa gen-dh
}

function makeTlsKey(){
    ./easytls init-tls
    ./easytls build-tls-auth
}

function makeServerConfiguration(){
    serverConfName=$(getServerConfName)
    ./easytls ita $serverName 0
    cat /usr/share/easy-rsa/pki/easytls/$serverName.inline  >> /etc/openvpn/server/$serverConfName
    sed -i '/dh none/d' /etc/openvpn/server/$serverConfName
    echo \<dh\> >> /etc/openvpn/server/$serverConfName
    cat /usr/share/easy-rsa/pki/dh.pem >> /etc/openvpn/server/$serverConfName
    echo \<\/dh\> >> /etc/openvpn/server/$serverConfName
}

function startVPNServer(){
    # Start openvpn-server
    status=$(systemctl status openvpn-server@server.service)
    if [[ $status == *"Active: active (running)"* ]]; then
        systemctl restart openvpn-server@server.service
    else
        systemctl -f enable openvpn-server@server.service
        systemctl start openvpn-server@server.service
    fi
}

function makeVPNServerOnly(){
    makeVPNServer
    makeTlsKey
    makeServerConfiguration
}

function makeVPNServerAndStartVPNServer(){
    makeVPNServerOnly
    startVPNServer
    systemctl status openvpn-server@server.service
}

makeVPNServerOnly

