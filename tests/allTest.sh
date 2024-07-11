
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

test_replaceFirstOccurrence() {
    local test_all="$1"
    local test_first="$2"
    local test_second="$3"
    local expected_result="$4"

    local result=$(replaceFirstOccurrence "$test_all" "$test_first" "$test_second")
    if [[ "$result" == "$expected_result" ]]; then
        echo "PASS: Got expected result '$result'"
    else
        echo "FAIL: Expected '$expected_result', but got '$result'"
    fi
}

# Run test cases
echo "Running test cases..."
test_replaceFirstOccurrence "8888:80,9999:443" "8888:80" "8887:81" "8887:81,9999:443"
test_replaceFirstOccurrence "8888:80,9999:443" "9999:443" "9998:442" "8888:80,9998:442"
test_replaceFirstOccurrence "8888:80,9999:443" "7777:77" "7776:76" "8888:80,9999:443"
test_replaceFirstOccurrence "8888:80,8888:80" "8888:80" "8887:81" "8887:81,8888:80"
test_replaceFirstOccurrence "" "8888:80" "8887:81" ""
echo "Tests completed."
