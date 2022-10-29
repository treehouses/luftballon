# luftballon

🎈

## What Luftballon does?

Luftballon makes sshtunnel for your Raspberry Pi via an AWS EC2 instance by one command.

## How to use Luftballon

### Prerequisite

1. Have an AWS account
2. Luftballon must be on Treehouses image
3. Have a pair of ssh key (public key's name must be id_rsa.pub)

### How to run

At first, you need to have aws cli on your Raspberry Pi.

If you do not have aws cli on your Raspberry Pi, execute the below script.

`./installAwsCli.sh`

Then, configure your aws cli.
Please consult [this page](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-prereqs.html) for setting up your aws cli if you use the aws cli at the first time.

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

If the command succeeds, you will get the output on your command screen like below.

```
Below sshtunnels are configured
root@[ip address]:2200 2222:22
```

The ip address is assigned by AWS, so it is not fixed value.

Then, go to a different device such as your laptop, and execute the below command.

`ssh -p 2222 root@[ip address]`

You can login to your Raspberry Pi via the EC2 instance.
