configName=luftballonConfigs
manageConfigPath=$(pwd)
source $manageConfigPath/dependencies/manageConfig.sh
source $manageConfigPath/dependencies/jsonController.sh
#source $manageConfigPath/dependencies/storeConfigByJson.sh

function updateSshtunnelConfig() {
	instanceName=$1
	attribute=$2
	allConfig=$(getConfigAsJson $configName)

	tunnelConfigArray=$(getSshtunnelConfiguration)

	for tunnelConfig in $tunnelConfigArray; do
		allConfig=$(addKeyArray "$allConfig" $instanceName $attribute "$tunnelConfig")
	done

    string=$(stringfy "$allConfig")
    treehouses config add $configName $string 
}

updateSshtunnelConfig luftbollon  sshtunnelArray
