manageConfigPath=$(pwd)
source $manageConfigPath/dependencies/manageConfig.sh
source $manageConfigPath/dependencies/jsonController.sh
source $manageConfigPath/dependencies/storeConfigByJson.sh
configName=luftballonConfigs

first_instanceName=firstballon
first_keyName=firstballon
first_instanceId=i-0c4c9b1efb2d505e0
first_publicIp=1.1.1.1
first_groupName=firstballon-sg

second_instanceName=secondballon
second_keyName=scondballon
second_instanceId=i-0c4c9b1efb2d505e0
second_publicIp=2.2.2.2
second_groupName=secondballon-sg

third_instanceName=firstballon
third_keyName=firstballon_new
third_instanceId=i-0c4c9b1efb2d505e0
third_publicIp=1.1.1.3
third_groupName=firstballon_new-sg

portArray=2200,1194,22,2222
sshtunnelArray=2222:22

function testAddKeyValue(){
    value=$(init $instanceName)
    value=$(addKeyValue "$value" $instanceName instanceName $instanceName )
    value=$(addKeyValue "$value" $instanceName keyName $keyName )
    value=$(addKeyValue "$value" $instanceName instanceId $instanceId )
    value=$(addKeyValue "$value" $instanceName publicIp $publicIp )
    value=$(addKeyValue "$value" $instanceName groupName $groupName )
}

function ifConfigIsEmptyJustMakeConfigAndStore(){
	instanceName=$1
	keyName=$2
	instanceId=$3
	publicIp=$4
	groupName=$5
	
	storeConfigIntoTreehousesConfigAsStringfiedJson $instanceName $keyName $instanceId $publicIp $groupName
	echo ifConfigIsEmptyJustMakeConfigAndStore
    getConfigAsJson
    #printAllConfig
}

function ifKeyNotExistUpdateMakeNewBucket(){
	instanceName=$1
	keyName=$2
	instanceId=$3
	publicIp=$4
	groupName=$5
	
	storeConfigIntoTreehousesConfigAsStringfiedJson $instanceName $keyName $instanceId $publicIp $groupName
	echo ifKeyNotExistUpdateMakeNewBucket
    getConfigAsJson
    #printAllConfig
}

function ifKeyExistUpdateTheValue(){
	instanceName=$1
	keyName=$2
	instanceId=$3
	publicIp=$4
	groupName=$5
	
	storeConfigIntoTreehousesConfigAsStringfiedJson $instanceName $keyName $instanceId $publicIp $groupName
	echo ifKeyExistUpdateTheValue
    getConfigAsJson
    #printAllConfig
}

#treehouses config delete $configName 
#ifConfigIsEmptyJustMakeConfigAndStore $first_instanceName $first_keyName $first_instanceId $first_publicIp $first_groupName
#ifKeyNotExistUpdateMakeNewBucket $second_instanceName $second_keyName $second_instanceId $second_publicIp $second_groupName
#ifKeyExistUpdateTheValue $third_instanceName $third_keyName $third_instanceId $third_publicIp $third_groupName

#merge=$(merge "$prev" "$value")
#string=$(stringfy "$merge")

#treehouses config add luftballonConfigs $string
#extractValueFromTreehousesConfig 

getValueByAttribute firstballon instanceName
