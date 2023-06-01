#!/bin/bash

manageConfigPath=$(pwd)

source $manageConfigPath/dependencies/configFunctions.sh
source $manageConfigPath/dependencies/config.sh
source $manageConfigPath/dependencies/isBalloonNameValid.sh
source $manageConfigPath/dependencies/manageConfig.sh
source $manageConfigPath/dependencies/securitygroupFunction.sh
source $manageConfigPath/dependencies/utilitityFunction.sh
source $manageConfigPath/dependencies/configOperations.sh
source $manageConfigPath/dependencies/getLatestIpAddress.sh
source $manageConfigPath/dependencies/jsonOperations.sh
source $manageConfigPath/dependencies/reverseShell.sh
source $manageConfigPath/dependencies/sshtunnelFunction.sh


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

aws ec2 stop-instances --instance-ids $instanceId
