
dummy=config

delete_ssh_config() {
    HOST_NAME="$1"
    TEMP_FILE=$(mktemp)
    
    # Ensure the temporary file gets deleted
    trap "rm -f $TEMP_FILE" EXIT

    awk -v host="$HOST_NAME" '
    $1 == "Host" && $2 == host {skip = 1}
    $1 == "Host" && $2 != host && skip {skip = 0; print ""}
    !skip {print}
    ' $dummy > "$TEMP_FILE" && mv "$TEMP_FILE" $dummy
    
    echo "Configuration for $HOST_NAME deleted."
}
delete_ssh_config "remoteserver"
