
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
    
    isNull=$(jq --arg name $name --arg attribute $attribute 'getpath([$name,$attribute])'  <<< "$input")
    if [ "$isNull" == "null" ] 
    then 
        output=$( echo "$input" \
        | jq --arg name $name \
        --arg attribute $attribute \
        --arg value $value \
        'setpath([$name,$attribute]; [$value])' ) 
    else 
        length=$(jq  --arg name $name --arg attribute $attribute 'getpath([$name,$attribute]) | length'  <<< "$input")
        output=$( echo "$input" \
        | jq --arg name $name \
        --arg attribute $attribute \
        --arg value $value \
        --argjson length $length \
        'setpath([$name,$attribute,$length]; $value)' ) 
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

function testAddAttribute(){
    value=$(init luftballon)
    value=$(addKeyValue "$value" luftballon instanceName luftballon )
    value=$(addKeyValue "$value" luftballon groupName luftballon-sg )
    value=$(addKeyValue "$value" luftballon keyName luftballon )
    value=$(addKeyValue "$value" luftballon publicIp 54.164.69.111 )
    value=$(addKeyValue "$value" luftballon instanceId i-05595f9fe283c9b97 )
    value=$(addKeyArray "$value" luftballon portArray 2200 )
    value=$(addKeyArray "$value" luftballon portArray 2222 )
    value=$(addKeyArray "$value" luftballon sshtunnelArray 2222:22 )
    value=$(addKeyArray "$value" luftballon sshtunnelArray 2233:33 )
    echo "$value"
}

testAddAttribute