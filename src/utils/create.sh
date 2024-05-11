
createSshConfig() {
    HOST_NAME="$1"
    HOST_ENTRY=$(cat <<EOF

Host $HOST_NAME
    HostName $2
    User $3
    Port $4
    IdentityFile $5
    $(echo "$6" | awk -F, '{for (i = 1; i <= NF; i++) {split($i, ports, ":"); print "    RemoteForward " ports[1] " localhost:" ports[2]}}')
    ServerAliveInterval 30
    ServerAliveCountMax 3
    ExitOnForwardFailure yes
    TCPKeepAlive yes
EOF
)

    if grep -q "^Host $HOST_NAME$" $CONFIG; then
        echo "Configuration for $HOST_NAME already exists."
    else
        echo "$HOST_ENTRY" >> $CONFIG
        echo "Configuration for $HOST_NAME created."
    fi
}

#createSshConfig "myserver" "example.com" "user" "22" "~/.ssh/id_rsa" "8888:80,9999:443"
