
client=client1

function makeClientConf(){
    clientName=$1
    fileName=${clientName}.conf
    cp /usr/share/doc/openvpn/examples/sample-config-files/client.conf /etc/openvpn/client/$fileName

    sed -i '/ca ca.crt/d' /etc/openvpn/client/$fileName
    sed -i '/cert client.crt/d' /etc/openvpn/client/$fileName
    sed -i '/key client.key/d' /etc/openvpn/client/$fileName
    sed -i '/tls-auth ta.key 1/d' /etc/openvpn/client/$fileName

    echo '' >> /etc/openvpn/client/$fileName
    cat /usr/share/easy-rsa/pki/easytls/$clientName.inline >> /etc/openvpn/client/$fileName
}


function makeClient(){
    clientName=$1
    ./easyrsa gen-req $clientName nopass
    ./easyrsa sign-req client $clientName
}

# Make tls-auth.key and make a part of the inline client conf
# The client-1 contains ca, cert, key, and tls-auth
function makeTlsKey(){
    ./easytls init-tls
    ./easytls build-tls-auth
}

function makeTlsAuthInline(){
    clientName=$1
    ./easytls inline-tls-auth $clientName
}

makeClient $client
makeTlsKey
makeTlsAuthInline $client
makeClientConf $client
