#!/usr/bin/env bash
# Aquest script ha de ser executat per la maquina "SERVIDOR BDD" (10.10.6.3)
# Aquest script publica els ports de l'array

declare -A port_enabled=(["POSTGRESQL"]=5432)


for service in "${!port_enabled[@]}"; do
  echo "listening to port ${port_enabled["DNS"]} for service: $service"
  bash $(dirname $0)/open_portsh ${port_enabled[$service]} & disown
done