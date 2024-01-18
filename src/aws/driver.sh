source load.sh

awsUsage() {
    echo "Usage: $0 credential [command]"
    echo "Commands:"
    echo "   init   - Verify AWS CLI installation, SSH key existence, and defines functions for SSH key import and port addition in AWS EC2"
    echo "   delete - deletes an AWS EC2 instance and its related resources, identified by a given "balloon name", and handles associated cleanup tasks such as removing SSH tunnels and deleting security keys"
    exit 1
}

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
    *)
        echo "Error: Invalid command."
        authUsage
        ;;
esac
