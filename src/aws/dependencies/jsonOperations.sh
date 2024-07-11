function addKeyValue(){
    local input="$1"
    local name="$2"
    local attribute="$3"
    local value="$4"

    local output=$( echo "$input" \
        | jq --arg name $name \
        --arg attribute $attribute \
        --arg value $value \
        'setpath([$name,$attribute]; $value)' )
    echo "$output"
}

function addKeyArray(){
    local input="$1"
    local name="$2"
    local attribute="$3"
    local value="$4"

    local isNull=$(jq --arg name $name \
            --arg attribute $attribute \
            'getpath([$name,$attribute])'  \
            <<< "$input")

    if [ "$isNull" == "null" ] 
    then 
        local output=$( echo "$input" \
        | jq --arg name $name \
        --arg attribute $attribute \
        --arg value $value \
        'setpath([$name,$attribute]; [$value])' ) 
    else 
        local length=$( jq  --arg name $name \
            --arg attribute $attribute \
            'getpath([$name,$attribute]) | length' \
            <<< "$input" )

        local output=$( echo "$input" \
        | jq --arg name $name \
        --arg attribute $attribute \
        --arg value $value \
        --argjson length $length \
        'setpath([$name,$attribute,$length]; $value)' ) 
    fi
    echo "$output"
}

function replaceValue(){
    local input="$1"
    local name="$2"
    local attribute="$3"
    local value="$4"

    local isKeyExist=$( echo "$input" \
        | jq --arg name "$name" \
        --arg attribute "$attribute" \
        'map(has($attribute)) | .[0]' )
    
    if [ "$isKeyExist" == 'true' ] 
    then 
        local output=$( echo "$input" \
            | jq --arg name $name \
            --arg attribute $attribute \
            --arg value $value \
            'setpath([$name,$attribute]; $value)' )
    else
        local output="$input"
    fi
    echo "$output"
}

function deleteKeyValue(){
    local input="$1"
    local name="$2"
    local attribute="$3"

    local isNull=$(jq --arg name $name \
            --arg attribute $attribute \
            'getpath([$name,$attribute])'  \
            <<< "$input"  )

    if [ "$isNull" == "" ] 
    then 
        local output="$input"
    else
        local output=$( jq --arg name $name \
        --arg attribute $attribute \
        'del(.[$name][$attribute])' <<< "$input"  )
    fi
    echo "$output"
}

function initJqObject(){
    local name="$1"
    local output=$( echo null \
        | jq --arg name $name \
        'setpath([$name]; {})' )
    echo "$output"
}

function merge(){
    local first="$1"
    local second="$2"
    local result=$(echo $first $second | jq -n 'reduce inputs as $i ({}; . + $i)') 
    echo "$result"
}

function stringfy(){
    local data="$1"
    local string=$(echo "$data"  | jq '.|tostring' |tr -d '\' 2>/dev/null | sed 's/"{/{/' | sed 's/}"/}/') 
    echo $string
}

function isKey(){
    local input="$1"
    local target="$2"
    local keys=$(echo "$input" | jq 'keys' )
    local output=$(jq --arg target "$target" 'any(.==$target)' <<< $keys)
    echo "$output"
}

function getBucketKeys(){
    local bucket="$1"
    echo "$bucket" | jq 'keys | .[]'
}

function makeBucket(){
    local input="$1"
    local name="$2"
    local value="$3"

    local output=$( jq --arg name "$name" \
        --argjson value "$value" \
        '.[$name] |= $value' <<< "$input" )
    echo "$output"
}

function getBucketByBucketKey(){
    local buckets="$1"
    local key="$2"
    local theBucket=$(echo "$buckets" | jq --arg key $key 'getpath([$key])')
    local emptyBucket=$(initJqObject "$key")
    local theBucketWithKey=$(makeBucket "$emptyBucket" "$key" "$theBucket" )
    echo "$theBucketWithKey"
}
