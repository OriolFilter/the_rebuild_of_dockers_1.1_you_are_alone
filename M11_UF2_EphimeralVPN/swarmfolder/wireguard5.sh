#https://upcloud.com/community/tutorials/get-started-wireguard-vpn/
# https://www.linode.com/docs/guides/set-up-wireguard-vpn-on-ubuntu/

# Enable port forwarding
echo 1 > /proc/sys/net/ipv4/ip_forward

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

sudo ufw allow ssh
sudo ufw allow 51820/udp
sudo ufw enable

cd /etc/wireguard
#umask 077
# Generates Keys
#wg genkey | tee srv_privatekey | wg pubkey > srv_publickey
#wg genkey | tee cli_privatekey | wg pubkey > cli_publickeycat
#wg genkey | tee privatekey | wg pubkey > publickey


## Generate conf
printf "
[Interface]
PrivateKey =  $(cat srv_privatekey)
Address = 10.0.0.1/24
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
ListenPort = 51820

[Peer]
PublicKey = $(cat cli_publickey)
AllowedIPs = 0.0.0.0/0
"


##
wg-quick up wg0

wg show

systemctl enable wg-quick@wg0




#### Client

printf "
[Interface]
Address = 10.10.6.101/24
PrivateKey = MEWSbMQkgJMfZH4lPNUV3MW5GhEULZ+vHbYaSgkyBVE=
DNS = 1.1.1.1

[Peer]
PublicKey = fmh0TqmDPoFgexSvpCN3jnbNvkAEtcWGUeLez/pYul8=
Endpoint = 192.168.1.212:51820
AllowedIPs = 10.10.6.0/24
" | sudo tee /etc/wireguard/wg0.conf