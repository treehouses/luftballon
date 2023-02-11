source getRunningVPNEntityConfName.sh

function stopVPNEntityIfRunning(){
    entityType=$1
    vpnEntityName=$(getRunningVPNEntityConfName $entityType)
    if [ -n "$vpnEntityName" ]; then
        echo "Stop VPN $entityType whose name is $vpnEntityName"
    fi
}

stopVPNEntityIfRunning client
stopVPNEntityIfRunning server
