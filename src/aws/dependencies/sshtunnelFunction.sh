
function updateSshtunnelConfig() {
	local instanceName=$1
	local allConfig=$(getConfigAsJson $configName)
	allConfig=$(deleteKeyValue "$allConfig" $instanceName sshtunnelArray)

	local tunnelConfigArray=$(getSshtunnelConfiguration)

	for tunnelConfig in $tunnelConfigArray; do
		allConfig=$(addKeyArray "$allConfig" $instanceName sshtunnelArray "$tunnelConfig")
	done

    local string=$(stringfy "$allConfig")
    treehouses config add $configName $string 
}