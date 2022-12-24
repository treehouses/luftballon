
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
    # TODO 
    # Need to conditonal statement to execute it.
    # I do not understand why the command is needed.
    # ./easytls rehash
    ./easytls inline-tls-auth $clientName
}

function addIPAddress(){
    fileName=$1
    sed -i  "s/my-server-1/$publicIp/" /etc/openvpn/client/$fileName.conf
}

function makeClientCertificate(){
    client=$1
    makeClient $client
    makeTlsAuthInline $client
    makeClientConf $client
    addIPAddress $client
}

function checkFile(){
    directory=/usr/share/easy-rsa/pki/easytls/
    fileName=$1
    FILE=$directory$fileName
    if [ -f "$FILE" ]; then
        read -p "File exists. Do you want to delete it? [Y/n] " choice
        case "$choice" in
            Y|y ) rm $FILE;;
            N|n ) exit;;
            * ) echo "Invalid input. Exiting."; exit;;
        esac
    fi
}

checkFile $client
cd /usr/share/easy-rsa/
makeClientCertificate $client
