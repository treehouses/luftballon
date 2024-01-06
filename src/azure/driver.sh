#!/bin/bash

source config.sh
source load.sh

rootUsage() {
    echo "Usage: $0 [command group] [command]"
    echo "Command groups:"
    echo "   credential - Manage credentials (init, update, show)"
    echo "   auth       - Authentication management (login)"
    exit 1
}

# Check if at least one argument is provided
if [ $# -eq 0 ]; then
    rootUsage
fi

# Execute the appropriate command
case "$1" in
    credential)
        credential "$2"
        ;;
    auth)
        auth "$2"
        ;;
    *)
        echo "Error: Invalid command."
        rootUsage
        ;;
esac
