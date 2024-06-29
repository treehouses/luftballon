#!/bin/bash

#BASE=$HOME
BASE=/home/pi

function restart(){
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

    oldPublicIp=$(getValueByAttribute $balloonName publicIp)

    aws ec2 start-instances --instance-ids $instanceId

    echo "get the new ip address. The procedure might take time for a while"
    publicIp=$(waitForOutput "getLatestIpAddress $instanceId")

    portConfigArray=$(getArrayValueAsStringByKey $instanceName tcpPortArray)

    echo "the new ip address is $publicIp"
    updateIPAddress $balloonName $publicIp

    closeSSHTunnel
    echo "remove old ssh tunnel settings"
    sleep 5

    restartSSHTunnel $balloonName $publicIp
    echo "open new ssh tunnel"
}