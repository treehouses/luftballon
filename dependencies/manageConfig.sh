
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


function getBalloonNameAsArray(){
    local array
    array=$(aws ec2 describe-instances | jq -r '.Reservations[].Instances[].Tags[] | select(.Key=="Name").Value')
    echo $array
}


    #keyword=$1
    #query=$2
    #findfuncName $keyword $query

