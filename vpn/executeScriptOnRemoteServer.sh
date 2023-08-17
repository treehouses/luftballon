#!/bin/bash

balloonName=$1
mode=$2

# Check the mode
if [[ -n "$mode" && "$mode" != "default" && "$mode" != "proxy" ]]; then
    echo "Invalid mode: $mode. Mode must be 'proxy', 'default', or empty."
    exit 1
fi

manageConfigPath=$(pwd)

source $manageConfigPath/../dependencies/config.sh
source $manageConfigPath/../dependencies/utilitiyFunction.sh
source $manageConfigPath/../dependencies/isBalloonNameValid.sh
source $manageConfigPath/../dependencies/jsonOperations.sh
source $manageConfigPath/../dependencies/configOperations.sh
source $manageConfigPath/../dependencies/configFunctions.sh
source $manageConfigPath/../dependencies/getLatestIpAddress.sh
source $manageConfigPath/../dependencies/securitygroupFunction.sh
source $manageConfigPath/../dependencies/manageConfig.sh
source $manageConfigPath/../dependencies/sshtunnelFunction.sh
source $manageConfigPath/../dependencies/reverseShell.sh

publicIp=$(getValueByAttribute $balloonName publicIp)

echo $publicIp

sshkey=`treehouses sshtunnel key name | cut -d ' ' -f 5`

ssh -i /root/.ssh/$sshkey root@$publicIp "
    apt update && apt upgrade &&  apt install -y openvpn"


if [ "$mode" == "proxy" ]
then
    scp -i /root/.ssh/$sshkey /etc/openvpn/server/serverProxy.conf root@$publicIp:/etc/openvpn/server/
else
    scp -i /root/.ssh/$sshkey /etc/openvpn/server/server.conf root@$publicIp:/etc/openvpn/server/
fi


ssh -i /root/.ssh/$sshkey root@$publicIp " 
    ipAddress=\$(ip a | grep -A 1 eth0 | awk '\$1 == \"inet\" {print \$2}' | sed -n 's/\([0-9\.]\+\).*/\1/p' ); 
    line1=\"push \\\"route \$ipAddress\\\"\"; 
    line2='client-to-client'
    sed -i \"/# EASYTLS/i \$line1\\\n\$line2\" /etc/openvpn/server/server.conf;
    systemctl -f enable openvpn-server@server.service;
    systemctl start openvpn-server@server.service;
    systemctl status openvpn-server@server.service"


if [ "$mode" == "proxy" ]
then
    ssh -i /root/.ssh/$sshkey root@$publicIp " 
        iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE;
        echo 1 > /proc/sys/net/ipv4/ip_forward"
fi
