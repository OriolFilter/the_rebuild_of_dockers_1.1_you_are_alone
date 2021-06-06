#!/usr/bin/env bash
# Aquest script ha de ser executat per la maquina "DMZ" (192.168.254.25)
# Aquest script publica els ports de l'array

declare -A port_enabled=(["SFTP"]=23
["SMTP"]=25
# ["DNS"]=53 systemd-resolve default enabled on ubuntu clients, which im using for testing.
["POP3"]=110
["NETBIOS"]=139
["IMAP"]=143
["SMB"]=445
["OPENMEETINGS"]=5443
["OPENFIRE"]=9090
)

echo "Test de sudo/root accessible"
sudo echo "Check"

for service in "${!port_enabled[@]}"; do
  echo "listening to port ${port_enabled["DNS"]} for service: $service"
  sudo bash $(dirname $0)/open_port.sh ${port_enabled[$service]} & disown
done
