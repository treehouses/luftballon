source load.sh

function sshConfigManagerUsage() {
    echo "Usage: driver <command> [options]"
    echo ""
    echo "Commands:"
    echo "  create <name> <host> <user> <port>   Create a new SSH configuration"
    echo "  update <name> <host> <user> <port>   Update an existing SSH configuration"
    echo "  delete <name>                        Delete an SSH configuration"
    echo ""
    echo "Options:"
    echo "  -h, --help                            Show help information"
}

function driver() {

    # Check if at least one argument is provided
    if [ $# -eq 0 ]; then
        sshConfigManagerUsage
    fi

    # Execute the appropriate command
    case "$1" in
        create)
            create "${@:2}"
            ;;
        update)
            callUpdate "${@:2}"
            ;;
        delete)
            delete "${@:2}"
            ;;
        *)
            echo "Error: Invalid command."
            sshConfigManagerUsage
            ;;
    esac

}