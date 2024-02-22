# This function updates or appends an IP and name pair to a file named "/etc/hosts".
# If the name already exists in the file, it updates the corresponding IP.
# If the name does not exist, it appends a new IP and name pair to the end of the file.
# Arguments:
#   ip: The IP address to be updated or appended.
#   name: The name to be updated or appended.
updateOrAppend() {
    local ip="$1"
    local name="$2"
    local file="/etc/hosts"

    local escaped_name=$(printf '%s\n' "$name" | sed 's:[][\/.^$*]:\\&:g')

    if grep -qP "^\S+\s+$escaped_name$" "$file"; then
        sed -i'' -r "/^\S+\s+$escaped_name$/s/.*/$ip\t$name/" "$file"
    else
        if [ "$(tail -c1 "$file")" != "" ]; then
            echo "" >> "$file"
        fi
        echo "$ip	$name" >> "$file"
    fi
}
