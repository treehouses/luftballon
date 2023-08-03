# Luftballon (🎈) VPN

## What is this?

You can generate VPN certificates by OpenVPN.  
Then, you can host the OpenVPN Server on Luftballon.

## How to use it?

### Install Dependencies

Execute the below function.

```
 ./install.sh
```

### Start VPN Server on the Luftballon

1. Install dependencies  
   If you use the Luftballon VPN first time, you need to install all dependencies first.

1. To create a Master Certificate Authority and a Server Certificate, run the command './makeVPNServer.sh'.

   ```
   ./makeVPNServer.sh
   ```

1. To start the VPN server on Luftballon, ensure that Luftballon is accessible and then run the command `./executeScriptOnRemoteServer.sh`.

   ```
   ./executeScriptOnRemoteServer.sh
   ```

### Start VPN Client Server

1. To start the VPN client server, run the command `./makeVPNClient.sh` in your terminal.

   ```
   ./makeVPNClient.sh
   ```

1. When prompted, answer 'Y' to the question:

   ```
   Do you want to start the OpenVPN client on this machine?.
   ```

   This will generate the client certificate and start the client server.

1. If you want to use a different name for the client OpenVPN configuration file, Client Certificate or Client Server, enter the desired name when prompted. Otherwise, press Enter to use the default name.

   ```
   Enter the name for the client openVPN config. [default is client1]
   ```

1. To confirm the request and sign the certificate, type 'yes' and press Enter. If you wish to cancel the request, type any other input.

   ```
   You are about to sign the following certificate.
   Please check over the details shown below for accuracy. Note that this request
   has not been cryptographically verified. Please be sure it came from a trusted
   source or that you have verified the request checksum with the sender.

   Request subject, to be signed as a client certificate for 1080 days:

   subject=
       commonName                = client8


   Type the word 'yes' to continue, or any other input to abort.
   Confirm request details:
   ```

### Make VPN Client Server

If you only make the Client Certificate, run the command `./makeVPNClient.sh` in your terminal.  
Then when prompted, answer 'n'
