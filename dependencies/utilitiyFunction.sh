
function filterInstancesByTag {
  local jsonData=$1
  echo $jsonData | jq '[.Reservations[].Instances[] \
                       | select(.Tags[]? | .Key=="Class" and .Value=="treehouses")]'
}

