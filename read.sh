get_ssh_config_values() {
    HOST_NAME=$1
    CONFIG_FILE=config
    FOUND_HOST=0

    while IFS= read -r line; do
        if [[ "$line" == Host\ $HOST_NAME ]]; then
            FOUND_HOST=1
            echo "$line"
        elif [[ "$line" == Host\ * && $FOUND_HOST -eq 1 ]]; then
            break
        elif [[ $FOUND_HOST -eq 1 ]]; then
            echo "$line"
        fi
    done < "$CONFIG_FILE"

    if [ $FOUND_HOST -eq 0 ]; then
        echo "No configuration found for $HOST_NAME."
    fi
}
