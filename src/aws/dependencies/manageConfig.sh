
function getTreehousesConfigValue(){
    keyWord=$1
    echo "keyord: $keyWord"
    echo "keyord: $keyWord"
    echo "keyord: $keyWord"
    echo "keyord: $keyWord"
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

