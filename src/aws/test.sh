#!/bin/bash

#BASE=$HOME
BASE=/home/pi

function test(){
    balloonName=$(setBalloonName "$1")
    if ! isBalloonNameValid "$balloonName"; then
        echo "Please provide a valid balloon name"
        exit 1
    fi

    instanceId=$(getValueByAttribute $balloonName instanceId)

    if [ "$instanceId" = "null" ]; then
        echo "$balloonName is already deleted"
        exit 1
    fi

    publicIp=$(getValueByAttribute $balloonName publicIp)

    echo $publicIp


}