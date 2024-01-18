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

source $manageConfigPath/init.sh
source $manageConfigPath/delete.sh
source $manageConfigPath/callStoreConfigIntoTreehousesConfigAsStringfiedJson

