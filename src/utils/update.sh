update_ssh_config() {
    HOST_NAME="$1"
    TEMP_FILE=$(mktemp)
    
    # Ensure the temporary file gets deleted
    trap "rm -f $TEMP_FILE" EXIT

    awk -v host="$HOST_NAME" '
    $1 == "Host" && $2 == host {skip = 1}
    $1 == "Host" && $2 != host && skip {skip = 0; print ""}
    !skip {print}
    ' $CONFIG > "$TEMP_FILE" && mv "$TEMP_FILE" $CONFIG
    
    create_ssh_config "$@"
    echo "Configuration for $HOST_NAME updated."
}
