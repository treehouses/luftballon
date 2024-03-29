#!/bin/bash

manageConfigPath=$(pwd)
source $manageConfigPath/dependencies/config.sh
source $manageConfigPath/dependencies/utilitiyFunction.sh
source $manageConfigPath/dependencies/isBalloonNameValid.sh
source $manageConfigPath/dependencies/jsonOperations.sh
source $manageConfigPath/dependencies/configOperations.sh
source $manageConfigPath/dependencies/configFunctions.sh
source $manageConfigPath/dependencies/getLatestIpAddress.sh
source $manageConfigPath/dependencies/securitygroupFunction.sh
source $manageConfigPath/dependencies/manageConfig.sh
source $manageConfigPath/dependencies/sshtunnelFunction.sh
source $manageConfigPath/dependencies/reverseShell.sh



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

keyName=$(getValueByAttribute $balloonName key)
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
while true; do
  output=$(aws ec2 delete-security-group --group-name "$groupName" 2>&1)
  if [[ $? -eq 0 ]]; then
    echo "Security group '$groupName' successfully deleted."
    break
  elif [[ $output == *"DependencyViolation"* ]]; then
    echo "Dependency violation. Retrying in 5 seconds..."
    sleep 10
  else
    echo "An error occurred: $output"
    break
  fi
done

deleteObsoleteKeyValue $balloonName
