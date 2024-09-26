# Filters instances from JSON data based on the tag "Class" with a value of "treehouses".
# Expects JSON data in the format returned by the AWS CLI command 'describe-instances'.
# Uses 'jq' to parse and filter the data.
# Returns instances with the specified tag as a filtered JSON array.
# Example usage: filterInstancesByTag "$(aws ec2 describe-instances)"
function filterInstancesByTag {
  local jsonData="$1"
  echo "$jsonData" | jq '[.Reservations[].Instances[] | select(.Tags[]? | .Key=="Class" and .Value=="treehouses")]'
}

function waitForOutput() {
  local cmd=$1
  local result=$(eval $cmd)
  while [ -z "$result" ] || [ "$result" == "null" ]; do
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

  IFS=',' read -ra pairs <<<"$portString"

  for pair in "${pairs[@]}"; do
    IFS=':' read -ra ports <<<"$pair"
    for port in "${ports[@]}"; do
      portArray+=("$port")
    done
  done

  echo "${portArray[@]}"
}

function getState() {
  local instanceId=$1
  local state=$(aws ec2 describe-instances --instance-ids $instanceId | jq '.Reservations[].Instances[].State.Name')
  echo $state
}

# Function: waitForConditionalOutput
# Description: Waits for a command to produce a specific result based on the specified mode.
# Parameters:
#   $1 - The command to execute
#   $2 - The target value to compare against
#   $3 - The mode of operation: 'match' or 'different'
#        'match': Waits for the result to match the target value
#        'different': Waits for the result to be different from the target value
# Returns:
#   0 - If the desired condition is met within the max attempts
#   1 - If the desired condition is not met within the max attempts

function waitForConditionalOutput() {
  local cmd=$1
  local targetValue=$2
  local mode=$3
  local maxAttempts=3
  local attempt=0

  # Validate mode
  if [[ "$mode" != "match" && "$mode" != "different" ]]; then
    echo "Error: Invalid mode. Use 'match' or 'different'."
    return 1
  fi

  while [ $attempt -lt $maxAttempts ]; do
    local result=$(eval $cmd)
    if [ "$mode" == "match" ]; then
      # Wait for the result to match the target value
      if [ "$result" == "$targetValue" ]; then
        echo $result
        return 0
      fi
    elif [ "$mode" == "different" ]; then
      # Wait for the result to be different from the target value
      if [ "$result" != "$targetValue" ]; then
        echo $result
        return 0
      fi
    fi
    attempt=$((attempt + 1))
    sleep 10
  done

  echo "Error: Failed to meet the condition after $maxAttempts attempts."
  return 1
}
