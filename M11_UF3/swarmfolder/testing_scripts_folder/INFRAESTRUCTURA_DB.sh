#!/usr/bin/env bash
# Aquest script ha de ser executat per la maquina "SERVIDOR BDD" (10.10.6.3)
# Aquest script publica els ports de l'array

declare -A port_enabled=(["POSTGRESQL"]=5432)

echo "Test de sudo/root accessible"
sudo echo "Check"

for service in "${!port_enabled[@]}"; do
  echo "listening to port ${port_enabled["DNS"]} for service: $service"
  sudo bash $(dirname $0)/open_port.sh ${port_enabled[$service]} & disown
done