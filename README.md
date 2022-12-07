# luftballon

🎈

## What Luftballon does?

Luftballon makes a sshtunnel for your Raspberry Pi via an AWS EC2 instance by one command.

## How to use Luftballon

### Prerequisite

1. Have an AWS account
2. Luftballon must be on Treehouses image
3. Have a pair of ssh key (public key's name must be id_rsa.pub)

### How to run

### Install AWS CLI

At first, you need to have AWS CLI on your Raspberry Pi. If you have the AWS CLI, and it is propely configured, you can skip it

If you do not have AWS CLI on your Raspberry Pi, execute the below script.

`./installAwsCli.sh`

Then, configure your AWS CLI.
Please consult [this page](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-prereqs.html) for setting up your AWS CLI if you use the AWS CLI at the first time.
Also, [this page](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html#cli-configure-quickstart-creds-create) 
explains the configuration basics.

```
**Note**  
Please set up the output format as `json`
```

The below is the example of the config. 
```bash
AWS Access Key ID [***your access key***] 
AWS Secret Access Key [***your access key***] 
Default region name [your region]: 
Default output format [json]:
```

### Start Luftballon

If you have the properly configured AWS CLI, you can start Luftballon by a command.

Execute the below command

`./start.sh`

This command does several things

1. Add ssh key on the AWS EC2 portal
2. Make security group on the EC2 portal
3. Configure security group (Open ports)
4. Create EC2 instance
5. Record EC2 instance ID and the ip address of the EC2 instance
6. Open a sshtunnel

If the command succeeds, you will get the output on your command screen like below.

```
Below sshtunnels are configured
root@[ip address of EC2]:2200 2222:22
```

The ip address is assigned by AWS, so it is not fixed value.

Then, go to a different device such as your laptop, and execute the below command.

`ssh -p 2222 root@[ip address]`

You can login to your Raspberry Pi via the EC2 instance.

### Add other ports to sshtunnel

The start.sh only makes the sshtunnel connecting the port 2222 of EC2 instance to the port 22 of the Raspberry Pi.
You can make another sshtunnel by the below command.

`./addPort.sh [EC2 port number] [Raspberry Pi port number]`

For example, `./addPort.sh 8080 80` makes the sshtunnel between the port 8080 of the EC2 and the port 80 of the Raspberry Pi.

If you host a web application on your Raspberry Pi on the port 80, people can access to the application via `[ip address of the EC2]:8080`

### Delete ports from the sshtunnel

You can delete the sshtunnel by the below command

`./deletePort.sh [EC2 port number] [Raspberry Pi port number]`

### Delete Luftballon

It is nice to connect to your Raspberry Pi by sshtunnel, but you have to pay money to Amazon to have the sshtunnels.
If you do not need to use the sshtunnel, you do not want to pay money for nothing.

The below comand delete the Luftballon.

`./delete.sh`

This command basically does the opposite of the `start.sh`

1. Close sshtunnels
2. Delete EC2 instance
3. Delete security group on the EC2 portal
4. Delete ssh key on the AWS EC2 portal
