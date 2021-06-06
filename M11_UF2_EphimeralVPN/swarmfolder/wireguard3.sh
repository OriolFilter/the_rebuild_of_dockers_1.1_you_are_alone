# https://www.linode.com/docs/guides/set-up-wireguard-vpn-on-ubuntu/

sudo add-apt-repository ppa:wireguard/wireguard;
sudo apt-get update;
sudo apt-get install -y wireguard;

# Fix?
echo 'Instalant moduls necessaris per a fer sevir wireguard:';
docker run --rm -it \
 	-v /lib/modules:/lib/modules \
 	-v /usr/src:/usr/src:ro \
 	r.j3ss.co/wireguard:install;


# Perms
umask 077;
# Generate Keys (private/public)
wg genkey | tee privatekey | wg pubkey > publickey;

printf "
[Interface]
PrivateKey = $(cat privatekey)
Address = 10.10.6.1/24
ListenPort = 51820
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o enp0s3 -j MASQUERADE; ip6tables -A FORWARD -i wg0 -j ACCEPT; ip6tables -t nat -A POSTROUTING -o enp0s3 -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o enp0s3 -j MASQUERADE; ip6tables -D FORWARD -i wg0 -j ACCEPT; ip6tables -t nat -D POSTROUTING -o enp0s3 -j MASQUERADE
SaveConfig = false
" | tee /etc/wireguard/wg0.conf


# Firewall
sudo ufw allow 22/tcp
sudo ufw allow 51820/udp
sudo ufw enable
# Check Firewall
sudo ufw status verbose


# Start the service
wg-quick up wg0
# Enable the service on boot
sudo systemctl enable wg-quick@
# Check if VPN is running
sudo wg show
ifconfig wg0