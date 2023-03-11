

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