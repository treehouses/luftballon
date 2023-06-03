function getConfigAsJson(){
    local allConfig=$(getTreehousesConfigValue $configName | jq .)
    echo "$allConfig"
}

function printAllConfig(){
    local allConfig=$(getTreehousesConfigValue $configName)
    echo $allConfig
}

function getValueByAttribute(){
    local instanceName=$1
    local attribute=$2
    local backet=$(getBucketByBucketKey "$(getConfigAsJson)" $instanceName)
    local keyName=$(echo "$backet" | \
              jq -r --arg instanceName "$instanceName" \
                    --arg attribute "$attribute" \
                    '.[$instanceName][$attribute]')
    echo "$keyName"
}

function getArrayValueAsStringByKey(){
    local instanceName=$1
    local attribute=$2
    local backet=$(getBucketByBucketKey "$(getConfigAsJson)" $instanceName)
    local keyName=$(echo "$backet" | \
              jq -r --arg instanceName "$instanceName" \
                    --arg attribute "$attribute" \
                    '.[$instanceName][$attribute] | join(" ")')
    echo "$keyName"
}
