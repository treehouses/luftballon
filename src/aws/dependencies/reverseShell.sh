#!/bin/bash

#BASE=$HOME
BASE=/home/pi

sshkey=`treehouses sshtunnel key name | cut -d ' ' -f 5`
#monitorPort=2200
#sshtunnelPortArray=2222:22
#luftballonHostPort=2222
#serverPort=22

# Fetches the SSH host key of the remote server and adds it to known_hosts
# to prevent SSH from asking for confirmation during automated connections
function addKeyFingerprintToKnownHost(){
    local instanceIp=$1
    ssh-keyscan -H $instanceIp | grep ecdsa-sha2-nistp256 >> /home/pi/.ssh/known_hosts
}

function establishPersistenceSSHTunnel(){
    local monitorPort=$1 
    local instanceName=$2

    # autossh command breakdown:
    # -f: Run in the background before executing the command.
    # -T: Disable pseudo-tty allocation.
    # -N: Do not execute remote commands.
    # -q: Enable quiet mode, suppresses most warning and diagnostic messages.
    # -4: Use IPv4 addresses only.
    # -M $monitorPort: Set up the monitoring port for autossh to keep the connection alive.
    # $instanceName: The hostname or IP address of the remote server.

    autossh  -f  -T -N -q -4 -M $monitorPort $instanceName
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

killProcess() {
    local processNumber="$1"

    if [ -n "$processNumber" ]; then
        kill -9 "$processNumber"
        echo "Killed process $processNumber"
    else
        echo "No process to kill"
    fi
}

function closeSSHTunnel(){
    local instanceName=$1
    local processNumber=$(getProcessNumber "$instanceName" "$(getProcessInfo)")
    killProcess $processNumber
    processNumber=$(getProcessNumber "$instanceName" "$(getProcessNumberSsh)")
    killProcess $processNumber
}

# This step is necessary because the client, being behind a firewall or NAT,
# may not be directly accessible from outside its network.
# By connecting to the remote server, the client creates a pathway 
# through which connections can be routed.
function establishSSHConnectionBeforeEstablishSSHTunnel(){
    local instanceIp=$1
    ssh -i /root/.ssh/$sshkey -o StrictHostKeyChecking=no root@$instanceIp 'echo hello world'
    sleep 2
}

function restartSSHTunnel(){
    local instanceName=$1
    local instanceIp=$2
    local monitorPort=2200

    addKeyFingerprintToKnownHost $instanceIp
    establishSSHConnectionBeforeEstablishSSHTunnel $instanceIp

    updateSshConfigInterface $instanceName HostName $instanceIp
    sleep 2
    establishPersistenceSSHTunnel $monitorPort $instanceName
}
