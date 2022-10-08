

function getIpAddresses(){
    described=$@
    echo $described | jq ".Reservations[].Instances[].PublicIpAddress" | sed 's/"//g'
}

function getInstanceIds(){
    described=$@
    echo $described | jq ".Reservations[].Instances[].InstanceId" | sed 's/"//g'
}



function getLatestIpAddress(){
    described=$(aws ec2 describe-instances)
    targetInstanceId=$1
    instanceIdsArray=($(getInstanceIds $described | sed 's/\n//g'| sed 's/ /,/g' ))
    ipAddressesArray=($(getIpAddresses $described | sed 's/\n//g'| sed 's/ /,/g' ))

    targetIndex=


    for index in ${!instanceIdsArray[@]};
    do
        if [ ${instanceIdsArray[$index]} = $targetInstanceId ] 
        then 
            targetIndex=$index
        fi
    done

    echo ${ipAddressesArray[$targetIndex]}

}
