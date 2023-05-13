
manageConfigPath=$(pwd)
source $manageConfigPath/dependencies/manageConfig.sh
source $manageConfigPath/dependencies/jsonController.sh
source $manageConfigPath/dependencies/storeConfigByJson.sh
source $manageConfigPath/dependencies/config.sh
balloonName=luftballons


#storePortArrayString $balloonName tcp
#storePortArrayString $balloonName udp

deleteObsoleteKeyValue $balloonName