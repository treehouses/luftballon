manageConfigPath=$(pwd)
source $manageConfigPath/dependencies/manageConfig.sh
source $manageConfigPath/dependencies/jsonController.sh

value=$(getArrayValueAsStringByKey luftballon portArray)
echo "$value"

#storePortArrayString
