

# Make pki, one master ca, one server, and one client
function makeVPNServer(){
    cd /usr/share/easy-rsa/
    cp vars.example vars
    ./easyrsa init-pki
    ./easyrsa build-ca nopass
    ./easyrsa gen-req openvpn-server nopass
    ./easyrsa sign-req server openvpn-server
    ./easyrsa gen-dh
}

function makeServerConfiguration(){
    # Make server conf file
    cp /usr/share/doc/openvpn/examples/sample-config-files/server.conf.gz /etc/openvpn/server/
    gunzip /etc/openvpn/server/server.conf.gz

    sed -i 's/ca.crt/\/usr\/share\/easy-rsa\/pki\/ca.crt/g' /etc/openvpn/server/server.conf 
    sed -i 's/server.crt/\/usr\/share\/easy-rsa\/pki\/issued\/openvpn-server.crt/' /etc/openvpn/server/server.conf 
    sed -i 's/server.key/\/usr\/share\/easy-rsa\/pki\/private\/openvpn-server.key/' /etc/openvpn/server/server.conf 
    sed -i 's/dh2048.pem/\/usr\/share\/easy-rsa\/pki\/dh.pem/' /etc/openvpn/server/server.conf 
    sed -i 's/;push "redirect-gateway def1 bypass-dhcp"/push "redirect-gateway def1 bypass-dhcp"/' /etc/openvpn/server/server.conf 
    sed -i 's/;push "dhcp-option DNS 208.67.222.222"/push "dhcp-option DNS 208.67.222.222"/' /etc/openvpn/server/server.conf 
    sed -i 's/;push "dhcp-option DNS 208.67.220.220"/push "dhcp-option DNS 208.67.220.220"/' /etc/openvpn/server/server.conf 
    sed -i 's/tls-auth ta.key 0/tls-auth \/usr\/share\/easy-rsa\/pki\/easytls\/tls-auth.key 0/' /etc/openvpn/server/server.conf
}

function openFireWall(){

    # Open firewall relating to the default vpn port
    sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf 
    sysctl -p

    sed -i "/# Don't delete these required lines, otherwise there will be errors/i \# OPENVPN RULES\n\# NAT\n\*nat\n\:POSTROUTING ACCREPT \[0\:0\]\n\# Allow traffic from OpenVPN client to eth0\n-A POSTROUTING -s 10.8.0.0\/8 -j MASQUERADE\nCOMMIT\n\# END OPENVPN RULES\n\n" /etc/ufw/before.rules

    ufw allow 1194/udp
    ufw allow OpenSSH

    ufw disable
    ufw enable
}

function startVPMServer(){
    # Start openvpn-server
    systemctl -f enable openvpn-server@server.service
    systemctl start openvpn-server@server.service
}

makeVPNServer
makeServerConfiguration
openFireWall
startVPMServer

systemctl status openvpn-server@server.service
