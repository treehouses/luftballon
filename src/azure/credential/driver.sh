
credentialUsage() {
    echo "Usage: $0 credential [command]"
    echo "Commands:"
    echo "   init    - Initialize and store new credentials"
    echo "   update  - Update existing credentials"
    echo "   show    - Display current credentials"
    exit 1
}

function credential(){

    # Check if at least one argument is provided
    if [ $# -eq 0 ]; then
        credentialUsage
    fi

    # Execute the appropriate command
    case "$1" in
        init)
            initCreds
            ;;
        update)
            updateCreds
            ;;
        show)
            showCreds
            ;;
        *)
            echo "Error: Invalid command."
            credentialUsage
            ;;
    esac

}