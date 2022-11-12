
#!/bin/bash

manageConfigPath=$(pwd)
source $manageConfigPath/dependencies/manageConfig.sh

publicIp=$(extractValueFromTreehousesConfig publicIp)

cp /usr/share/doc/openvpn/examples/sample-config-files/client.conf  /etc/openvpn/client/
scp root@$publicIp:/usr/share/doc/openvpn/examples/sample-config-files/client.conf /etc/openvpn/client/
scp root@$publicIp:/usr/share/easy-rsa/pki/ca.crt /etc/openvpn/client/
scp root@$publicIp:/usr/share/easy-rsa/pki/issued/client-1.crt /etc/openvpn/client/
scp root@$publicIp:/usr/share/easy-rsa/pki/private/client-1.key /etc/openvpn/client/
scp root@$publicIp:/usr/share/easy-rsa/pki/private/tls-auth.key /etc/openvpn/client/

sed -i 's/remote my-server-1 1194/remote publicIp 1194/g' /etc/openvpn/client/client.conf
sed -i "s/publicIp/$publicIp/" /etc/openvpn/client/client.conf
sed -i 's/ca.crt/\/etc\/openvpn\/client\/ca.crt/g' /etc/openvpn/client/client.conf
sed -i 's/client.crt/\/etc\/openvpn\/client\/client-1.crt/g' /etc/openvpn/client/client.conf
sed -i 's/client.key/\/etc\/openvpn\/client\/client-1.key/g' /etc/openvpn/client/client.conf
sed -i 's/ta.key 1/\/etc\/openvpn\/client\/tls-auth.key 1/g' /etc/openvpn/client/client.conf

echo "
script-security 2
up /etc/openvpn/update-systemd-resolved
down /etc/openvpn/update-systemd-resolved
down-pre
dhcp-option DOMAIN-ROUTE ." >> /etc/openvpn/client/client.conf

apt install -y openvpn-systemd-resolved

openvpn --config /etc/openvpn/client/client.conf


