
extractBlocks() {
    local input_string="$1"
    local block_pattern='([0-9]+)\ localhost:([0-9]+)'
    local -a blocks_array

    while read -r block; do
        if [[ $block =~ $block_pattern ]]; then
            blocks_array+=("$block")
        fi
    done <<< "$(echo $input_string | grep -oE '([0-9]+)\ localhost:[0-9]+')"

    for block in "${blocks_array[@]}"; do
        echo "$block"
    done
}

input_string="12345 localhost:22 54321 localhost:80 ..."
# Capture the output in an array
readarray -t captured_blocks < <(extractBlocks "$input_string")
# Print each captured block
for block in "${captured_blocks[@]}"; do
    echo "$block"
done