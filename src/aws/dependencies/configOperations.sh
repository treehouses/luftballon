function getConfigAsJson(){
    if [ -z "$configName" ]; then
        echo "configName is not set"
        return 1
    fi
    echo "configName: $configName"
    local allConfig=$(getTreehousesConfigValue $configName)
    if ! echo "$allConfig" | jq . > /dev/null 2>&1; then
        echo "getTreehousesConfigValue did not return valid JSON"
        return 1
    fi
    echo "$allConfig"
}

function printAllConfig(){
    local allConfig=$(getTreehousesConfigValue $configName)
    echo $allConfig
}

function getValueByAttribute(){
    local instanceName=$1
    local attribute=$2
    echo "instanceName: $instanceName"
    echo "instanceName: $instanceName"
    echo "attribute: $attribute"
    local backet=$(getBucketByBucketKey "$(getConfigAsJson)" $instanceName)
    echo "backet: $backet"
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
