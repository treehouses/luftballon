source jsonController.sh

function getBalloonNameAsArray(){
    local array
    array=$( filterInstancesByTag "$(aws ec2 describe-instances)" | jq -r '.[].Tags[] | select(.Key=="Name").Value')
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