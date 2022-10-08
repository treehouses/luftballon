

manageConfigPath=$(pwd)
source $manageConfigPath/dependencies/manage-config.sh

BASE=/home/pi
groupName=luftballons-sg

instance_ip=$(extractValueFromTreehousesConfig instanceIp)
bastions_host_port=$1
server_port=$2

port_array=($(aws ec2 describe-security-groups | jq ".SecurityGroups[].IpPermissions[].FromPort"))
port_array_length=$((${#port_array[@]}-1))

function checkPort() {
	result=0
	for i in "${port_array[@]:0:$port_array_length}"
	do
        if (( $i>0 )) && [ $i -eq $1 ]   # Check if a equals b
        then
			result=$(($result+1))
		fi                 
	done
	return $result
}

function call_aws_add_port_command() {
	aws ec2 authorize-security-group-ingress \
		--group-name $groupName \
		--protocol tcp \
		--port $1 \
		--cidr 0.0.0.0/0
}



function add_port_security_groups(){
	checkPort $1 
	if [ $? -eq 0 ]  
	then              
		echo $1
		call_aws_add_port_command $1
	fi                 

	checkPort $2 
	if [ $? -eq 0 ]   
	then              
		echo $2
		call_aws_add_port_command $2
	fi                 
}


add_port_security_groups $bastions_host_port $server_port
echo $instance_ip
treehouses sshtunnel add port actual "$server_port" "$bastions_host_port" root@"$instance_ip"

storePortArrayString
storeSshtunnelConfiguration



