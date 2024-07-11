
function sshConfigManagerUsage() {
    echo "Usage: driver <command> [options]"
    echo ""
    echo "Commands:"
    echo "  create <host> <hostname> <user> <port> <identityfile> <remoteforward> - Generates an SSH configuration block with specified host, user, port, identity key, and port forwarding settings."
    echo "         <remoteforward> should be specified in the format 'local_port:remote_port', and you can include multiple mappings separated by commas to forward several ports."
    echo ""
    echo "  update <host> <key> <new value> - Modifies an existing key-value pair in the SSH configuration for the specified host."
    echo "  update <host> <RemoteForward> <old value> <new value> - Updates a specific RemoteForward entry by replacing an old port mapping with a new one."
    echo ""
    echo "  delete <host> - Removes the entire SSH configuration entry associated with the specified host."
    echo ""
    echo "Options:"
    echo "  -h, --help                            Show help information"
}

function configDriver() {

    # Check if at least one argument is provided
    if [ $# -eq 0 ]; then
        sshConfigManagerUsage
    fi

    # Execute the appropriate command
    case "$1" in
        create)
            createSshConfig "${@:2}"
            ;;
        update)
            updateSshConfigInterface "${@:2}"
            ;;
        delete)
            deleteSshConfig "${@:2}"
            ;;
        *)
            echo "Error: Invalid command."
            sshConfigManagerUsage
            ;;
    esac

}
