
function getSshtunnelMonitorConfiguration(){
    [ -f /etc/tunnel ] && cat /etc/tunnel | grep /usr/bin/autossh | grep -oE "\-M [0-9]{1,4}" |  grep -oE "[0-9]{1,4}"
}

function storeSshtunnelMonitorConfiguration(){
    monitor=$(getSshtunnelMonitorConfiguration)
    treehouses config add sshtunnelMonitor $monitor
}

function findAllPortMap(){
    grep -oE "[0-9]{2,4}:[0-9]{2,4}"
}


function extractValueFromTreehousesConfig(){
    keyWord=$1
    treehouses config | grep $keyWord= | sed "s/${keyWord}=//"
}

function getSshtunnelConfiguration(){
    [ -f /etc/tunnel ] && cat /etc/tunnel | grep -oE "[0-9]{2,4}:127.0.1.1:[0-9]{2,4}" | sed s/:127.0.1.1:/:/ 
}

function storeSshtunnelConfiguration(){
    array=$(getSshtunnelConfiguration | sed 's/\n//g'| sed 's/ /,/g' )
    sshtunnelArray=$(echo $array | sed 's/ /,/g' )
    echo $sshtunnelArray
    treehouses config add sshtunnelArray $sshtunnelArray
}


function getLuftballSshtunnelArray(){
    luftballonArray=$(extractValueFromTreehousesConfig sshtunnelArray | sed 's/,/ /g')
    echo $luftballonArray
}


function getServerPortArray(){
    serverArray=$(treehouses config | grep sshtunnelArray | grep -oE ":[0-9]{2,4}" | sed 's/://g')
    echo $serverArray
}



function getPortArrayString(){
    array=$(extractValueFromTreehousesConfig portArray | sed s/,/" "/g  )
    echo $array
}

function findfuncName(){
    keyword=$1
    query=$2
    echo $keyword
    funcNameArray=($(cat manageConfig.sh | grep $keyword | sed "s/$keyword //g" | sed "s/(){//g"))
    for funcName in ${funcNameArray[@]}
    do
        cat $query | grep ${funcName}
    done
}


function storePortArrayString(){
    local data=$(aws ec2 describe-security-groups)
    local len=$(echo $data | jq ". | length")
    local groupName=$(extractValueFromTreehousesConfig groupName)
    
    local index=
    for i in $(seq 0 $len) 
    do 
        if [ $groupName = $(echo $data | jq ".SecurityGroups[$i].GroupName" | sed 's/"//g') ]
        then
            index=$i
        fi
    done

    local portArrayString=$(echo $data | jq ".SecurityGroups[$index].IpPermissions[].FromPort" | sed 's/null//g')
    portArrayString=$(echo $portArrayString | sed 's/ /,/g')
    echo $portArrayString
    treehouses config add portArray $portArrayString
}


function removeArrayDuplicates() {
    declare -A tmp_array
    for i in "$@"; do
        [[ $i ]] && IFS=" " tmp_array["${i:- }"]=1
    done
    printf '%s\n' "${!tmp_array[@]}"
}


function getArrayWithoutDuplicate(){
    duplicateArray=($@)
    echo $(removeArrayDuplicates "${duplicateArray[@]}")
}


    #keyword=$1
    #query=$2
    #findfuncName $keyword $query

