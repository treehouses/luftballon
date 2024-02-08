#!/bin/bash

manageConfigPath=$(pwd)

usage() {
    echo "Usage: $0 credential [command]"
    echo "Commands:"
    echo "   aws   - Execute an AWS command"
    exit 1
}

# Check if at least one argument is provided
if [ $# -eq 0 ]; then
    usage
fi

# Execute the appropriate command
case "$1" in
    aws)
        source $manageConfigPath/src/aws/load.sh
        driver "${@:2}"
        ;;
    *)
        echo "Error: Invalid command."
        usage
        ;;
esac
