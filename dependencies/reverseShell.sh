#!/bin/bash

#BASE=$HOME
BASE=/home/pi


sshkey=`treehouses sshtunnel key name`
monitorPort=2200
sshtunnelPortArray=2222:22
luftballonHostPort=2222
serverPort=22
treehouses sshtunnel key name $sshkey

function openNonDefaultSShtunnel(){
    instanceIp=$1
    configuredSshTunnelPortArray=$2
    defaultSshtunnelPortArray=$(getSshtunnelConfiguration | sed 's/\n//g'| sed 's/ /,/g' )

    for _sshtunnelPortSet in "${configuredSshTunnelPortArray[@]}"; do
        if [ -z $(echo "$_sshtunnelPortSet" | grep "$defaultSshtunnelPortArray") ] 
        then
            sshtunnelPortSet=($(echo $_sshtunnelPortSet | sed 's/:/ /'))
            luftballonHosPport=${sshtunnelPortSet[0]}
            serverPort=${sshtunnelPortSet[1]}
            treehouses sshtunnel add port actual "$serverPort" "$luftballonHosPport" root@"$instanceIp"
        fi
    done
}


function deleteUnusedSShtunnel(){
    instanceIp=$1
    configuredSshTunnelPortArray=$2
    defaultSshtunnelPortArray=($(getSshtunnelConfiguration | sed 's/\n//g'| sed 's/ /,/g' ))

    for _sshtunnelPortSet in "${defaultSshtunnelPortArray[@]}"; do
        if [ -z $(echo "$configuredSshTunnelPortArray" | grep "$_sshtunnelPortSet") ] 
        then
            sshtunnelPortSet=($(echo $_sshtunnelPortSet | sed 's/:/ /'))
            luftballonHostPort=${sshtunnelPortSet[0]}
            treehouses sshtunnel remove port $luftballonHostPort root@"$instanceIp"
        fi
    done
}


function addKeyFingerprintToKnownHost(){
    instanceIp=$1
    ssh-keyscan -H $instanceIp | grep ecdsa-sha2-nistp256 >> /home/pi/.ssh/known_hosts
}

function openSSHTunnel(){

    instanceIp=$1
    addKeyFingerprintToKnownHost $instanceIp
    sleep 2

    ssh -o StrictHostKeyChecking=no admin@$instanceIp "sudo cp /home/admin/.ssh/authorized_keys /root/.ssh/."
    sleep 2

    ssh root@$instanceIp 'echo "GatewayPorts yes" >> /etc/ssh/sshd_config'
    sleep 2

    ssh root@$instanceIp 'screen -m -d bash -c "service ssh restart"'
    sleep 2

    treehouses sshtunnel add host "$monitorPort" root@"$instanceIp"
    deleteUnusedSShtunnel $instanceIp $sshtunnelPortArray
    openNonDefaultSShtunnel $instanceIp $sshtunnelPortArray

    echo "Below sshtunnels are configured"
    treehouses sshtunnel ports

}


#treehouses sshtunnel add port actual "$serverPort" "$luftballonHostPort" root@"$instanceIp"
