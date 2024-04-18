source array.sh

test_extractBlocks() {
    local input_string="$1"
    echo "Testing with input: $input_string"
    # Capture the output in an array
    readarray -t captured_blocks < <(extractBlocks "$input_string")
    # Print each captured block
    for block in "${captured_blocks[@]}"; do
        echo "$block"
    done
}

test_extractBlocks "12345 localhost:22 54321 localhost:80 ..."
test_extractBlocks "67890 localhost:443 another_text 98765 localhost:8080"
