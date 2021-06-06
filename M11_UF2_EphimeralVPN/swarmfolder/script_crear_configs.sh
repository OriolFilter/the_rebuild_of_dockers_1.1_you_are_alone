## REQUISITES
# docker running and access to it

## VARS
# SERVER
PIP="192.168.1.117" #Public IP
POP=51820 # Public Open Port
IFACE="enp0s8" # Interface to redirect the traffic
ADDRESS="10.10.6.0/24" # Address to give the server

# CLIENT
CLIIP="10.10.6.102" # Client DESIRED IP
CLIMSK="24" # Client DESIRED net MASK
ALLOWEDIPS="10.10.6.0/24" # List of allowed ip/mask, separated by coma, 0.0.0.0/0 to forward all the traffic.

# Creacio d'una carpeta per emmagatzemar els fitxers resultants
mkdir srv cli ;


# SRV KEYS
docker run --rm r.j3ss.co/wireguard genkey | tee srv/srv_privatekey;
docker run --rm -i r.j3ss.co/wireguard pubkey < srv/srv_privatekey | tee srv/srv_publickey;
# CLI KEYS
docker run --rm r.j3ss.co/wireguard genkey | tee cli/cli_privatekey;
docker run --rm -i r.j3ss.co/wireguard pubkey < cli/cli_privatekey | tee cli/cli_publickey;


printf "\n"
echo "----------------------------------"
echo "--------------SERVER--------------"
echo "----------------------------------"

# Generate Server config
printf "
[Interface]
Address =  $ADDRESS
SaveConfig = true
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o $IFACE -j MASQUERADE;
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o $IFACE -j MASQUERADE;
ListenPort = $POP
PrivateKey = $(cat srv/srv_privatekey)

[Peer]
PublicKey = $(cat cli/cli_publickey)
AllowedIPs = ${CLIIP}/32
" | tee srv/w0.conf

printf "\n"
echo "----------------------------------"
echo "--------------CLIENT--------------"
echo "----------------------------------"

# Generate Client config
printf "
[Interface]
Address = ${CLIIP}/${CLIMSK}
SaveConfig = true
ListenPort = 49539
PrivateKey = $(cat cli/cli_privatekey)

[Peer]
PublicKey = $(cat cli/cli_publickey)
AllowedIPs = $ALLOWEDIPS
Endpoint = $PIP:$POP
PersistentKeepalive = 30
" | tee srv/w0.conf
printf "\n"

