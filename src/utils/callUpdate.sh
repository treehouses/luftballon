#!/bin/bash

function updateSshConfigInterface(){
    local host=$1
    local newKey=$2
    local newValue=$3
    local currentValue
    local ssh_config=$(extractSshConfigToVariables $host)

    if [ $? -ne 0 ]; then
        echo "Failed to execute extractSshConfigToVariables or the command does not exist."
        exit 1
    fi

    while IFS=: read -r key value; do
        key=$(echo "$key" | xargs)
        value=$(echo "$value" | xargs)

        declare "$key=$value"
    done <<< "$ssh_config"

    RemoteForward=$(extractBlocks "$RemoteForward")
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
        "RemoteForward")
            currentValue=$newValue
            if [[ -n "$4" ]]; then
                newValue=$4
            fi
            RemoteForward=$(replaceFirstOccurrence "$RemoteForward" "$currentValue" "$newValue")
            ;;
        *)
            echo "Invalid key."
            exit 1
            ;;
    esac


    updateSshConfig "$host" "$HostName" "$User" "$Port" "$IdentityFile" "$RemoteForward"

}

#update $host "RemoteForward" "8888:80" "8887:81"