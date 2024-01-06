#!/bin/bash

updateCreds() {
    if [ ! -f "$FILE_PATH" ]; then
        echo "Credentials file not found. Please run the setup script first."
        exit 1
    fi

    echo "Updating credentials..."

    # Update username
    read -p "Enter your new username (leave blank to keep current): " new_username
    if [ -n "$new_username" ]; then
        sed -i "s/^username=.*/username=$new_username/" "$FILE_PATH"
    fi

    # Update password
    read -sp "Enter your new password (leave blank to keep current): " new_password
    echo
    if [ -n "$new_password" ]; then
        sed -i "s/^password=.*/password=$new_password/" "$FILE_PATH"
    fi

    # Update tenant name
    read -p "Enter your new tenant name (leave blank to keep current): " new_tenant_name
    if [ -n "$new_tenant_name" ]; then
        sed -i "s/^tenant_name=.*/tenant_name=$new_tenant_name/" "$FILE_PATH"
    fi

    echo "Credentials updated successfully."
}
