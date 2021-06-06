sudo add-apt-repository ppa:wireguard/wireguard
sudo apt-get update
sudo apt-get install -y wireguard
umask 077
wg genkey | tee privatekey | wg pubkey > publickey


printf "
[Interface]
#thinkpad
PrivateKey=$(cat privatekey)
Address=10.252.0.3/32
DNS=192.168.0.253

[Peer]
#opnsense
PublicKey=$(cat publickey)
Endpoint=linuxserver:51820
AllowedIPs=0.0.0.0/0, ::/0

" | tee  /etc/wireguard/wg0.conf