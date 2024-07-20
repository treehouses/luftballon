
# Filters instances from JSON data based on the tag "Class" with a value of "treehouses".
# Expects JSON data in the format returned by the AWS CLI command 'describe-instances'.
# Uses 'jq' to parse and filter the data.
# Returns instances with the specified tag as a filtered JSON array.
# Example usage: filterInstancesByTag "$(aws ec2 describe-instances)"
function filterInstancesByTag {
  local jsonData="$1"
  echo "$jsonData" | jq '[.Reservations[].Instances[] | select(.Tags[]? | .Key=="Class" and .Value=="treehouses")]'
}

function waitForOutput(){
    local cmd=$1
    local result=$(eval $cmd)
    while [ -z "$result" ] || [ "$result" == "null" ]
    do
        sleep 5
        result=$(eval $cmd)
    done
    echo $result
}

setBalloonName() {
    if [ -z "$1" ]; then
        echo "luftballon"
    else
        echo "$1"
    fi
}

function makePortArray {
    local portString="$1"
    local -a portArray

    IFS=',' read -ra pairs <<< "$portString"

    for pair in "${pairs[@]}"; do
        IFS=':' read -ra ports <<< "$pair"
        for port in "${ports[@]}"; do
            portArray+=("$port")
        done
    done

    echo "${portArray[@]}"
}

function getState(){
    local instanceId=$1
    local state=$(aws ec2 describe-instances --instance-ids $instanceId | jq '.Reservations[].Instances[].State.Name')
    echo $state
}