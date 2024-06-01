#!/bin/bash

#BASE=$HOME
BASE=/home/pi

sshkey=`treehouses sshtunnel key name | cut -d ' ' -f 5`
#monitorPort=2200
#sshtunnelPortArray=2222:22
#luftballonHostPort=2222
#serverPort=22

function openNonDefaultSShtunnel(){
    local instanceIp=$1
    local configuredSshTunnelPortArray=("$2")
    local defaultSshtunnelPortArray=($(getSshtunnelConfiguration | sed 's/\n//g'| sed 's/ /,/g' ))

    for _sshtunnelPortSet in "${configuredSshTunnelPortArray[@]}"; do
        if [ -z $(echo "$_sshtunnelPortSet" | grep "$defaultSshtunnelPortArray") ] 
        then
            local sshtunnelPortSet=($(echo $_sshtunnelPortSet | sed 's/:/ /'))
            local luftballonHosPport=${sshtunnelPortSet[0]}
            local serverPort=${sshtunnelPortSet[1]}
            treehouses sshtunnel add port actual "$serverPort" "$luftballonHosPport" root@"$instanceIp"
        fi
    done
}


function deleteUnusedSShtunnel(){
    local instanceIp=$1
    local configuredSshTunnelPortArray="$2"
    local defaultSshtunnelPortArray=($(getSshtunnelConfiguration | sed 's/\n//g'| sed 's/ /,/g' ))

    for _sshtunnelPortSet in "${defaultSshtunnelPortArray[@]}"; do
        if [ -z $(echo "$configuredSshTunnelPortArray" | grep "$_sshtunnelPortSet") ] 
        then
            local sshtunnelPortSet=($(echo $_sshtunnelPortSet | sed 's/:/ /'))
            local luftballonHostPort=${sshtunnelPortSet[0]}
            treehouses sshtunnel remove port $luftballonHostPort root@"$instanceIp"
        fi
    done
}


function addKeyFingerprintToKnownHost(){
    local instanceIp=$1
    ssh-keyscan -H $instanceIp | grep ecdsa-sha2-nistp256 >> /home/pi/.ssh/known_hosts
}

function openSSHTunnel(){
    local instanceIp=$1
    local serverPort=$2
    local luftballonHostPort=$3
    local monitorPort=$4
    local sshtunnelPortArray=$luftballonHostPort:$serverPort

    addKeyFingerprintToKnownHost $instanceIp
    addKeyFingerprintToKnownHost luftballon
    treehouses sshtunnel key name $sshkey
    sleep 2

    ssh -i /root/.ssh/$sshkey -o StrictHostKeyChecking=no admin@$instanceIp "sudo cp /home/admin/.ssh/authorized_keys /root/.ssh/."
    sleep 2

    ssh -i /root/.ssh/$sshkey root@$instanceIp 'echo "GatewayPorts yes" >> /etc/ssh/sshd_config'
    sleep 2

    # Restart SSH service on the remote machine in a detached screen session
    # Use `screen` to run the command in the background, 
    # ensuring it completes even if the SSH connection is lost.
    # This is necessary to apply the changes made to the SSH configuration.
    ssh -i /root/.ssh/$sshkey root@$instanceIp 'screen -m -d bash -c "service ssh restart"'
    sleep 2

    treehouses sshtunnel add host "$monitorPort" root@"$instanceIp"
    #deleteUnusedSShtunnel $instanceIp $sshtunnelPortArray
    openNonDefaultSShtunnel $instanceIp $sshtunnelPortArray

    echo "Below sshtunnels are configured"
    treehouses sshtunnel ports

}
