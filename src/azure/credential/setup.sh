#!/bin/bash

saveCreds() {
    read -p "Enter your username: " username
    read -sp "Enter your password: " password
    echo
    read -p "Enter your tenant name: " tenant_name

    # Storing credentials in the file
    echo "username=$username" > "$FILE_PATH"
    echo "password=$password" >> "$FILE_PATH"
    echo "tenant_name=$tenant_name" >> "$FILE_PATH"

    echo "Credentials stored successfully in $FILE_PATH."
}

checkDirFile() {
    if [ ! -d "$DIR_PATH" ]; then
        echo "Directory $DIR_PATH does not exist. Creating now."
        mkdir "$DIR_PATH"
    else
        echo "Directory $DIR_PATH already exists."
    fi

    if [ ! -f "$FILE_PATH" ]; then
        echo "Creating credentials file at $FILE_PATH."
        touch "$FILE_PATH"
    else
        echo "Credentials file already exists at $FILE_PATH."
    fi
}

initCreds() {
    checkDirFile
    saveCreds
}
