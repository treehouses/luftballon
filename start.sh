#!/bin/bash

manageConfigPath=$(pwd)
source $manageConfigPath/dependencies/manageConfig.sh
source $manageConfigPath/dependencies/jsonController.sh
source $manageConfigPath/dependencies/storeConfigByJson.sh
source $manageConfigPath/dependencies/config.sh
source $manageConfigPath/dependencies/isBalloonNameValid.sh

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

aws ec2 start-instances --instance-ids $instanceId
