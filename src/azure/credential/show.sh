#!/bin/bash

showCreds() {
    if [ ! -f "$FILE_PATH" ]; then
        echo "Credentials file not found."
        exit 1
    fi

    echo "Current credentials:"
    while IFS= read -r line; do
        if [[ $line == password=* ]]; then
            password=${line#password=}
            masked_password="${password:0:6}*****"
            echo "password=$masked_password"
        else
            echo "$line"
        fi
    done < "$FILE_PATH"
}
