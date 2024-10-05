#!/bin/bash

#BASE=$HOME
BASE=/home/pi

# Fetch the instance ID based on balloonName, then terminate the EC2 instance if found.
# If the instance does not exist, the function exits early.
fetchInstanceIdAndTerminateEc2() {
  local balloonName=$1

  instanceId=$(getValueByAttribute "$balloonName" instanceId)

  if [ "$instanceId" = "null" ]; then
    echo "$balloonName does not exist"
    exit 0
  fi

  echo $instanceId
  aws ec2 terminate-instances --instance-ids $instanceId
  echo "EC2 instance terminated"
}

# Store TCP/UDP port information for a group, then attempt to delete the security group.
# If a dependency prevents deletion, it prints a dependency violation message.
storePortAndDeleteSecurityGroup() {
  local groupName=$1
  local balloonName=$2

  storePortArrayString "$groupName" tcp "$balloonName"
  storePortArrayString "$groupName" udp "$balloonName"

  echo "$groupName"
  output=$(aws ec2 delete-security-group --group-name "$groupName" 2>&1)

  if [[ $? -eq 0 ]]; then
    echo "Security group '$groupName' successfully deleted."
  elif [[ $output == *"DependencyViolation"* ]]; then
    echo "Dependency violation. Security group could not be deleted."
  else
    echo "An error occurred: $output"
  fi
}

# Delete an EC2 key pair by its name.
deleteEc2KeyPair() {
  local keyName=$1

  echo "$keyName"
  aws ec2 delete-key-pair --key-name "$keyName"
  echo "EC2 key pair deleted"
}

# Store TCP/UDP port information for a group, sleep for a given duration, and then attempt
# to delete the security group. If a dependency violation occurs, it retries after sleeping.
storePortAndDeleteSecurityGroupWithSleepAndRetry() {
  local groupName=$1
  local balloonName=$2
  local sleepDuration=$3 # Third argument for sleep duration

  storePortArrayString "$groupName" tcp "$balloonName"
  storePortArrayString "$groupName" udp "$balloonName"

  echo "Sleeping for $sleepDuration seconds before attempting to delete security group..."
  sleep "$sleepDuration"

  echo "$groupName"

  while true; do
    output=$(aws ec2 delete-security-group --group-name "$groupName" 2>&1)

    if [[ $? -eq 0 ]]; then
      echo "Security group '$groupName' successfully deleted."
      break
    elif [[ $output == *"DependencyViolation"* ]]; then
      echo "Dependency violation. Retrying in $sleepDuration seconds..."
      sleep "$sleepDuration"
    else
      echo "An error occurred: $output"
      break
    fi
  done
}

function down() {

  balloonName=$(setBalloonName "$1")
  keyName=$(getValueByAttribute "$balloonName" key)
  groupName=$(getValueByAttribute "$balloonName" groupName)

  detectIncompleteState "$balloonName" "$groupName" "$groupName"
  binaryState=$?

  if instanceExists "$binaryState" && securityGroupExists "$binaryState"; then
    fetchInstanceIdAndTerminateEc2 "$balloonName"
    storePortAndDeleteSecurityGroupWithSleepAndRetry "$groupName" "$balloonName" 30
  else
    if instanceExists $binaryState; then
      fetchInstanceIdAndTerminateEc2 "$balloonName"
    fi
    if securityGroupExists $binaryState; then
      storePortAndDeleteSecurityGroup "$groupName" "$balloonName"
    fi
  fi
  if keyPairExists $binaryState; then
    deleteEc2KeyPair "$keyName"
  fi

  updateSshtunnelConfig "$balloonName"
  treehouses sshtunnel remove all
  echo "remove all sshtunnel"

  deleteSshConfig "$balloonName"
  deleteObsoleteKeyValue "$balloonName"

}
