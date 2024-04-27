
extractBlocks() {
    local inputString="$1"
    local blockPattern='([0-9]+)\ localhost:([0-9]+)'
    local -a blocksArray
    local allPortsPairs=""

    while read -r block; do
        if [[ $block =~ $blockPattern ]]; then
            blocksArray+=("$block")
        fi
    done <<< "$(echo $inputString | grep -oE '([0-9]+)\ localhost:[0-9]+')"

    for block in "${blocksArray[@]}"; do
        local localPort=$(echo "$block" | cut -d' ' -f1)
        local remoteHostAndPort=$(echo "$block" | cut -d' ' -f2)
        local remotePort=$(echo "$remoteHostAndPort" | cut -d':' -f2)
        allPortsPairs+="${localPort}:${remotePort},"
    done
    allPortsPairs="${allPortsPairs%,}"
    echo "$allPortsPairs"
}

