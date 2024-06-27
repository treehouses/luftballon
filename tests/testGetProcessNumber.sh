testGetProcessNumber() {
    local luftballon="luftballon"
    
    # Test case 1: Find process number
    local processInfo1="root     1923245  0.0  0.0   2216    84 ?        Ss   03:18   0:00 /usr/lib/autossh/autossh    -T -N -q -4 -M 2200 luftballon"
    local result1=$(getProcessNumber "$luftballon" "$processInfo1")
    echo "Test case 1 - Process number: $result1"

    # Test case 2: No /usr/lib/autossh/autossh
    local processInfo2="root     1922602  0.0  0.1  19736 10404 ?        Ss   03:16   0:00 sshd: root@pts/0"
    local result2=$(getProcessNumber "$luftballon" "$processInfo2")
    echo "Test case 2 - Process number: $result2"

    # Test case 3: No luftballon
    local processInfo3="root     1923245  0.0  0.0   2216    84 ?        Ss   03:18   0:00 /usr/lib/autossh/autossh    -T -N -q -4 -M 2200 not_found"
    local result3=$(getProcessNumber "$luftballon" "$processInfo3")
    echo "Test case 3 - Process number: $result3"

    # Test case 4: Multiple /usr/lib/autossh/autossh
    local processInfo4="root     1923245  0.0  0.0   2216    84 ?        Ss   03:18   0:00 /usr/lib/autossh/autossh    -T -N -q -4 -M 2200 luftballon
root     1923246  0.3  0.1  14476  8072 ?        S    03:18   0:00 /usr/lib/autossh/autossh    -T -N -q -4 -M 2200 luftballon"
    local result4=$(getProcessNumber "$luftballon" "$processInfo4")
    echo "Test case 4 - Process number: $result4"

    local result5=$(getProcessNumber "$luftballon" "$(getProcessInfo)")
    echo "Test case 5 - Process number: $result5"
}
