#!/bin/bash

portConfigArray=
udpPortConfigArray=

publickey=`treehouses sshtunnel key name | cut -d ' ' -f 5`.pub

keyname=
groupName=luftballons-sg
instanceName=luftballon
checkSSH=~/.ssh/$publickey



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

function getNewPortinterval {
  local portinterval=$1
  local portint_offset=0
  while grep -qs -e "M $((portinterval - 1))" -e "M $portinterval" -e "M $((portinterval + 1))" /etc/tunnel; do
    portinterval=$((portinterval + 1))
    portint_offset=$((portint_offset + 1))
  done
  echo $portinterval
}

function createSecurityGroups(){
	aws ec2 create-security-group \
		--group-name $groupName \
		--description "luftballons security group"

	if [ -z "$portConfigArray" ]
	then
		portConfigArray="22 2222 $(getNewPortinterval 2200)"
	fi

    portArray=($portConfigArray)

	for i in "${portArray[@]}"
	do
		addPort $i
		echo $i
	done

	if [ -z "$udpPortConfigArray" ]
	then
		udpPortConfigArray="1194"
	fi

    portArray=($udpPortConfigArray)

	for i in "${portArray[@]}"
	do
		addUDPPort $i
		echo $i
	done
}

function createEc2(){
    image="ami-0750fb43a63427eff"
    #image="ami-01e5ff16fd6e8c542"
	aws ec2 run-instances \
		--count 1 \
		--image-id $image \
		--instance-type t2.micro \
		--key-name $keyname \
		--security-groups $groupName 
        --user-data file://./setupIpTables.txt
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
		echo "script usage: $(basename \$0 aws init) [-n ssh key name] [-p] [-a change key name, instance name, and group name]" >&2
        echo 'Start Luftballon.'
        echo '   -n          Change SSH key name on AWS'
        echo '   -a          Change SSH key name, instance name, and group name'
        echo '   -p          Use stored port Numbers instead of the default port number.'
        exit 1
}

function init {
	while getopts 'n:pN:a:' OPTION; do
	case "$OPTION" in
		n)
		keyname=$OPTARG
		;;
		p)
		portConfigArray=$(getArrayValueAsStringByKey $instanceName tcpPortArray)
		udpPortConfigArray=$(getArrayValueAsStringByKey $instanceName udpPortArray)
		if [ -z "$portConfigArray" ]
		then
			echo "There is no stored port numbers. The default port numbers are used"
		fi
		if [ -z "$udpPortConfigArray" ]
		then
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
	shift "$(($OPTIND -1))"

	aws --version || ( echo "Run './installAwsCli.sh' first. AWS CLI is not installed." && exit 1 )

	if test ! -f "$checkSSH"; then
		echo "Run 'ssh-keygen' first, with an empty passphrase for no passphrase. Missing ssh key." && exit 1
	fi

	if [ -z $keyname ]
	then
		keyname=luftballon
	fi


	keyName=$(importSshKey | getValueByKeyword KeyName )

	if [ -z $keyName ]
	then 
		exit 1
	fi

	echo "Success to add ssh key: $keyName"

	createSecurityGroups
	echo "Add security group"

	instanceId=$(createEc2 | getValueByKeyword InstanceId )
	echo "Create EC2 Instance"
	echo "Instance id is $instanceId"


	aws ec2 create-tags --resources $instanceId --tags Key=Name,Value=$instanceName
	aws ec2 create-tags --resources $instanceId --tags Key=Class,Value=treehouses


	publicIp=$(waitForOutput "getLatestIpAddress $instanceId")
	echo "Public IP Address is $publicIp"

	echo "Will open ssh tunnel soon"
	isOpen=$(waitForOutput "ssh-keyscan -H $publicIp | grep ecdsa-sha2-nistp256")
	echo "Opened ssh tunnel"

	openSSHTunnel $publicIp $portConfigArray

	storeConfigIntoTreehousesConfigAsStringfiedJson $instanceName $keyName $instanceId $publicIp $groupName
}


