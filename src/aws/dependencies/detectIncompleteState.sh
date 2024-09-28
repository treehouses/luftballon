#!/bin/bash

# Function to describe an EC2 instance by its Name tag
# Accepts one argument: instanceName
describeInstanceByName() {
  local instanceName=$1

  # Check if instanceName was provided
  if [ -z "$instanceName" ]; then
    echo "Error: Please provide an instance name."
    return 1
  fi

  # Run the AWS CLI command with the provided instanceName and capture the result in JSON format
  local result=$(aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=$instanceName" \
    --query 'Reservations[*].Instances[*].{Instance:InstanceId,State:State.Name,PublicIP:PublicIpAddress}' \
    --output json)

  # Check if result is empty, meaning no instances found
  if [ -z "$result" ] || [ "$result" = "[]" ]; then
    echo "No instances found with Name tag: $instanceName"
    return 1
  fi

  # Use jq to parse and display InstanceId, State, and PublicIP
  echo "$result" | jq -r '.[] | .[] | "\nInstanceId: \(.Instance)\nState: \(.State)\nPublicIP: \(.PublicIP // "N/A")\n"'
  return 0
}

# Function to check if a security group exists by its name
# Accepts one argument: groupName
checkSecurityGroupExists() {
  local groupName=$1

  # Describe security groups filtered by group name
  local result=$(aws ec2 describe-security-groups --group-names "$groupName" 2>&1)

  # Check if the result contains an error (security group not found)
  if echo "$result" | grep -q "InvalidGroup.NotFound"; then
    echo "Security group '$groupName' does not exist."
    return 1
  else
    echo "Security group '$groupName' exists."
    return 0
  fi
}

# Function to check if a key pair exists by its name
# Accepts one argument: keyName
checkKeyPairExists() {
  local keyName=$1

  # Describe key pairs filtered by key name
  local result=$(aws ec2 describe-key-pairs --key-name "$keyName" 2>&1)

  # Check if the result contains an error (key pair not found)
  if echo "$result" | grep -q "InvalidKeyPair.NotFound"; then
    echo "Key pair '$keyName' does not exist."
    return 1
  else
    echo "Key pair '$keyName' exists."
    return 0
  fi
}

# Parent function to detect the state of the instance, security group, and key pair
# Accepts three arguments:
#   $1: instanceName (for describeInstanceByName)
#   $2: groupName (for checkSecurityGroupExists)
#   $3: keyName (for checkKeyPairExists)
# Returns a binary value representing the state:
#   - Bit 2 (100): Instance exists
#   - Bit 1 (010): Security group exists
#   - Bit 0 (001): Key pair exists
detectIncompleteState() {
  local instanceName=$1
  local groupName=$2
  local keyName=$3

  # Initialize existence status variables (0 = exists, 1 = doesn't exist)
  local keyPairExists=0
  local securityGroupExists=0
  local instanceExists=0

  # Check if the instance exists
  describeInstanceByName "$instanceName"
  instanceExists=$? # 0 if exists, 1 if doesn't exist

  # Check if the security group exists
  checkSecurityGroupExists "$groupName"
  securityGroupExists=$? # 0 if exists, 1 if doesn't exist

  # Check if the key pair exists
  checkKeyPairExists "$keyName"
  keyPairExists=$? # 0 if exists, 1 if doesn't exist

  # Construct a binary value based on the resource existence statuses
  # Bit 2 -> instanceExists (shift left by 2 positions)
  # Bit 1 -> securityGroupExists (shift left by 1 position)
  # Bit 0 -> keyPairExists
  local binaryState=$(((instanceExists << 2) | (securityGroupExists << 1) | keyPairExists))

  # Output the binary value (as a decimal number)
  echo "Binary state (in decimal): $binaryState"

  # Return the binary state (as an integer)
  return $binaryState
}

# Example usage:
# To use the parent function `detectIncompleteState`, provide three arguments:
# 1. The name of the instance to check
# 2. The name of the security group to check
# 3. The name of the key pair to check
#
# Example:
# detectIncompleteState "luftballon" "luftballons-sg" "luftballon"
detectIncompleteState "luftballon" "luftballons-sg" "luftballon"
binaryState=$?

# Output the binary state in binary format for easier understanding
echo "Binary state (in binary): $(echo "obase=2; $binaryState" | bc)"

# Example: Interpret the binary state
if [[ $binaryState -eq 0 ]]; then
  echo "All resources exist."
else
  # Analyze each bit
  if ((binaryState & 4)); then
    echo "Instance does not exist."
  fi
  if ((binaryState & 2)); then
    echo "Security Group does not exist."
  fi
  if ((binaryState & 1)); then
    echo "Key Pair does not exist."
  fi
fi

# Example usage:
# To use the parent function `detectIncompleteState`, provide three arguments:
# 1. The name of the instance to check
# 2. The name of the security group to check
# 3. The name of the key pair to check
#
# Example:
# detectIncompleteState "my-instance-name" "my-security-group-name" "my-key-pair-name"
detectIncompleteState "luftballon" "luftballons-sg" "luftballon"
echo $?
