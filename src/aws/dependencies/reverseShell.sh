#!/bin/bash

#BASE=$HOME
BASE=/home/pi

sshkey=`treehouses sshtunnel key name | cut -d ' ' -f 5`
#monitorPort=2200
#sshtunnelPortArray=2222:22
#luftballonHostPort=2222
#serverPort=22

function addKeyFingerprintToKnownHost(){
    local instanceIp=$1
    ssh-keyscan -H $instanceIp | grep ecdsa-sha2-nistp256 >> /home/pi/.ssh/known_hosts
}

function openSSHTunnel(){
    local instanceName=$1
    local instanceIp=$2
    local sshtunnelPortArray=$3
    local monitorPort=2200

    addKeyFingerprintToKnownHost $instanceIp
    treehouses sshtunnel key name $sshkey
    sleep 2

    ssh -i /root/.ssh/$sshkey -o StrictHostKeyChecking=no admin@$instanceIp "sudo cp /home/admin/.ssh/authorized_keys /root/.ssh/."
    sleep 2

    ssh -i /root/.ssh/$sshkey root@$instanceIp 'echo "GatewayPorts yes" >> /etc/ssh/sshd_config'
    sleep 2

    ssh -i /root/.ssh/$sshkey root@$instanceIp 'screen -m -d bash -c "service ssh restart"'
    sleep 2

    createSshConfig $instanceName $instanceIp "root" "22" "~/.ssh/id_rsa" $sshtunnelPortArray
    autossh  -f  -T -N -q -4 -M $monitorPort $instanceName
}

function closeSSHTunnel(){
    local instanceName=$1
    local processNumber=$(getProcessNumber "$instanceName" "$(getProcessInfo)")
    if [ -n "$processNumber" ]; then
        kill -9 $processNumber
    fi
}

function restartSSHTunnel(){
    local instanceName=$1
    local instanceIp=$2
    local monitorPort=2200
    updateSshConfigInterface $instanceName HostName $instanceIp
    autossh  -f  -T -N -q -4 -M $monitorPort $instanceName
}
