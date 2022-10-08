
#!/bin/bash

manageConfigPath=$(pwd)
source $manageConfigPath/dependencies/manage-config.sh


#function getArrayWithoutDuplicate(){
#    duplicateArray=($(extractValueFromTreehousesConfig sshtunnelArray | sed 's/:/,/g' | sed 's/,/ /g'))
#    echo $(remove_array_duplicates "${duplicateArray[@]}")
#}

arr=$(getArrayWithoutDuplicate $(extractValueFromTreehousesConfig sshtunnelArray | sed 's/:/,/g' | sed 's/,/ /g' ) )

function checkPort() {
	result=0
    port=$1
    array=($@)
    for (( i=1; i<${#array[@]}; i++ ));
    do
        if (( ${array[$i]}>0 )) && [ ${array[$i]} -eq $port ]   # Check if a equals b
        then
			result=$(($result+1))
		fi
    done
    return $result
}

checkPort 80 $arr
echo $?

checkPort 1234 $arr
echo $?
