

# This file is for the test
sample=$(cat <<EOF
instanceName=luftballon
keyName=luftballon
instanceId=i-05595f9fe283c9b97
publicIp=54.164.69.111
groupName=myballon-sg
portArray=2200,1194,22,2222
sshtunnelArray=2222:22,2222:22
EOF
)


function extractValueFromTreehousesConfig(){
    keyWord=$1
    #treehouses config | grep $keyWord | sed "s/${keyWord}=//"
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

constructJson
