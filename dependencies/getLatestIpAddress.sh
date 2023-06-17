
function getIpAddresses(){
    local described=$@
    echo $described | jq ".[].PublicIpAddress" | sed 's/"//g'
}

function getInstanceIds(){
    local described=$@
    echo $described | jq ".[].InstanceId" | sed 's/"//g'
}

function getLatestIpAddress(){
    local described=$(filterInstancesByTag "$(aws ec2 describe-instances)")
    local targetInstanceId=$1
    local instanceIdsArray=($(getInstanceIds "$described" | sed 's/\n//g'| sed 's/ /,/g' ))
    local ipAddressesArray=($(getIpAddresses "$described" | sed 's/\n//g'| sed 's/ /,/g' ))

    local targetIndex=

    for index in ${!instanceIdsArray[@]};
    do
        if [ ${instanceIdsArray[$index]} = $targetInstanceId ] 
        then 
            targetIndex=$index
        fi
    done

    echo ${ipAddressesArray[$targetIndex]}
}
