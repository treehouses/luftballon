
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

function testAddAttribute(){
    value=$(init luftballon)
    value=$(addKeyValue "$value" luftballon instanceName luftballon )
    value=$(addKeyValue "$value" luftballon groupName luftballon-sg )
    value=$(addKeyValue "$value" luftballon keyName luftballon )
    value=$(addKeyValue "$value" luftballon publicIp 54.164.69.111 )
    value=$(addKeyValue "$value" luftballon instanceId i-05595f9fe283c9b97 )
    value=$(addKeyArray "$value" luftballon portArray 2200 )
    value=$(addKeyArray "$value" luftballon portArray 2222 )
    value=$(addKeyArray "$value" luftballon udpPortArray 8800 )
    value=$(addKeyArray "$value" luftballon sshtunnelArray 2222:22 )
    value=$(addKeyArray "$value" luftballon sshtunnelArray 2233:33 )
    value=$(addKeyValue "$value" luftballon instanceId i-05595f9fe283c9b97 )

    value1=$(init myballon)
    value1=$(addKeyValue "$value1" myballon instanceName luftballon )
    value1=$(addKeyValue "$value1" myballon groupName luftballon-sg )
    value1=$(addKeyValue "$value1" myballon keyName luftballon )
    value1=$(addKeyValue "$value1" myballon publicIp 54.164.69.111 )
    value1=$(addKeyValue "$value1" myballon instanceId i-05595f9fe283c9b97 )
    value1=$(addKeyArray "$value1" myballon portArray 2200 )
    value1=$(addKeyArray "$value1" myballon portArray 2222 )
    value1=$(addKeyArray "$value1" myballon udpPortArray 8800 )
    value1=$(addKeyArray "$value1" myballon sshtunnelArray 2222:22 )
    value1=$(addKeyArray "$value1" myballon sshtunnelArray 2233:33 )
    value1=$(addKeyValue "$value1" myballon instanceId i-05595f9fe283c9b97 )
    
    merge=$(merge "$value" "$value1")
    
    value2=$(init yourballon)
    value2=$(addKeyValue "$value2" yourballon instanceName luftballon )
    value2=$(addKeyValue "$value2" yourballon groupName luftballon-sg )
    value2=$(addKeyValue "$value2" yourballon keyName luftballon )
    value2=$(addKeyValue "$value2" yourballon publicIp 54.164.69.111 )
    value2=$(addKeyValue "$value2" yourballon instanceId i-05595f9fe283c9b97 )
    value2=$(addKeyArray "$value2" yourballon portArray 2200 )
    value2=$(addKeyArray "$value2" yourballon portArray 2222 )
    value2=$(addKeyArray "$value2" yourballon udpPortArray 8800 )
    value2=$(addKeyArray "$value2" yourballon sshtunnelArray 2222:22 )
    value2=$(addKeyArray "$value2" yourballon sshtunnelArray 2233:33 )
    value2=$(addKeyValue "$value2" yourballon instanceId i-05595f9fe283c9b97 )

    merge=$(merge "$merge" "$value2")

    backet=$(getBucketByBucketKey "$merge" yourballon)
    echo "$backet"
    merge=$(merge "$merge" "$backet")
    echo "$merge"
}
testAddAttribute | jq -R .

#data=$(testAddAttribute | jq -R . | tr -d ' ' | tr -d '\r' |  tr -d '"\n"' | tr -d '\'  )
data=$(testAddAttribute | jq -R . | tr -d ' ' | tr -d '"\n"'  )
echo $data
treehouses config add ballonconfigs $data
