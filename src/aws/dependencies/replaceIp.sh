replaceIp() {
    FILE="/etc/tunnel"

    if [ "$#" -ne 2 ]; then
        echo "Usage: replace_ip OLD_IP NEW_IP"
        return 1
    fi

    oldIp=$1
    newIp=$2

    if [ -f "$FILE" ]; then
        sudo sed -i "s/$newIp/$oldIp/g" "$FILE"
        echo "IP address has been successfully replaced."
    else
        echo "Error: File $FILE does not exist."
        return 1
    fi
}
