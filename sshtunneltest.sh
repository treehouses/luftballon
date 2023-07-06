#!/bin/bash
manageConfigPath=$(pwd)
source $manageConfigPath/dependencies/config.sh
source $manageConfigPath/dependencies/utilitiyFunction.sh
source $manageConfigPath/dependencies/isBalloonNameValid.sh
source $manageConfigPath/dependencies/jsonOperations.sh
source $manageConfigPath/dependencies/configOperations.sh
source $manageConfigPath/dependencies/configFunctions.sh
source $manageConfigPath/dependencies/getLatestIpAddress.sh
source $manageConfigPath/dependencies/securitygroupFunction.sh
source $manageConfigPath/dependencies/manageConfig.sh
source $manageConfigPath/dependencies/sshtunnelFunction.sh
source $manageConfigPath/dependencies/reverseShell.sh

portConfigArray=
udpPortConfigArray=

publickey=`treehouses sshtunnel key name | cut -d ' ' -f 5`.pub

keyname=
groupName=luftballons-sg
instanceName=luftballon
checkSSH=~/.ssh/$publickey


function getNewPortinterval {
  local portinterval=$1
  local portint_offset=0
  while grep -qs -e "M $((portinterval - 1))" -e "M $portinterval" -e "M $((portinterval + 1))" ./tunnel; do
    portinterval=$((portinterval + 1))
    portint_offset=$((portint_offset + 1))
  done
  echo $portinterval
}

function createSecurityGroups(){

	if [ -z "$portConfigArray" ]
	then
		portConfigArray="22 2222 $(getNewPortinterval 2200)"
	fi

    portArray=($portConfigArray)

	for i in "${portArray[@]}"
	do
		echo $i
	done

	if [ -z "$udpPortConfigArray" ]
	then
		udpPortConfigArray="1194"
	fi

    portArray=($udpPortConfigArray)

	for i in "${portArray[@]}"
	do
		echo $i
	done
}


function getPort(){
    ip=$1
    port1=$2
    port2=$3
    port3=$4
    
    echo $ip
    echo $port1
    echo $port2
    echo $port3
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


createSecurityGroups
echo "Add security group"

getPort $publicIp $portConfigArray




