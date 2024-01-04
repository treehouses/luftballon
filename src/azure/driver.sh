#!/bin/bash

source config.sh
source loadScripts.sh

usage() {
    echo "Usage: $0 [command]"
    echo "Commands:"
    echo "   init    - Initialize and store new credentials"
    echo "   update  - Update existing credentials"
    echo "   show    - Display current credentials"
    echo "   login   - Login azure as service-principal"
    exit 1
}

# Check if at least one argument is provided
if [ $# -eq 0 ]; then
    usage
fi

# Execute the appropriate command
case "$1" in
    credential)
        credential "$2"
        ;;
    login)
        login
        ;;
    *)
        echo "Error: Invalid command."
        usage
        ;;
esac
