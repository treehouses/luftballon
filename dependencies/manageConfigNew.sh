
#!/bin/bash


data=$(cat sample.txt)

echo $data | jq '.Reservations[].Instances[].InstanceId' 
echo $data | jq '.Reservations[].Instances[].SecurityGroups[].GroupName' 
echo $data | jq '.Reservations[].Instances[].PublicIpAddress' 
result=$(echo $data | jq '.Reservations[].Instances[].Tags[].Ke')
echo $result
echo $data | jq '.Reservations[].Instances[].Tags[].Value' 

sample=$'instanceName=myballon\nkeyName=myballon\ninstanceId=i-05595f9fe283c9b97\npublicIp=54.164.69.111\ngroupName=myballon-sg\nportArray=2200,1194,22,2222\nsshtunnelArray=2222:22,2222:22'


function extractValueFromTreehousesConfig(){
    keyWord=$1
    echo "$sample" | grep $keyWord | sed "s/${keyWord}=//"
}

function constructKeyValue(){
    keyWord=$1
    echo "\"$keyWord\" :\"$(extractValueFromTreehousesConfig $keyWord)\","
}

function constructJson(){
    keyWordArray=(instanceName keyName instanceId publicIp groupName portArray sshtunnelArray)

    json="{ \"$(extractValueFromTreehousesConfig instanceName)\": {"
    json="${json%,*}"

    for keyWord in "${keyWordArray[@]}"; do
        json+=$(constructKeyValue $keyWord) 
    done
    json=${json%,*}
    json+=' }}'

    echo $json 
}

constructJson  | jq '.'



string=$(cat <<EOF
instanceName=luftballon
keyName=luftballon
instanceId=i-05595f9fe283c9b97
publicIp=54.164.69.111
groupName=myballon-sg
portArray=2200,1194,22,2222
sshtunnelArray=2222:22,2222:22
EOF
)

