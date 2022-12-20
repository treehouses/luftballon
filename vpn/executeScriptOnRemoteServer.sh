#!/bin/bash

manageConfigPath=$(pwd)
source $manageConfigPath/../dependencies/manageConfig.sh

publicIp=$(extractValueFromTreehousesConfig publicIp)

echo $publicIp

#scp installOpenVPVServer.sh root@$instanceId:~/
#ssh root@$instanceId 'bash installOpenVPVServer.sh'

ssh root@$publicIp '
    apt update;
    apt install -y gnupg;
    curl -fsSL https://swupdate.openvpn.net/repos/repo-public.gpg | gpg --dearmor > /etc/apt/trusted.gpg.d/openvpn-repo-public.gpg;
    echo "deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/openvpn-repo-public.gpg] https://build.openvpn.net/debian/openvpn/stable buster main" > /etc/apt/sources.list.d/openvpn-aptrepo.list;
    apt-get update && apt-get install -y openvpn ufw unzip'

scp /etc/openvpn/server/server.conf root@$publicIp:/etc/openvpn/server/

ssh root@$publicIp '
    systemctl -f enable openvpn-server@server.service;
    systemctl start openvpn-server@server.service;
    systemctl status openvpn-server@server.service'
