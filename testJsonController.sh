manageConfigPath=$(pwd)
source $manageConfigPath/dependencies/manageConfig.sh
source $manageConfigPath/dependencies/jsonController.sh
source $manageConfigPath/dependencies/storeConfigByJson.sh


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

function printAllConfig(){
    allConfig=$(extractValueFromTreehousesConfig $configName)
    echo $allConfig
}

function ifConfigIsEmptyJustMakeConfigAndStore(){
    allConfig=$(getConfigAsJson $configName)
	echo "$allConfig"
}


function ifKeyExistUpdateTheValue(){
    allConfig=$(getConfigAsJson $configName)
    evaluate=$(isKey "$allConfig" $instanceName)
    if [ $evaluate == true ]
    then
        replaceValueAndStoreConfig "$allConfig" $instanceName differentKey $instanceId 128.0.0.1 $groupName 
    fi
    printAllConfig
}


function ifKeyNotExistUpdateMakeNewBucket(){
    allConfig=$(getConfigAsJson $configName)
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
ifConfigIsEmptyJustMakeConfigAndStore
#storeConfig $instanceName $keyName $instanceId $publicIp $groupName 
printAllConfig
ifKeyNotExistUpdateMakeNewBucket
ifKeyExistUpdateTheValue

#merge=$(merge "$prev" "$value")
#string=$(stringfy "$merge")

#treehouses config add luftballonConfigs $string
#extractValueFromTreehousesConfig luftballonConfigs
