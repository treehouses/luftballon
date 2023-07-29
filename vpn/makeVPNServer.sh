mode=$1
serverName=openvpn-server

if [[ -n "$mode" && "$mode" != "default" && "$mode" != "secure" ]]; then
then
    echo "Invalid mode: $mode. Mode must be 'secure', 'default', or empty."
    exit 1
fi

function makeVPNServer(){
    if [ "$mode" == "secure" ]
    then
        cp ./templates/serverSecure.conf /etc/openvpn/server/
    else
        cp ./templates/server.conf /etc/openvpn/server/
    fi
    
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

