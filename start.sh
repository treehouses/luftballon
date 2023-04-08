#!/bin/bash
manageConfigPath=$(pwd)
source $manageConfigPath/dependencies/manageConfig.sh
source $manageConfigPath/dependencies/reverseShell.sh
source $manageConfigPath/dependencies/getLatestIpAddress.sh
source $manageConfigPath/dependencies/jsonController.sh
source $manageConfigPath/dependencies/storeConfigByJson.sh

portConfigArray=
publickey=`treehouses sshtunnel key name | cut -d ' ' -f 5`.pub

keyname=
groupName=luftballons-sg
instanceName=luftballon
checkSSH=~/.ssh/$publickey

aws --version || ( echo "Run './installAwsCli.sh' first. AWS CLI is not installed." && exit 1 )

if test ! -f "$checkSSH"; then
	echo "Run 'ssh-keygen' first, with an empty passphrase for no passphrase. Missing ssh key." && exit 1
fi

function importSshKey()
{
    if [[ -f ~/.ssh/$publickey ]]
    then
        aws ec2 import-key-pair --key-name "$keyname" --public-key-material fileb://~/.ssh/$publickey  
    else
        echo 'ssh key pair (~/.ssh/$publickey) do not exist ~/.ssh/$publickey'
        echo 'Please generate the ssh key by the commad "ssh-keygen -t rsa"'
        exit 1
    fi
}

function addPort(){
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

	addUDPPort 1194
	echo 1194
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

function usage {
		echo "script usage: $(basename \$0) [-n ssh key name] [-p] [-a change key name, instance name, and group name]" >&2
        echo 'Start Luftballon.'
        echo '   -n          Change SSH key name on AWS'
        echo '   -a          Change SSH key name, instance name, and group name'
        echo '   -p          Use stored port Numbers instead of the default port number.'
        exit 1
}

while getopts 'n:pN:a:' OPTION; do
  case "$OPTION" in
    n)
      keyname=$OPTARG
      ;;
    p)
      portConfigArray=$(getArrayValueAsStringByKey $instanceName portArray)
	  if [ -z $portConfigArray ]
	  then
	    echo "There is no stored port numbers. The default port numbers are used"
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
shift "$(($OPTIND -1))"

if [ -z $keyname ]
then
	keyname=luftballon
fi


keyName=$(importSshKey | getValueByKeyword KeyName )

if [ -z $keyName ]
then 
	exit 1
fi

treehouses config add keyName $keyName
echo "Add key $keyName"

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
storeConfigIntoTreehousesConfigAsStringfiedJson $instanceName $keyName $instanceId $publicIp $groupName



