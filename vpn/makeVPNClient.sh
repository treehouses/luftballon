
manageConfigPath=$(pwd)
source $manageConfigPath/../dependencies/manageConfig.sh
source getRunningVPNEntityConfName.sh
source deleteEasytlsIClientnline.sh

publicIp=$(extractValueFromTreehousesConfig publicIp)


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


function errorCheck(){
    result=$1
    if [[ $status == *"Error: verify_master_hash"* ]]; then
        echo 0
    else
        echo -1
    fi
}

function makeTlsAuthInline(){
    clientName=$1
    # TODO 
    # Need to conditonal statement to execute it.
    # I do not understand why the command is needed.
    # ./easytls rehash
    result=$(./easytls inline-tls-auth $clientName)
    isError=$(errorCheck $result)
    if [ $isError==0 ]; then
        ./easytls rehash
        ./easytls inline-tls-auth $clientName
    fi
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

function getClientName(){
    read -p "Enter the name for the client openVPN config. [default is client1]" client

    if [[ -z "$client" ]]; then
        client=client1
    fi
    echo $client
}

function makeClientConfig(){
    client=$(getClientName)
    checkFile $client
    deleteEasytlsIClientnline $client
    cd /usr/share/easy-rsa/
    makeClientCertificate $client
}

function makeClientConfigAndStart(){
    client=$(getClientName)
    checkFile $client
    deleteEasytlsIClientnline $client
    cd /usr/share/easy-rsa/
    makeClientCertificate $client
    systemctl enable openvpn-client@$client.service
    systemctl start openvpn-client@$client.service
    systemctl status openvpn-client@$client.service
}

function stopVPNEntityIfRunning(){
    entityType=$1
    vpnEntityName=$(getRunningVPNEntityConfName $entityType)
    if [ -n "$vpnEntityName" ]; then
        echo "Stop VPN $entityType whose name is $vpnEntityName"
        systemctl stop openvpn-$entityType@$vpnEntityName.service
        systemctl disable openvpn-$entityType@$vpnEntityName.service
    fi
}

stopVPNEntityIfRunning server
stopVPNEntityIfRunning client
read -p "Do you start openVPN client on this machine? If not, the script just make client config [Y/n] " choice
case $choice in
    Y|y ) makeClientConfigAndStart;; 
    N|n ) makeClientConfig;;
    * ) echo "Invalid input. Exiting."; exit;;
esac


