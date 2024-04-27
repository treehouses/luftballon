replaceFirstOccurrence() {
    local all="$1"
    local first="$2"
    local second="$3"
    
    if [[ "$all" == *"$first"* ]]; then
        all="${all/$first/$second}"
    fi
    
    echo "$all"
}