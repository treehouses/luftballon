authUsage() {
    echo "Usage: $0 credential [command]"
    echo "Commands:"
    echo "   login   - Login azure as service-principal"
    exit 1
}

function auth(){

    # Check if at least one argument is provided
    if [ $# -eq 0 ]; then
        authUsage
    fi

    # Execute the appropriate command
    case "$1" in
        login)
            login
            ;;
        *)
            echo "Error: Invalid command."
            authUsage
            ;;
    esac

}