
awsUsage() {
    echo "Usage: aws [command]"
    echo "Commands:"
    echo "   init   - Verify AWS CLI installation, SSH key existence, and defines functions for SSH key import and port addition in AWS EC2"
    echo "   delete - deletes an AWS EC2 instance and its related resources, identified by a given "balloon name", and handles associated cleanup tasks such as removing SSH tunnels and deleting security keys"
    echo "   stop   - stops a specified AWS EC2 instance and removes its associated SSH tunnel"
    echo "   restart- restarts a specified Amazon EC2 instance, updates its IP address, and opens a new SSH tunnel to it"
    exit 1
}

function driver() {

    # Check if at least one argument is provided
    if [ $# -eq 0 ]; then
        awsUsage
    fi

    # Execute the appropriate command
    case "$1" in
        init)
            init "${@:2}"
            ;;
        delete)
            delete "${@:2}"
            ;;
        stop)
            stop "${@:2}"
            ;;
        restart)
            restart "${@:2}"
            ;;
        install)
            installAwsCli "${@:2}"
            ;;
        *)
            echo "Error: Invalid command."
            awsUsage
            ;;
    esac

}
