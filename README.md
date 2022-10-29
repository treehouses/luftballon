# luftballon

🎈

## What Luftballon does?

Luftballon makes sshtunnel via AWS EC2 by one command

## How to use Luftballon

### Prerequisite

1. Have an AWS account
2. Luftballon must be on Treehouses image
3. Have a pair of ssh key (public key's name must be id_rsa.pub)

### How to run

At first, you need to have aws cli on your device.

If you do not have aws cli on your device, execute the below script.

`./installAwsCli.sh`

Then, make a sshtunnel via AWS EC2

Execute the below command

`./start.sh`

This command does several things

1. Add ssh key
2. Make security group
3. Configure security group (Open ports)
4. Create EC2 instance
5. Record EC2 instance ID and the ip address of the EC2 instance
6. Open sshtunnel

