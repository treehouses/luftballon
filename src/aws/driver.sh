source load.sh

awsUsage() {
    echo "Usage: $0 credential [command]"
    echo "Commands:"
    echo "   init   - Verify AWS CLI installation, SSH key existence, and defines functions for SSH key import and port addition in AWS EC2"
    exit 1
}

function auth(){

    # Check if at least one argument is provided
    if [ $# -eq 0 ]; then
        awsUsage
    fi

    # Execute the appropriate command
    case "$1" in
        init)
            init
            ;;
        *)
            echo "Error: Invalid command."
            authUsage
            ;;
    esac

}