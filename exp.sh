#!/bin/bash
manageConfigPath=$(pwd)
source $manageConfigPath/dependencies/config.sh
source $manageConfigPath/dependencies/manageConfig.sh
source $manageConfigPath/dependencies/reverseShell.sh
source $manageConfigPath/dependencies/getLatestIpAddress.sh
source $manageConfigPath/dependencies/jsonController.sh
source $manageConfigPath/dependencies/storeConfigByJson.sh

balloonName=luftballons

portConfigArray=
publickey=`treehouses sshtunnel key name | cut -d ' ' -f 5`.pub

keyname=
groupName=luftballons-sg
instanceName=luftballon
checkSSH=~/.ssh/$publickey


portConfigArray=$(getArrayValueAsStringByKey $instanceName tcpPortArray)
udpPortConfigArray=$(getArrayValueAsStringByKey $instanceName udpPortArray)

echo $portConfigArray
echo $udpPortConfigArray


if [ -z "$portConfigArray" ]
then
    echo $portConfigArray
fi

if [ -z "$udpPortConfigArray" ]
then
    echo $udpPortConfigArray
fi
