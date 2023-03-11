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

function testAddKeyValue(){
    instanceName=yourballon
    keyName=yourballon
    instanceId=i-0c4c9b1efb2d505e0
    publicIp=23.91.33.15
    groupName=yourballon-sg
    portArray=2200,1194,22,2222
    sshtunnelArray=2222:22

    value=$(init $instanceName)
    value=$(addKeyValue "$value" $instanceName instanceName $instanceName )
    value=$(addKeyValue "$value" $instanceName keyName $keyName )
    value=$(addKeyValue "$value" $instanceName instanceId $instanceId )
    value=$(addKeyValue "$value" $instanceName publicIp $publicIp )
    value=$(addKeyValue "$value" $instanceName groupName $groupName )
}

function testGetBucketByBucketKey(){
    prev=$(extractValueFromTreehousesConfig luftballonConfigs)
    backet=$(getBucketByBucketKey "$prev" ballon)
    echo $backet
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
	treehouses config add testLuftballonConfigs $string
}

storeConfig $instanceName $keyName $instanceId $publicIp $groupName 

#merge=$(merge "$prev" "$value")
#string=$(stringfy "$merge")

#treehouses config add luftballonConfigs $string
#extractValueFromTreehousesConfig luftballonConfigs
