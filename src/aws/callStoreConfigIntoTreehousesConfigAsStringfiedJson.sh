
source configFunctions.sh

function callStoreConfigIntoTreehousesConfigAsStringfiedJson() {
    local instanceName="testBallon"
    local keyName="key-testBallon"
    local instanceId="i-0abcd1234efgh5678"  # replace with your actual AWS instance ID
    local publicIp="192.1.2.1"  # replace with your actual public IPv4 address
    local groupName="testBallon"

    storeConfigIntoTreehousesConfigAsStringfiedJson $instanceName $keyName $instanceId $publicIp $groupName
}