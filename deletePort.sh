
manageConfigPath=$(pwd)
source $manageConfigPath/dependencies/manageConfig.sh
source $manageConfigPath/dependencies/config.sh

luftballonHostPort=$1
localHostPort=$2

publicIp=$(extractValueFromTreehousesConfig publicIp)
groupName=$(extractValueFromTreehousesConfig groupName)

# port 2200 is used for monitor
# port 2222 and 22 also must not be deleted, but these port is not explicitly 
# set up in the notDeleteSecurityPort.
# However, the script cannot delete the port 2222 and 22 
# because sshtunnel is set up between the port 2222 and 22.
notDeleteSecurityPort=2200

# port 2222 cannot be deleted means that port 22 also cannot be deleted 
# because the port 22 and 2222 is configured as the default sshtunnel
notDeleteLuftballonHostPort=2222

function deleteUnusedSShtunnel(){
    instanceIp=$1
    luftballonHostPort=$2
    if [ ! $luftballonHostPort -eq $notDeleteLuftballonHostPort ]
    then
        treehouses sshtunnel remove port $luftballonHostPort root@"$instanceIp"
    fi
}


function deletePort(){
    port=$1
    aws ec2 revoke-security-group-ingress \
        --group-name $groupName \
        --protocol tcp \
        --port $port \
		--cidr 0.0.0.0/0
}


function checkPort() {
	result=0
    port=$1
    array=($@)
    for (( i=1; i<${#array[@]}; i++ ));
    do
        if (( ${array[$i]}>0 )) && [ ${array[$i]} -eq $port ]
        then
			result=$(($result+1))
		fi
    done
    return $result
}

function deletePortOnSecurityGroups(){
    targetPort=$1
    portArray=$@
	checkPort $targetPort $sshtunnelArray
	if [ $? -eq 0 ] && [ ! $targetPort -eq $notDeleteSecurityPort ] 
	then              
		echo "port $targetPort is deleted from security group"
		deletePort $targetPort
	fi                 
}

deleteUnusedSShtunnel $publicIp $luftballonHostPort

storeSshtunnelConfiguration
sshtunnelArray=$(getArrayWithoutDuplicate $(extractValueFromTreehousesConfig sshtunnelArray | sed 's/:/,/g' | sed 's/,/ /g') )

deletePortOnSecurityGroups $localHostPort $sshtunnelArray
deletePortOnSecurityGroups $luftballonHostPort $sshtunnelArray

storePortArrayString
