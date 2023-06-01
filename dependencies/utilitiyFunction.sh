
# Filters instances from JSON data based on the tag "Class" with a value of "treehouses".
# Expects JSON data in the format returned by the AWS CLI command 'describe-instances'.
# Uses 'jq' to parse and filter the data.
# Returns instances with the specified tag as a filtered JSON array.
# Example usage: filterInstancesByTag "$(aws ec2 describe-instances)"
function filterInstancesByTag {
  local jsonData=$1
  echo $jsonData | jq '[.Reservations[].Instances[] \
                       | select(.Tags[]? | .Key=="Class" and .Value=="treehouses")]'
}

