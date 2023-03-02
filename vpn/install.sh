# Install openvpn, upzip, and easyrsa
# easyrsa is installed with openvpn
# easyrsa is in /usr/share/easy-rsa/
apt update && apt install -y openvpn unzip

# Install easytls
cd /usr/share/easy-rsa/
wget https://github.com/TinCanTech/easy-tls/archive/refs/heads/master.zip
unzip master.zip
cd easy-tls-master/
cp ./easytls ../
cd ..
rm -r easy-tls-master/
rm master.zip