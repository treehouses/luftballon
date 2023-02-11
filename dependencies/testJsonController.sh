source manageConfig.sh
source jsonController.sh

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
    merge=$(merge "$merge" "$backet")
    echo "$merge" 
}

function returnJson(){
    json=$(testAddAttribute)
    echo "$json"
}

function returnString(){
    json=$(testAddAttribute)
    string=$(stringfy "$json")
    echo $string
}

function convertStringToJson(){
    json=$(testAddAttribute)
    string=$(stringfy "$json")
    echo $string | jq .
}

function testWithTreehousesConfig(){
    json=$(testAddAttribute)
    string=$(stringfy "$json")
    treehouses config add ballonconfigs $string
    data=$(extractValueFromTreehousesConfig test)
    echo $data | jq .
}

returnJson
returnString
convertStringToJson
testWithTreehousesConfig
