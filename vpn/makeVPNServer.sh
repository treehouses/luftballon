
serverName=openvpn-server

# Make pki, one master ca, one server, and one client
function makeVPNServer(){
    cp ./server.conf /etc/openvpn/server/
    cd /usr/share/easy-rsa/
    cp vars.example vars
    #echo "luftballon\nluftballon\nyes\n" | ./easyrsa init-pki
    #echo "luftballon\nluftballon\nyes\n" | ./easyrsa build-ca nopass
    #echo "luftballon\nluftballon\nyes\n" | ./easyrsa gen-req openvpn-server nopass
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
    ./easytls ita $serverName 0
    cat /usr/share/easy-rsa/pki/easytls/$serverName.inline  >> /etc/openvpn/server/server.conf
    sed -i '/dh none/d' /etc/openvpn/server/server.conf
    echo \<dh\> >> /etc/openvpn/server/server.conf
    cat /usr/share/easy-rsa/pki/dh.pem >> /etc/openvpn/server/server.conf
    echo \<\/dh\> >> /etc/openvpn/server/server.conf
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