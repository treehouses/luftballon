#!/bin/bash

source update.sh
source retrieve.sh

host="remoteserver1"

ssh_config=$(extract_ssh_config_to_variables $host)

function update(){
    host=$1
    newKey=$2
    newValue=$3

    if [ $? -ne 0 ]; then
        echo "Failed to execute extract_ssh_config_to_variables or the command does not exist."
        exit 1
    fi

    while IFS=: read -r key value; do
        key=$(echo "$key" | xargs)
        value=$(echo "$value" | xargs)

        declare "$key=$value"
    done <<< "$ssh_config"

    case "$newKey" in
        "HostName")
            HostName=$newValue
            ;;
        "User")
            User=$newValue
            ;;
        "Port")
            Port=$newValue
            ;;
        "IdentityFile")
            IdentityFile=$newValue
            ;;
        "ServerAliveInterval")
            ServerAliveInterval=$newValue
            ;;
        "ServerAliveCountMax")
            ServerAliveCountMax=$newValue
            ;;
        "ExitOnForwardFailure")
            ExitOnForwardFailure=$newValue
            ;;
        "TCPKeepAlive")
            TCPKeepAlive=$newValue
            ;;
        *)
            echo "Invalid key."
            exit 1
            ;;
    esac

    update_ssh_config "$host" "$HostName" "$User" "$Port" "$IdentityFile" "2222:88"

}

update $host "HostName" "newremoteserver.com"