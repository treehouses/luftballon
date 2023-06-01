
function storePortArrayString(){
	local groupName=$1
	local protocol=$2
	local balloonName=$3

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
	allConfig=$(deleteKeyValue "$allConfig" $balloonName ${protocol}PortArray)

	portArrayString=$(echo "$data" | jq -r --arg index "$index" \
		--arg protocol "$protocol" \
		'.SecurityGroups[$index | tonumber].IpPermissions[] | select(.IpProtocol==$protocol).FromPort' \
		| sed 's/null//g')

    for port in $portArrayString; do
        allConfig=$(addKeyArray "$allConfig" $balloonName ${protocol}PortArray $port )
    done
    local string=$(stringfy "$allConfig")
    treehouses config add $configName $string 
}