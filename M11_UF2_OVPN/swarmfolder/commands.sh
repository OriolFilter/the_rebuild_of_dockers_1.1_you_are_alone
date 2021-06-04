#!/bin/bash

# Requires:
# docker-compose

DOMAIN="192.168.1.117" #Visible IP
#CA password: abc123

OVPN_DATA="ovpn-data"
CERTS_FOLDER='./ovpn_certs' # Storing folder
CLIENTNAME="test"
SERVICE="ovpn"
COMPOSE="docker-compose.ovpn.yml"
CAPASS="abc123"
COMMONNAME="vpn.ofa.itb"
# Generate
docker-compose -f $COMPOSE run --rm $SERVICE ovpn_genconfig -u "udp://$DOMAIN:1194"  # Creates default config, if it's the first time running, we could pause it here and modify the files
docker-compose -f $COMPOSE run --rm $SERVICE ovpn_initpki # Generates Certificate/Certificate config, in case of already exists, needs to print yes

# Creates and exports certificate
docker-compose -f $COMPOSE run --rm $SERVICE easyrsa build-client-full $CLIENTNAME nopass
docker-compose -f $COMPOSE run --rm $SERVICE ovpn_getclient "$CLIENTNAME" > "${CERTS_FOLDER}/${CLIENTNAME}.ovpn" # Extracts cert