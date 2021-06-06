sudo ufw allow 22/tcp
sudo ufw allow 51820/udp
sudo ufw enable

sudo apt update
add-apt-repository ppa:wireguard/wireguard
sudo apt -y install wireguard

umask 077; wg genkey | sudo tee /etc/wireguard/privatekey | wg pubkey | sudo tee /etc/wireguard/publickey
touch /etc/wireguard/wg0.conf

#
#[Interface]
#Address =10.10.6.0/24
#
#SaveConfig = false
#ListenPort = 51820
#PrivateKey =SMCDZkfWEUKyN5Mbvi01Aee5CJCIo3FGWKsaPNYQWnI=
#PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -t nat -A POSTROUTING -oenp0s3 -j MASQUERADE
#PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -t nat -D POSTROUTING-o enp0s3 -j MASQUERADE


sysctl -w net.ipv4.ip_forward=1
wg-quick up wg0

sudo wg set wg0 peer Pu6Yj2d6nvw1am6XBSx9u52f9vKSQlgtoJgkJofPpgU= allowed-ips 10.10.6.102/32


# Client

#[Interface]PrivateKey =KJf30VdqaaPR0jjUqk9pEm++Hg+sXyStPH8Ou2ggeHQ=
#Address =10.10.6.101/24
#[Peer]PublicKey =J8DrplnC2hDhbgBg460pzaspbAcdahiK4/2Ant/L/AQ=
#AllowedIPs =0.0.0.0/0, ::/0
#Endpoint =10.10.6.1:51820


# Server
wg set wg0 peer vgJeO8S9ZDF4PkrwQPfahfpXS+qatvV4V37Q+g4AWH0= allowed-ips 10.10.6.1