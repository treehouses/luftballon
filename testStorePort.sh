configName=luftballonConfigs
manageConfigPath=$(pwd)
source $manageConfigPath/dependencies/manageConfig.sh
source $manageConfigPath/dependencies/jsonController.sh

value=$(getArrayAsStringByAttribute luftballon portArray)
echo "$value"

#storePortArrayString
