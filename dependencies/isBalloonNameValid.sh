function getBalloonNameAsArray(){
    local array
    array=$(aws ec2 describe-instances | jq -r '.Reservations[].Instances[].Tags[] | select(.Key=="Name").Value')
    echo $array
}

function isBalloonNameValid() {
    balloonName="$1"
    balloonNamesString=$(getBalloonNameAsArray)

    if echo "$balloonNamesString" | grep -q -w -- "$balloonName"; then
        return 0
    else
        return 1
    fi
}