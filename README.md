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

Then, configure your AWS CLI with [`aws configure`](https://docs.aws.amazon.com/cli/latest/reference/configure/index.html).  
Please consult [this page](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-prereqs.html) for setting up your AWS CLI if you use the AWS CLI at the first time.  
Also, [this page](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html#cli-configure-quickstart-creds-create)
explains the configuration basics.

> **Note**
> Please set up the output format as `json`

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

```
./init.sh
```

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

### Start Luftballon with different name

```
./init.sh -a [name]
```

This a flag changes three names

1. key name
2. Security group name
3. EC2 Instance name

### Stop Luftballon (currently unstable)

```
./stop.sh [name]
```

### Restart Luftballon (currently unstable)

```
./restart.sh [name]
```

### Add other ports to sshtunnel

The init.sh only makes the sshtunnel connecting the port 2222 of EC2 instance to the port 22 of the Raspberry Pi.
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

This command basically does the opposite of the `init.sh`

1. Close sshtunnels
2. Delete EC2 instance
3. Delete security group on the EC2 portal
4. Delete ssh key on the AWS EC2 portal

### sshConfigManager Interface

The `sshConfigManager` interface is designed to facilitate the management of SSH configurations, providing methods to create, update, and delete SSH configuration entries. This interface streamlines the process of maintaining complex SSH config files, making it easier to manage access to multiple remote servers.

#### Create Command

**What it does:**  
The `create` command generates a new entry in the SSH configuration file with detailed settings for host alias, hostname, user, port, identity file, and port forwarding options.

**How to execute:**  
To add a new SSH configuration entry:

```
create "myserver" "example.com" "user" "22" "~/.ssh/id_rsa" "8888:80,9999:443"
```

This command sets up a host with alias `myserver`, connecting to `example.com` on port 22 with the specified identity file and port forwarding settings.

#### Update Command

**What it does:**  
The `update` command modifies an existing SSH configuration entry for a specified host. It can change settings for any key such as `User`, `Port`, or complex keys like `RemoteForward`, where both old and new port forwarding settings need to be specified.

**How to execute:**  
To change the `User` for host `myserver`:

```
update myserver User newuser
```

To update a `RemoteForward` setting:

```
update myserver RemoteForward 8888:80 8899:80
```

These commands adjust the specified configurations, replacing old values with new ones.

#### Delete Command

**What it does:**  
The `delete` command removes an entire SSH configuration block for a specified host from the SSH config file, effectively discontinuing the SSH management for that host through the configuration file.

**How to execute:**  
To remove the configuration for a host:

```
delete myserver
```

This command deletes all settings associated with the host `myserver`, cleaning up the SSH config file by removing unused or outdated entries.
