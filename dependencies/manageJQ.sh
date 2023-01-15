
function addAttribute(){
    input=$1
    name="$2"
    attribute="$3"
    value="$4"
    echo $( echo "$input" \
            | jq --arg name $name \
            --arg attribute $attribute \
            --arg value $value \
            'setpath([$name,$attribute]; $value)' )
}

value=$(addAttribute null luftballon name luftballon )
value=$(addAttribute "$value" luftballon securityGroup luftballon-sg )
echo "$value"