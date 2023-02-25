#!/bin/bash

manageConfigPath=$(pwd)
source $manageConfigPath/../dependencies/manageConfig.sh

publicIp=$(extractValueFromTreehousesConfig publicIp)

echo $publicIp

sshkey=`treehouses sshtunnel key name | cut -d ' ' -f 5`

ssh -i /root/.ssh/$sshkey root@$publicIp '
    apt update && apt install -y openvpn'

scp -i /root/.ssh/$sshkey /etc/openvpn/server/server.conf root@$publicIp:/etc/openvpn/server/

ssh -i /root/.ssh/$sshkey root@$publicIp '
    systemctl -f enable openvpn-server@server.service;
    systemctl start openvpn-server@server.service;
    systemctl status openvpn-server@server.service'
