
mode=$1
balloonName=$1
manageConfigPath=$(pwd)

if [[ -n "$mode" && "$mode" != "default" && "$mode" != "secure" ]]; then
then
    echo "Invalid mode: $mode. Mode must be 'secure', 'default', or empty."
    exit 1
fi

source $manageConfigPath/../dependencies/config.sh
source $manageConfigPath/../dependencies/utilitiyFunction.sh
source $manageConfigPath/../dependencies/isBalloonNameValid.sh
source $manageConfigPath/../dependencies/jsonOperations.sh
source $manageConfigPath/../dependencies/configOperations.sh
source $manageConfigPath/../dependencies/configFunctions.sh
source $manageConfigPath/../dependencies/getLatestIpAddress.sh
source $manageConfigPath/../dependencies/securitygroupFunction.sh
source $manageConfigPath/../dependencies/manageConfig.sh
source $manageConfigPath/../dependencies/sshtunnelFunction.sh
source $manageConfigPath/../dependencies/reverseShell.sh

source getRunningVPNEntityConfName.sh
source deleteEasytlsIClientnline.sh

startpath=$(pwd)
publicIp=$(getValueByAttribute $balloonName publicIp)

function makeClientConf(){
    clientName=$1
    fileName=$clientName.conf
    if [ "$mode" == "secure" ]
    then
        cp $manageConfigPath/templates/clientSecure.conf /etc/openvpn/client/$fileName
    else
        cp $manageConfigPath/templates/client.conf /etc/openvpn/client/$fileName
    fi

    sed -i '/ca ca.crt/d' /etc/openvpn/client/$fileName
    sed -i '/cert client.crt/d' /etc/openvpn/client/$fileName
    sed -i '/key client.key/d' /etc/openvpn/client/$fileName
    sed -i '/tls-auth ta.key 1/d' /etc/openvpn/client/$fileName

    echo '' >> /etc/openvpn/client/$fileName
    cat /usr/share/easy-rsa/pki/easytls/$clientName.inline >> /etc/openvpn/client/$fileName
    cp /etc/openvpn/client/$fileName $startpath/$fileName
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

# Finds the first missing element in the given array of strings in the form 'client + number', or the next element in a consecutive array.
# If the array is empty, returns 'client1'.
function getDefaultName(){
    array=($(ls /usr/share/easy-rsa/pki/easytls/ | grep client))

    if [ ${#array[@]} -eq 0 ]; then
        echo 'client1'
    else
        prev=''
        missingElementFound=false

        for element in "${array[@]}"
        do
            num=$(echo $element | grep -o '[0-9]*')
            if [ "$num" -ne $((prev+1)) ]; then
                echo $(awk -v num=$num 'BEGIN { print "client" num+1 }')
                missingElementFound=true
                break
            fi
            prev=$num
        done

        if [ "$missingElementFound" = false ]; then
            echo $(echo ${array[-1]} | grep -o '[0-9]*' | awk '{print "client" $0+1}')
        fi
    fi
}

function getClientName(){
    defaultName=$(getDefaultName)
    read -p "Enter the name for the client openVPN config. [default is $defaultName]" client

    if [[ -z "$client" ]]; then
        client=$defaultName
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


