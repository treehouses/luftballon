source manageConfig.sh
data=$(extractValueFromTreehousesConfig ballonconfigs)
echo $data
echo "$data"
echo $data | jq .
