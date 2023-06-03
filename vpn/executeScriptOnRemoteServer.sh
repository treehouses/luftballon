#!/bin/bash

manageConfigPath=$(pwd)
source $manageConfigPath/../dependencies/manageConfig.sh

publicIp=$(getTreehousesConfigValue publicIp)

echo $publicIp


sshkey=`treehouses sshtunnel key name | cut -d ' ' -f 5`

ssh -i /root/.ssh/$sshkey root@$publicIp '
    apt update && apt install -y openvpn'

scp -i /root/.ssh/$sshkey /etc/openvpn/server/server.conf root@$publicIp:/etc/openvpn/server/

ssh -i /root/.ssh/$sshkey root@$publicIp " 
    ipAddress=\$(ip a | grep -A 1 eth0 | awk '\$1 == \"inet\" {print \$2}' | sed -n 's/\([0-9\.]\+\).*/\1/p' ); 
    line1=\"push \\\"route \$ipAddress\\\"\"; 
    line2='client-to-client'
    sed -i \"/# EASYTLS/i \$line1\\\n\$line2\" /etc/openvpn/server/server.conf;
    systemctl -f enable openvpn-server@server.service;
    systemctl start openvpn-server@server.service;
    systemctl status openvpn-server@server.service"
