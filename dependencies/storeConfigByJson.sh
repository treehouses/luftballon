
configName=luftballonConfigs

function storeConfig(){
	instanceName=$1
	keyName=$2
	instanceId=$3 
	publicIp=$4
	groupName=$5 
	
	value=$(init $instanceName)
	value=$(addKeyValue "$value" $instanceName instanceName $instanceName )
	value=$(addKeyValue "$value" $instanceName key $keyName )
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
	value=$(addKeyValue "$value" $instanceName key $keyName )
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

	value=$(addKeyValue "$value" $instanceName key $keyName )
	value=$(addKeyValue "$value" $instanceName instanceId $instanceId )
	value=$(addKeyValue "$value" $instanceName publicIp $publicIp )
	value=$(addKeyValue "$value" $instanceName groupName $groupName )
	string=$(stringfy "$value")
	treehouses config add $configName $string
}

function storeConfigIntoTreehousesConfigAsStringfiedJson(){
	instanceName=$1
	keyName=$2
	instanceId=$3
	publicIp=$4
	groupName=$5

	local evaluate
    allConfig=$(getConfigAsJson $configName)
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
        newConfig=$(makeConfig $instanceName $keyName $instanceId $publicIp $groupName)
        merge=$(merge "$allConfig" "$newConfig")
        string=$(stringfy "$merge")
        treehouses config add $configName $string 
    fi
}

function storePortArrayString(){
    data=$(aws ec2 describe-security-groups)
    len=$(echo $data | jq ". | length")
    groupName=$(extractValueFromTreehousesConfig groupName)
    
    index=
    for i in $(seq 0 $len) 
    do 
        if [ $groupName = $(echo $data | jq ".SecurityGroups[$i].GroupName" | sed 's/"//g') ]
        then
            index=$i
        fi
    done

    allConfig=$(getConfigAsJson $configName)

    portArrayString=$(echo $data | jq ".SecurityGroups[$index].IpPermissions[].FromPort" | sed 's/null//g')
    for port in $portArrayString; do
        allConfig=$(addKeyArray "$allConfig" luftballon portArray $port )
    done
    string=$(stringfy "$allConfig")
    treehouses config add $configName $string 
}

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