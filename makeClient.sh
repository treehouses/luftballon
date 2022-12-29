#!/bin/bash

cp /usr/share/doc/openvpn/examples/sample-config-files/client.conf  /etc/openvpn/client/
cp ./client.conf /etc/openvpn/client/
cp ./ca.crt /etc/openvpn/client/
cp ./client-1.crt /etc/openvpn/client/
cp ./client-1.key /etc/openvpn/client/
cp ./ta.key /etc/openvpn/client/

sed -i 's/remote my-server-1 1194/remote publicIp 1194/g' /etc/openvpn/client/client.conf
sed -i "s/publicIp/$publicIp/" /etc/openvpn/client/client.conf
sed -i 's/ca.crt/\/etc\/openvpn\/client\/ca.crt/g' /etc/openvpn/client/client.conf
sed -i 's/client.crt/\/etc\/openvpn\/client\/client-1.crt/g' /etc/openvpn/client/client.conf
sed -i 's/client.key/\/etc\/openvpn\/client\/client-1.key/g' /etc/openvpn/client/client.conf
sed -i 's/ta.key 1/\/etc\/openvpn\/client\/ta.key 1/g' /etc/openvpn/client/client.conf

#echo "
#script-security 2
#up /etc/openvpn/update-systemd-resolved
#down /etc/openvpn/update-systemd-resolved
#down-pre
#dhcp-option DOMAIN-ROUTE ." >> /etc/openvpn/client/client.conf

cp /etc/openvpn/client/client.conf ./