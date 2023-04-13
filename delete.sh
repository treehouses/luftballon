#!/bin/bash

manageConfigPath=$(pwd)
source $manageConfigPath/dependencies/manageConfig.sh
source $manageConfigPath/dependencies/jsonController.sh
source $manageConfigPath/dependencies/storeConfigByJson.sh
source $manageConfigPath/dependencies/config.sh

#BASE=$HOME
BASE=/home/pi

ballonName=$1

if [ -z "$ballonName" ]
then
  echo "Please provide the balloon name"
  exit 1
fi

keyName=$(getValueByAttribute $ballonName key)
instanceId=$(getValueByAttribute $ballonName instanceId)
groupName=$(getValueByAttribute $ballonName groupName)

storePortArrayString $ballonName
updateSshtunnelConfig $ballonName

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
