source manageConfig.sh
#data=$(extractValueFromTreehousesConfig ballonconfigs)
data=$(extractValueFromTreehousesConfig test)
echo $data
echo "$data"
echo $data | jq .
