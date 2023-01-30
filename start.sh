#!/bin/bash

manageConfigPath=$(pwd)
source $manageConfigPath/dependencies/manageConfig.sh
source $manageConfigPath/dependencies/reverseShell.sh
source $manageConfigPath/dependencies/getLatestIpAddress.sh

keyname=
portConfigArray=
publickey=id_rsa.pub
groupName=luftballons-sg
instanceName=luftballon
checkSSH=~/.ssh/$publickey

aws --version || ( echo "Run './installAwsCli.sh' first. AWS CLI is not installed." && exit 1 )

if test ! -f "$checkSSH"; then
	echo "Run 'ssh-keygen' first, with an empty passphrase for no passphrase. Missing ssh key." && exit 1
fi

function importSshKey()
{
	aws ec2 import-key-pair --key-name "$keyname" --public-key-material fileb://~/.ssh/$publickey  
}

function addPort(){
	aws ec2 authorize-security-group-ingress \
		--group-name $groupName \
		--protocol tcp \
		--port $1 \
		--cidr 0.0.0.0/0
}

function createSecurityGroups(){
	aws ec2 create-security-group \
		--group-name $groupName \
		--description "luftballons security group"

	if [ -z $portConfigArray ]
	then
		portConfigArray="22 2222 2200"
	fi
	portArray=($portConfigArray)
	echo $portArray

	for i in "${portArray[@]}"
	do
		addPort $i
		echo $i
	done
}


function createEc2(){
	image="ami-07d02ee1eeb0c996c"
	aws ec2 run-instances \
		--count 1 \
		--image-id $image \
		--instance-type t2.micro \
		--key-name $keyname \
		--security-groups $groupName 
}


function findData(){
	keyWord=$1
	grep $keyWord | awk -F':' '{ print $2 }' | sed 's/ //g; s/"//g; s/,//g' 
}

function deleteKeyword(){
	keyWord=$1
    sed "s/$keyWord//g; s/ //g"
}

function getValueByKeyword(){
	keyWord=$1
    findData $keyWord | deleteKeyword $keyWord
}



while getopts 'n:pN:' OPTION; do
  case "$OPTION" in
    n)
      keyname=$OPTARG
      ;;
    p)
      portConfigArray=$(getPortArrayString)
      ;;
    N)
      instanceName=$OPTARG
      ;;
    ?)
      echo "script usage: $(basename \$0) [-n ssh key name] [-p somevalue] [-N instance name] " >&2
      exit 1
      ;;
  esac
done
shift "$(($OPTIND -1))"

if [ -z $keyname ]
then
	keyname=luftballon
fi


keyName=$(importSshKey | getValueByKeyword KeyName )
echo $keyName
treehouses config add keyName $keyName
echo "Add key"

createSecurityGroups
echo "Add security group"

instanceId=$(createEc2 | getValueByKeyword InstanceId )
echo $instanceId
treehouses config add instanceId $instanceId
echo "Create EC2 Instance"

publicIp=$(getLatestIpAddress $instanceId )
treehouses config add publicIp $publicIp
echo "Store IP Address"

treehouses config add groupName $groupName
echo "Store Group Name"

echo "Add name "$instanceName" on EC2 instance"
aws ec2 create-tags --resources $instanceId --tags Key=Name,Value=$instanceName

echo "Will open ssh tunnel soon"
isOpen=$(ssh-keyscan -H $publicIp | grep ecdsa-sha2-nistp256)

while [ -z "$isOpen" ]
do
    echo "Check out the status of server"
    sleep 5
    isOpen=$(ssh-keyscan -H $publicIp | grep ecdsa-sha2-nistp256)
done

openSSHTunnel $publicIp
