#!/bin/bash
source $manageConfigPath/src/aws/dependencies/config.sh
source $manageConfigPath/src/aws/dependencies/utilitiyFunction.sh
source $manageConfigPath/src/aws/dependencies/isBalloonNameValid.sh
source $manageConfigPath/src/aws/dependencies/jsonOperations.sh
source $manageConfigPath/src/aws/dependencies/configOperations.sh
source $manageConfigPath/src/aws/dependencies/configFunctions.sh
source $manageConfigPath/src/aws/dependencies/getLatestIpAddress.sh
source $manageConfigPath/src/aws/dependencies/securitygroupFunction.sh
source $manageConfigPath/src/aws/dependencies/manageConfig.sh
source $manageConfigPath/src/aws/dependencies/sshtunnelFunction.sh
source $manageConfigPath/src/aws/dependencies/reverseShell.sh
source $manageConfigPath/src/aws/dependencies/updateOrAppend.sh

source $manageConfigPath/src/aws/init.sh
source $manageConfigPath/src/aws/delete.sh
source $manageConfigPath/src/aws/stop.sh
source $manageConfigPath/src/aws/restart.sh
source $manageConfigPath/src/aws/installAwsCli.sh
source $manageConfigPath/src/aws/driver.sh

