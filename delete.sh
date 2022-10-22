#!/bin/bash

manageConfigPath=$(pwd)
source $manageConfigPath/dependencies/manageConfig.sh

#BASE=$HOME
BASE=/home/pi


groupName=$(extractValueFromTreehousesConfig groupName)
instanceId=$(extractValueFromTreehousesConfig instanceId)
keyName=$(extractValueFromTreehousesConfig keyName)

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
