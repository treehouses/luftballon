
function addAttribute(){
    input="$1"
    name="$2"
    attribute="$3"
    value="$4"
    isArray="$5"

    if [[ $isArray == 0 ]] 
    then
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
    else
        output=$( echo "$input" \
            | jq --arg name $name \
            --arg attribute $attribute \
            --arg value $value \
            'setpath([$name,$attribute]; $value)' )
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
    value=$(addAttribute "$value" luftballon instanceName luftballon )
    value=$(addAttribute "$value" luftballon groupName luftballon-sg )
    value=$(addAttribute "$value" luftballon keyName luftballon )
    value=$(addAttribute "$value" luftballon publicIp 54.164.69.111 )
    value=$(addAttribute "$value" luftballon instanceId i-05595f9fe283c9b97 )
    value=$(addAttribute "$value" luftballon portArray 2200 0 )
    value=$(addAttribute "$value" luftballon portArray 2222 0 )
    value=$(addAttribute "$value" luftballon sshtunnelArray 2222:22 0 )
    value=$(addAttribute "$value" luftballon sshtunnelArray 2233:33 0 )
    echo "$value"
}

testAddAttribute