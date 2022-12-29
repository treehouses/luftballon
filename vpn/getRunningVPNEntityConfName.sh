#!/bin/bash

# If there is a running OpenVPN entity in a machine, the script print out the config name
# Otherwise, it print out empty string

# 

OpenVPNDir=/etc/openvpn/

function getFiles(){
    entityType=$1
    files=$(ls $OpenVPNDir$entityType/)
    echo $files
}

function removeConfExtention(){
    fileWithExtention=$1
    echo ${entityConfWithExtention%.conf}
}

function checkVPMEntityOn(){
    entityConfWithExtention=$1
    entityType=$2
    entityConf=$(removeConfExtention $entityConfWithExtention)

    status=$(systemctl status openvpn-$entityType@$entityConf.service)

    if [[ $status == *"Active: active (running)"* ]]; then
        echo "$entityConf"
    fi
}

# Input should be client or server
function getRunningVPNEntityConfName(){
    entityType=$1
    confName=""
    OLD_IFS=$IFS
    IFS=' '

    echo $entityType

    if [[ $entityType == 'server' || $entityType == 'client' ]]
    then

        while read -ra confFiles; do
            for confFile in "${confFiles[@]}"; do
                confName=$(checkVPMEntityOn $confFile $entityType)
            done
        done <<< $(getFiles $entityType) 
    else
        echo 'Invalid input: Please use server or client as an argument'
    fi

    # Restore the original value of IFS
    IFS=$OLD_IFS
    echo $confName
}

