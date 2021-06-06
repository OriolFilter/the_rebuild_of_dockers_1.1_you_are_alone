#!/usr/bin/env bash

# Basic firewall
sudo ufw allow 22/tcp
sudo ufw allow 51820/udp
printf "y\n" | sudo ufw enable

# Install packages
sudo apt update
add-apt-repository ppa:wireguard/wireguard
sudo apt -y install wireguard
# Enable forwarding
sysctl -w net.ipv4.ip_forward=1

# En el nostre cas necessitem instalar moduls del sistema, per aixo s'ha utilitzat la seguent maquina docker.
echo 'Instalant moduls necessaris per a fer sevir wireguard:';
docker run --rm -it \
 	-v /lib/modules:/lib/modules \
 	-v /usr/src:/usr/src:ro \
 	r.j3ss.co/wireguard:install;

# Move conf
sudo mv ~/swarmfolder/srv/wg0.conf /etc/wireguard/

# Start net
sudo wg-quick up wg0
