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

1. Make PKI (a Master CA and a Server Certificate)  
   Execute the below function

   ```
   ./makeVPNServer.sh
   ```

1. Start VPN Server on Luftballon
   At first, make sure that you have an accessible Luftballon.  
   Then, execute the below function

   ```
   ./executeScriptOnRemoteServer.sh
   ```

### Start VPN Client Server

1. Make Client Certificate and Start the Client Server  
   Execute the below function

   ```
   ./makeVPNClient.sh
   ```

1. Answer the question to Y  
   The script asks you the below question.

   ```
   Do you start openVPN client on this machine? If not, the script just make client config [Y/n]
   ```

   You need to type y.  
   The script makes the Client certificate and starts the Client server.

1.
