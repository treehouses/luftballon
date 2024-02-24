# AWS EC2 Management Script

This script is designed to simplify the management of AWS EC2 instances. It provides easy-to-use commands for initializing and deleting EC2 instances.

## Usage

This script supports two main commands: init and delete.

### Command: init

The init command verifies the AWS CLI installation, checks for the existence of an SSH key, and defines functions for importing an SSH key and adding ports in AWS EC2.

```bash
./driver.sh init [additional options]
```

Options for init:

- -n [ssh key name]: Specify a name for the SSH key on AWS.
- -a [balloon name]: Change the SSH key name, instance name, and group name, based on the provided balloon name.
- -p: Use stored port numbers instead of the default port number.

### Command: delete

The delete command deletes an AWS EC2 instance and its related resources, identified by a given "balloon name". It also handles cleanup tasks such as removing SSH tunnels and deleting security keys.

```bash
./driver.sh delete [balloon name]
```

### Command: stop

The stop command stops a specified AWS EC2 instance and removes its associated SSH tunnel.

```bash
./driver.sh stop [balloon name]
```

### Command: restart

The restart command restarts a specified Amazon EC2 instance, updates its IP address, and opens a new SSH tunnel to it.

```bash
./driver.sh restart [balloon name]
```

### Help

To view the usage instructions, use the following command:

```bash
./driver.sh
```
