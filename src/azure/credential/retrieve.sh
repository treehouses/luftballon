#!/bin/bash

retrieveCred() {
    local key=$1
    local file=$FILE_PATH 

    local value=$(grep "^$key=" "$file" | cut -d'=' -f2)

    if [ -z "$value" ]; then
        echo "" 
    else
        echo $value 
    fi
}
