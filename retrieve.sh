source read.sh
extract_ssh_config_to_variables() {
    # Capture the output of get_ssh_config_values
    CONFIG_OUTPUT=$(get_ssh_config_values "$1")

    # Check if the configuration was found
    if echo "$CONFIG_OUTPUT" | grep -q "No configuration found"; then
        echo "No configuration found for $1."
        return 1
    fi

    # Extracting configuration details
    HOST_NAME=$(echo "$CONFIG_OUTPUT" | grep "Host " | awk '{print $NF}')
    HOSTNAME=$(echo "$CONFIG_OUTPUT" | grep "HostName " | awk '{print $NF}')
    USER=$(echo "$CONFIG_OUTPUT" | grep "User " | awk '{print $NF}')
    PORT=$(echo "$CONFIG_OUTPUT" | grep "Port " | awk '{print $NF}')
    IDENTITYFILE=$(echo "$CONFIG_OUTPUT" | grep "IdentityFile " | awk '{print $NF}')
    REMOTEFORWARD=$(echo "$CONFIG_OUTPUT" | grep "RemoteForward " | awk '{$1=""; print $0}' | xargs)
    LOCALPORT=$(echo "$REMOTEFORWARD" | cut -d' ' -f1)
    REMOTEHOSTANDPORT=$(echo "$REMOTEFORWARD" | cut -d' ' -f2)
    REMOTEHOST=$(echo "$REMOTEHOSTANDPORT" | cut -d':' -f1)
    REMOTEPORT=$(echo "$REMOTEHOSTANDPORT" | cut -d':' -f2)
    SERVERALIVEINTERVAL=$(echo "$CONFIG_OUTPUT" | grep "ServerAliveInterval " | awk '{print $NF}')
    SERVERALIVECOUNTMAX=$(echo "$CONFIG_OUTPUT" | grep "ServerAliveCountMax " | awk '{print $NF}')
    EXITONFORWARDFAILURE=$(echo "$CONFIG_OUTPUT" | grep "ExitOnForwardFailure " | awk '{print $NF}')
    TCPKEEPALIVE=$(echo "$CONFIG_OUTPUT" | grep "TCPKeepAlive " | awk '{print $NF}')

    # Display the variables for demonstration
    echo "HOST_NAME: $HOST_NAME"
    echo "HOSTNAME: $HOSTNAME"
    echo "USER: $USER"
    echo "PORT: $PORT"
    echo "IDENTITYFILE: $IDENTITYFILE"
    echo "REMOTEFORWARD: $REMOTEFORWARD"
    echo "LOCALPORT: $LOCALPORT"
    echo "REMOTEHOST: $REMOTEHOST"
    echo "REMOTEPORT: $REMOTEPORT"
    echo "SERVERALIVEINTERVAL: $SERVERALIVEINTERVAL"
    echo "SERVERALIVECOUNTMAX: $SERVERALIVECOUNTMAX"
    echo "EXITONFORWARDFAILURE: $EXITONFORWARDFAILURE"
    echo "TCPKEEPALIVE: $TCPKEEPALIVE"
}

extract_ssh_config_to_variables remoteserver1