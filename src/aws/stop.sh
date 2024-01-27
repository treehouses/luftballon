#!/bin/bash

#BASE=$HOME
BASE=/home/pi

balloonName=$1

if ! isBalloonNameValid "$balloonName"; then
    echo "Please provide a valid balloon name"
    exit 1
fi

instanceId=$(getValueByAttribute $balloonName instanceId)

if [ "$instanceId" = "null" ]; then
    echo "$balloonName is already deleted"
    exit 1
fi

publicIp=$(waitForOutput "getLatestIpAddress $instanceId")
treehouses sshtunnel remove host root@$publicIp
echo "Delete sshtunnel of root@$publicIp"

aws ec2 stop-instances --instance-ids $instanceId