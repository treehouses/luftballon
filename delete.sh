#!/bin/bash

manageConfigPath=$(pwd)
source $manageConfigPath/dependencies/manageConfig.sh
source $manageConfigPath/dependencies/jsonController.sh
source $manageConfigPath/dependencies/storeConfigByJson.sh
source $manageConfigPath/dependencies/config.sh

#BASE=$HOME
BASE=/home/pi

balloonName=$1

isBalloonNameValid() {
    balloonName="$1"
    balloonNamesString=$(getBalloonNameAsArray)

    if echo "$balloonNamesString" | grep -q -w -- "$balloonName"; then
        return 0
    else
        return 1
    fi
}



if ! isBalloonNameValid "$balloonName"; then
    echo "Please provide a valid balloon name"
    exit 1
fi


keyName=$(getValueByAttribute $balloonName key)
instanceId=$(getValueByAttribute $balloonName instanceId)
groupName=$(getValueByAttribute $balloonName groupName)

storePortArrayString $groupName tcp $balloonName
storePortArrayString $groupName udp $balloonName
updateSshtunnelConfig $balloonName

echo $instanceId
aws ec2 terminate-instances --instance-ids $instanceId 
echo "ec2 instance delete"

echo $keyName
aws ec2 delete-key-pair --key-name $keyName
echo "security key delete"

treehouses sshtunnel remove all
echo "remove all sshtunnel"

sleep 30
echo $groupName
aws ec2 delete-security-group --group-name $groupName
echo "security group delete"
