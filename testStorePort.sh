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

    portArrayString=$(echo $data | jq ".SecurityGroups[$index].IpPermissions[].FromPort" | sed 's/null//g')
    portArrayString=$(echo $portArrayString | sed 's/ /,/g')
    echo $portArrayString
    treehouses config add portArray $portArrayString
}

storePortArrayString