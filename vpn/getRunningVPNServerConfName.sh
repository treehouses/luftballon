#!/bin/bash

# If there is a running OpenVPN server in a machine, the script print out the config name
# Otherwise, it print out empty string

ServerDir=/etc/openvpn/server/

function checkFiles(){
    files=$(ls $ServerDir)
    echo $files
}

function checkVPMServerOn(){
    serverConfWithExtention=$1
    serverConf=${serverConfWithExtention%.conf}
    status=$(systemctl status openvpn-server@$serverConf.service)

    if [[ $status == *"Active: active (running)"* ]]; then
        echo "$serverConf"
    fi
}

function getRunningVPNServerConfName(){
    confName=""
    OLD_IFS=$IFS
    IFS=' '

    while read -ra confFiles; do
    for confFile in "${confFiles[@]}"; do
        confName=$(checkVPMServerOn $confFile)
    done
    done <<< $(checkFiles)

    # Restore the original value of IFS
    IFS=$OLD_IFS
    echo $confName
}


