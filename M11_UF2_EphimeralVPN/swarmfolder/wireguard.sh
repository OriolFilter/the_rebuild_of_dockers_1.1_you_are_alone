
# Set Vars
export INTERACTIVE="no"
export PRIVATE_SUBNET="10.6.0.0/24"
export SERVER_HOST="192.168.1.117"
export SERVER_PORT="51820"
export CLIENT_DNS="8.8.8.8,8.8.4.4"



# Install
wget https://raw.githubusercontent.com/l-n-s/wireguard-install/master/wireguard-install.sh -O wireguard-install.sh
printf "test\n" | sudo bash wireguard-install.sh
