function storeConfig(){
	local instanceName=$1
	local keyName=$2
	local instanceId=$3 
	local publicIp=$4
	local groupName=$5 
	
	local value=$(init $instanceName)
	value=$(addKeyValue "$value" $instanceName instanceName $instanceName )
	value=$(addKeyValue "$value" $instanceName key $keyName )
	value=$(addKeyValue "$value" $instanceName instanceId $instanceId )
	value=$(addKeyValue "$value" $instanceName publicIp $publicIp )
	value=$(addKeyValue "$value" $instanceName groupName $groupName )
	local string=$(stringfy "$value")
	treehouses config add $configName $string
}

function makeConfig(){
	local instanceName=$1
	local keyName=$2
	local instanceId=$3 
	local publicIp=$4
	local groupName=$5 
	
	local value=$(init $instanceName)
	value=$(addKeyValue "$value" $instanceName instanceName $instanceName )
	value=$(addKeyValue "$value" $instanceName key $keyName )
	value=$(addKeyValue "$value" $instanceName instanceId $instanceId )
	value=$(addKeyValue "$value" $instanceName publicIp $publicIp )
	value=$(addKeyValue "$value" $instanceName groupName $groupName )
    echo "$value"
}

function replaceValueAndStoreConfig(){
    local value="$1"    
	local instanceName=$2
	local keyName=$3
	local instanceId=$4 
	local publicIp=$5
	local groupName=$6 

	value=$(addKeyValue "$value" $instanceName key $keyName )
	value=$(addKeyValue "$value" $instanceName instanceId $instanceId )
	value=$(addKeyValue "$value" $instanceName publicIp $publicIp )
	value=$(addKeyValue "$value" $instanceName groupName $groupName )
	local string=$(stringfy "$value")
	treehouses config add $configName $string
}

function updateIPAddress(){
	local instanceName=$1
	local publicIp=$2

    local value=$(getConfigAsJson $configName)
	value=$(addKeyValue "$value" $instanceName publicIp $publicIp )
	local string=$(stringfy "$value")
	treehouses config add $configName $string
}

function storeConfigIntoTreehousesConfigAsStringfiedJson(){
	local instanceName=$1
	local keyName=$2
	local instanceId=$3
	local publicIp=$4
	local groupName=$5

	local evaluate
    local allConfig=$(getConfigAsJson $configName)
	if [ -z "$allConfig" ]
	then
		storeConfig $instanceName $keyName $instanceId $publicIp $groupName 
	else
		evaluate=$(isKey "$allConfig" $instanceName)
	fi

    if [ "$evaluate" == true ]
    then
        replaceValueAndStoreConfig "$allConfig" $instanceName $keyName $instanceId $publicIp $groupName
	elif [ "$evaluate" == false ]
    then
        local newConfig=$(makeConfig $instanceName $keyName $instanceId $publicIp $groupName)
        local merge=$(merge "$allConfig" "$newConfig")
        local string=$(stringfy "$merge")
        treehouses config add $configName $string 
    fi
}

function deleteObsoleteKeyValue(){
	local instanceName=$1
	local allConfig=$(getConfigAsJson $configName)
	allConfig=$(deleteKeyValue "$allConfig" $instanceName instanceName)
	allConfig=$(deleteKeyValue "$allConfig" $instanceName key)
	allConfig=$(deleteKeyValue "$allConfig" $instanceName instanceId)
	allConfig=$(deleteKeyValue "$allConfig" $instanceName publicIp)
	allConfig=$(deleteKeyValue "$allConfig" $instanceName groupName)
    local string=$(stringfy "$allConfig")
    treehouses config add $configName $string 
}

