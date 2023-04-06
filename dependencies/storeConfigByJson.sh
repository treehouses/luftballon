
configName=luftballonConfigs

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

function storePortArrayString(){
	local groupName=$1

    local data=$(aws ec2 describe-security-groups)
    local len=$(echo $data | jq ". | length")
    
    local index=
    for i in $(seq 0 $len) 
    do 
        if [ $groupName = $(echo $data | jq ".SecurityGroups[$i].GroupName" | sed 's/"//g') ]
        then
            index=$i
        fi
    done

    local allConfig=$(getConfigAsJson $configName)

    local portArrayString=$(echo $data | jq ".SecurityGroups[$index].IpPermissions[].FromPort" | sed 's/null//g')
    for port in $portArrayString; do
        allConfig=$(addKeyArray "$allConfig" luftballon portArray $port )
    done
    local string=$(stringfy "$allConfig")
    treehouses config add $configName $string 
}

function updateSshtunnelConfig() {
	local instanceName=$1
	local allConfig=$(getConfigAsJson $configName)

	local tunnelConfigArray=$(getSshtunnelConfiguration)

	for tunnelConfig in $tunnelConfigArray; do
		allConfig=$(addKeyArray "$allConfig" $instanceName sshtunnelArray "$tunnelConfig")
	done

    local string=$(stringfy "$allConfig")
    treehouses config add $configName $string 
}

