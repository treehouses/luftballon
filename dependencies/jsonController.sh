
function addKeyValue(){
    input="$1"
    name="$2"
    attribute="$3"
    value="$4"

    output=$( echo "$input" \
        | jq --arg name $name \
        --arg attribute $attribute \
        --arg value $value \
        'setpath([$name,$attribute]; $value)' )
    echo "$output"
}

function addKeyArray(){
    input="$1"
    name="$2"
    attribute="$3"
    value="$4"

    isNull=$(jq --arg name $name \
            --arg attribute $attribute \
            'getpath([$name,$attribute])'  \
            <<< "$input")

    if [ "$isNull" == "null" ] 
    then 
        output=$( echo "$input" \
        | jq --arg name $name \
        --arg attribute $attribute \
        --arg value $value \
        'setpath([$name,$attribute]; [$value])' ) 
    else 
        length=$( jq  --arg name $name \
            --arg attribute $attribute \
            'getpath([$name,$attribute]) | length' \
            <<< "$input" )

        output=$( echo "$input" \
        | jq --arg name $name \
        --arg attribute $attribute \
        --arg value $value \
        --argjson length $length \
        'setpath([$name,$attribute,$length]; $value)' ) 
    fi
    echo "$output"
}

function replaceValue(){
    input="$1"
    name="$2"
    attribute="$3"
    value="$4"

    isKeyExist=$( echo "$input" \
        | jq --arg name "$name" \
        --arg attribute "$attribute" \
        'map(has($attribute)) | .[0]' )
    
    if [ "$isKeyExist" == 'true' ] 
    then 
        output=$( echo "$input" \
            | jq --arg name $name \
            --arg attribute $attribute \
            --arg value $value \
            'setpath([$name,$attribute]; $value)' )
    else
        output="$input"
    fi
    echo "$output"
}

function deleteKeyValue(){
    input="$1"
    name="$2"
    attribute="$3"

    isNull=$(jq --arg name $name \
            --arg attribute $attribute \
            'getpath([$name,$attribute])'  \
            <<< "$input"  )

    if [ "$isNull" == "" ] 
    then 
        output="$input"
    else
        output=$( jq --arg name $name \
        --arg attribute $attribute \
        'del(getpath([$name,$attribute]))' <<< "$input"  )
    fi
    echo "$output"
}

function init(){
    name="$1"
    output=$( echo null \
        | jq --arg name $name \
        'setpath([$name]; {})' )
    echo "$output"
}

function merge(){
    first="$1"
    second="$2"
    result=$(echo $first $second | jq -n 'reduce inputs as $i ({}; . + $i)') 
    echo "$result"
}

function getBucketKeys(){
    bucket="$1"
    echo "$bucket" | jq 'keys | .[]'
}

function makeBucket(){
    input="$1"
    name="$2"
    value="$3"

    output=$( jq --arg name "$name" \
        --argjson value "$value" \
        '.[$name] |= $value' <<< "$input" )
    echo "$output"
}

function getBucketByBucketKey(){
    buckets="$1"
    key="$2"
    theBucket=$(echo "$buckets" | jq --arg key $key 'getpath([$key])')
    emptyBucket=$(init "$key")
    theBucketWithKey=$(makeBucket "$emptyBucket" "$key" "$theBucket" )
    echo "$theBucketWithKey"
}

function stringfy(){
    data="$1"
    string=$(echo "$data"  | jq '.|tostring' |tr -d '\' | sed 's/"{/{/' | sed 's/}"/}/' )
    echo $string
}

function isKey(){
    input="$1"
    target="$2"
    keys=$(echo "$input" | jq 'keys' )
    output=$(jq --arg target "$target" 'any(.==$target)' <<< $keys)
    echo "$output"
}

function getConfigAsJson(){
    allConfig=$(extractValueFromTreehousesConfig $configName | jq .)
	echo "$allConfig"
}

function printAllConfig(){
	configName=$1
    allConfig=$(extractValueFromTreehousesConfig $configName)
    echo $allConfig
}

function getValueByAttribute(){
	instanceName=$1
	attribute=$2
    backet=$(getBucketByBucketKey "$getConfigAsJson" $instanceName)
    keyName=$(echo "$backet" | jq -r --arg instanceName "$instanceName" --arg keyName "$attribute" '.[$instanceName][$attribute]')
    echo "$keyName"
}