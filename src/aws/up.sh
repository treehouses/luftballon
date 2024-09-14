#!/bin/bash

portConfigArray=
udpPortConfigArray=

publickey=$(treehouses sshtunnel key name | cut -d ' ' -f 5).pub

keyname=
groupName=luftballons-sg
instanceName=luftballon
checkSSH=~/.ssh/$publickey

checkSshKey() {
  aws ec2 describe-key-pairs --key-names $keyname &>/dev/null
  return $?
}

checkSecurityGroup() {
  aws ec2 describe-security-groups --group-names $groupName &>/dev/null
  return $?
}

checkInstance() {
  aws ec2 describe-instances --filters "Name=tag:Name,Values=$instanceName" --query "Reservations[*].Instances[*].InstanceId" --output text
}

checkInstanceState() {
  ID=$1
  aws ec2 describe-instances --instance-ids $ID --query "Reservations[*].Instances[*].State.Name" --output text
}

function importSshKey() {
  if [[ -f ~/.ssh/$publickey ]]; then
    aws ec2 import-key-pair --key-name "$keyname" --public-key-material fileb://~/.ssh/$publickey
  else
    echo 'ssh key pair (~/.ssh/$publickey) do not exist ~/.ssh/$publickey'
    echo 'Please generate the ssh key by the commad "ssh-keygen -t rsa"'
    exit 1
  fi
}

function addPort() {
  aws ec2 authorize-security-group-ingress \
    --group-name $groupName \
    --protocol tcp \
    --port $1 \
    --cidr 0.0.0.0/0
}

function addUDPPort() {
  aws ec2 authorize-security-group-ingress \
    --group-name $groupName \
    --protocol udp \
    --port $1 \
    --cidr 0.0.0.0/0
}

function createSecurityGroups() {
  aws ec2 create-security-group \
    --group-name $groupName \
    --description "luftballons security group"
  if [ -z "$portConfigArray" ]; then
    portConfigArray="8080:80,8443:443,2022:22"
  fi
  portArray=($(makePortArray "$portConfigArray"))
  for i in "${portArray[@]}"; do
    addPort $i
    echo $i
  done
  if [ -z "$udpPortConfigArray" ]; then
    udpPortConfigArray="1194"
  fi
  portArray=($udpPortConfigArray)
  for i in "${portArray[@]}"; do
    addUDPPort $i
    echo $i
  done
}

function createEc2() {
  image="ami-0750fb43a63427eff"
  #image="ami-01e5ff16fd6e8c542"
  aws ec2 run-instances \
    --count 1 \
    --image-id $image \
    --instance-type t2.micro \
    --key-name $keyname \
    --security-groups $groupName
}

function findData() {
  keyWord=$1
  grep $keyWord | awk -F':' '{ print $2 }' | sed 's/ //g; s/"//g; s/,//g'
}

function deleteKeyword() {
  keyWord=$1
  sed "s/$keyWord//g; s/ //g"
}

function getValueByKeyword() {
  keyWord=$1
  findData $keyWord | deleteKeyword $keyWord
}

function usage {
  echo "script usage: $(basename \$0 aws up) [-n ssh key name] [-p] [-a change key name, instance name, and group name]" >&2
  echo 'Start Luftballon.'
  echo '   -n          Change SSH key name on AWS'
  echo '   -a          Change SSH key name, instance name, and group name'
  echo '   -p          Use stored port Numbers instead of the default port number.'
  exit 1
}

function up {
  while getopts 'n:pN:a:' OPTION; do
    case "$OPTION" in
    n)
      keyname=$OPTARG
      ;;
    p)
      portConfigArray=$(getArrayValueAsStringByKey $instanceName tcpPortArray)
      udpPortConfigArray=$(getArrayValueAsStringByKey $instanceName udpPortArray)
      if [ -z "$portConfigArray" ]; then
        echo "There is no stored port numbers. The default port numbers are used"
      fi
      if [ -z "$udpPortConfigArray" ]; then
        echo "There is no stored udp port numbers. The default port numbers are used"
      fi
      ;;
    a)
      groupName=$OPTARG-sg
      instanceName=$OPTARG
      keyname=$OPTARG
      ;;
    ?)
      usage
      ;;
    esac
  done
  shift "$(($OPTIND - 1))"

  aws --version || (echo "Run './installAwsCli.sh' first. AWS CLI is not installed." && exit 1)

  if test ! -f "$checkSSH"; then
    echo "Run 'ssh-keygen' first, with an empty passphrase for no passphrase. Missing ssh key." && exit 1
  fi

  if [ -z $keyname ]; then
    keyname=luftballon
  fi

  if ! checkSshKey; then
    importedKeyName=$(importSshKey | getValueByKeyword KeyName)
    if [ -z $importedKeyName ]; then
      exit 1
    fi
    echo "Success to add ssh key: $importedKeyName"
  else
    echo "The key pair $keyname already exists. Please use another key name."
  fi

  if ! checkSecurityGroup; then
    createSecurityGroups
    echo "Add security group"
    # Add rules to Security Group as needed
  else
    echo "Security Group already exists."
  fi

  createAndTagInstance() {
    instanceId=$(createEc2 | getValueByKeyword InstanceId)
    echo "Creating and running EC2 instance..."
    echo "Instance id is $instanceId"

    aws ec2 create-tags --resources $instanceId --tags Key=Name,Value=$instanceName
    aws ec2 create-tags --resources $instanceId --tags Key=Class,Value=treehouses

    publicIp=$(waitForOutput "getLatestIpAddress $instanceId")
    echo "Public IP Address is $publicIp"
    echo "Will open ssh tunnel soon"

    isOpen=$(waitForOutput "ssh-keyscan -H $publicIp | grep ecdsa-sha2-nistp256")
    echo "Opened ssh tunnel"

    openSSHTunnel $instanceName $publicIp $portConfigArray
    storeConfigIntoTreehousesConfigAsStringfiedJson $instanceName $importedKeyName $instanceId $publicIp $groupName
  }

  instanceId=$(checkInstance)
  if [ -z "$instanceId" ]; then
    createAndTagInstance
  else
    instanceState=$(checkInstanceState $instanceId)

    case "$instanceState" in
    "running")
      echo "EC2 instance is already running."
      ;;
    "stopped")
      echo "Starting stopped EC2 instance..."
      start $instanceName
      ;;
    "terminated")
      createAndTagInstance
      ;;
    *)
      echo "EC2 instance is in state: $instanceState."
      ;;
    esac
  fi
}
