manageConfigPath=$(pwd)
source $manageConfigPath/dependencies/manageConfig.sh
source $manageConfigPath/dependencies/jsonController.sh


instanceName=yourballon
keyName=yourballon
instanceId=i-0c4c9b1efb2d505e0
publicIp=23.91.33.15
groupName=yourballon-sg
portArray=2200,1194,22,2222
sshtunnelArray=2222:22
configName=testLuftballonConfigs

function testAddKeyValue(){
    value=$(init $instanceName)
    value=$(addKeyValue "$value" $instanceName instanceName $instanceName )
    value=$(addKeyValue "$value" $instanceName keyName $keyName )
    value=$(addKeyValue "$value" $instanceName instanceId $instanceId )
    value=$(addKeyValue "$value" $instanceName publicIp $publicIp )
    value=$(addKeyValue "$value" $instanceName groupName $groupName )
}

function testGetBucketByBucketKey(){
    prev=$(extractValueFromTreehousesConfig $configName)
    backet=$(getBucketByBucketKey "$prev" $instanceName)
    echo $backet
}

function printAllConfig(){
    allConfig=$(extractValueFromTreehousesConfig $configName)
    echo $allConfig
}


function storeConfig(){
	instanceName=$1
	keyName=$2
	instanceId=$3 
	publicIp=$4
	groupName=$5 
	
	value=$(init $instanceName)
	value=$(addKeyValue "$value" $instanceName instanceName $instanceName )
	value=$(addKeyValue "$value" $instanceName keyName $keyName )
	value=$(addKeyValue "$value" $instanceName instanceId $instanceId )
	value=$(addKeyValue "$value" $instanceName publicIp $publicIp )
	value=$(addKeyValue "$value" $instanceName groupName $groupName )
	string=$(stringfy "$value")
	treehouses config add $configName $string
}

function makeConfig(){
	instanceName=$1
	keyName=$2
	instanceId=$3 
	publicIp=$4
	groupName=$5 
	
	value=$(init $instanceName)
	value=$(addKeyValue "$value" $instanceName instanceName $instanceName )
	value=$(addKeyValue "$value" $instanceName keyName $keyName )
	value=$(addKeyValue "$value" $instanceName instanceId $instanceId )
	value=$(addKeyValue "$value" $instanceName publicIp $publicIp )
	value=$(addKeyValue "$value" $instanceName groupName $groupName )
    echo "$value"
}

function replaceValueAndStoreConfig(){
    value="$1"    
	instanceName=$2
	keyName=$3
	instanceId=$4 
	publicIp=$5
	groupName=$6 

	value=$(addKeyValue "$value" $instanceName keyName $keyName )
	value=$(addKeyValue "$value" $instanceName instanceId $instanceId )
	value=$(addKeyValue "$value" $instanceName publicIp $publicIp )
	value=$(addKeyValue "$value" $instanceName groupName $groupName )
	string=$(stringfy "$value")
	treehouses config add $configName $string
}

function ifKeyExistUpdateTheValue(){
    allConfig=$(extractValueFromTreehousesConfig $configName | jq .)
    evaluate=$(isKey "$allConfig" $instanceName)
    if [ $evaluate == true ]
    then
        #prev=$(extractValueFromTreehousesConfig $configName)
        #backet=$(getBucketByBucketKey "$allConfig" $instanceName)
        replaceValueAndStoreConfig "$allConfig" $instanceName differentKey $instanceId 128.0.0.1 $groupName 
    fi
    printAllConfig
}


function ifKeyNotExistUpdateMakeNewBucket(){
    allConfig=$(extractValueFromTreehousesConfig $configName | jq .)
    evaluate=$(isKey "$allConfig" luftballon)
    if [ $evaluate == false ]
    then
        newConfig=$(makeConfig differentBallon mygroupBallon $instanceId 12.0.0.0 mygroup)
        merge=$(merge "$allConfig" "$newConfig")
        string=$(stringfy "$merge")
        treehouses config add $configName $string
    fi
    printAllConfig
}

treehouses config delete $configName 
storeConfig $instanceName $keyName $instanceId $publicIp $groupName 
printAllConfig
ifKeyNotExistUpdateMakeNewBucket
ifKeyExistUpdateTheValue

#merge=$(merge "$prev" "$value")
#string=$(stringfy "$merge")

#treehouses config add luftballonConfigs $string
#extractValueFromTreehousesConfig luftballonConfigs
