#!/bin/bash

manageConfigPath=$(pwd)
source $manageConfigPath/../dependencies/manageConfig.sh

publicIp=$(extractValueFromTreehousesConfig publicIp)

echo $publicIp

ssh root@$publicIp '
    apt update && apt install -y openvpn'

scp /etc/openvpn/server/server.conf root@$publicIp:/etc/openvpn/server/

ssh root@$publicIp '
    systemctl -f enable openvpn-server@server.service;
    systemctl start openvpn-server@server.service;
    systemctl status openvpn-server@server.service'
