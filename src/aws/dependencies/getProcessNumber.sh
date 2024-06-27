#!/bin/bash

getProcessNumber() {
    local targetString="$1"
    local processInfo="$2"
    local processNumber=$(
            echo "$processInfo" \
            | \
            awk -v target="$targetString" '$0 ~ /\/usr\/lib\/autossh\/autossh/ && $0 ~ target {print $2}'
        )

    if [ -n "$processNumber" ]; then
        echo "$processNumber"
    else
        echo ""
    fi
}

getProcessInfo() {
    local processInfo=$(ps aux | grep ssh)
    echo "$processInfo"
}

