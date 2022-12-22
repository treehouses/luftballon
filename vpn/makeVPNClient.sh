
manageConfigPath=$(pwd)
source $manageConfigPath/../dependencies/manageConfig.sh

publicIp=$(extractValueFromTreehousesConfig publicIp)

client=client1

function makeClientConf(){
    clientName=$1
    fileName=$clientName.conf
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


function makeTlsAuthInline(){
    clientName=$1
    ./easytls inline-tls-auth $clientName
}

function addIPAddress(){
    fileName=$1
    sed -i '/my-server-1/$publicIp/' /etc/openvpn/client/$fileName
}

function makeClientCertificate(){
    client=$1
    makeClient $client
    makeTlsAuthInline $client
    makeClientConf $client
    addIPAddress $client
}

cd /usr/share/easy-rsa/
makeClientCertificate $client
