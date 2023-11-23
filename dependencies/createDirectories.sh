#!/bin/bash

scriptDir="$(dirname "$0")"

dirPaths=(
    "$scriptDir/vpn/server"
    "$scriptDir/vpn/client"
)

createDirectories() {
    for dirPath in "${dirPaths[@]}"; do
        if [ ! -d "$dirPath" ]; then
            mkdir -p "$dirPath"
        fi
    done
}

getServerDirectory(){
    echo "$scriptDir/vpn/server"
}


getClientDirectory(){
    echo "$scriptDir/vpn/client"
}