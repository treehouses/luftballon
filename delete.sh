#!/bin/bash

manageConfigPath=$(pwd)
source $manageConfigPath/dependencies/manageConfig.sh
source $manageConfigPath/dependencies/jsonController.sh

#BASE=$HOME
BASE=/home/pi

configName=luftballonConfigs
ballonName=$1

#groupName=$(extractValueFromTreehousesConfig groupName)
#instanceId=$(extractValueFromTreehousesConfig instanceId)
#keyName=$(extractValueFromTreehousesConfig keyName)

keyName=$(getValueByAttribute $ballonName key)
instanceId=$(getValueByAttribute $ballonName instanceId)
groupName=$(getValueByAttribute $ballonName groupName)

storePortArrayString
storeSshtunnelConfiguration

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
