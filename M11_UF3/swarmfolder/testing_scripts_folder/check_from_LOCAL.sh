#!/usr/bin/env bash
# shellcheck disable=SC2059
##########################
# @Oriol Filter Anson    #
# @5/06/2021            #
##########################

#########################################################################
# Script intended to checking the firewall rules from the local network #
#########################################################################

##############
# COLOR VARS #
##############

COLOR_DEFAULT='\e[39m'
COLOR_RED='\e[91m'
COLOR_GREEN='\e[92m'
COLOR_BLUE='\e[34m'
COLOR_YELLOW='\e[93m'


### Hosts
#### Addr
ip_db="10.10.6.3"
ip_web="192.168.254.25"
ip_dmz="192.168.254.20"
ip_employee="10.10.6.101"
#### Ports
db_name="POSTGRESQL"

ip_externa="8.8.8.8"

## Dictionaries
declare -A port_dict=(["SFTP"]=23
["SMTP"]=25
["DNS"]=53
["HTTP"]=80
["POP3"]=110
["NETBIOS"]=139
["IMAP"]=143
["HTTPS"]=443
["SMB"]=445
["OPENMEETINGS"]=5443
["OPENFIRE"]=9090
["POSTGRESQL"]=5432
)

declare -A  dmz_local_enabled=(["SFTP"]=1
["DNS"]=1
["POP3"]=1
["NETBIOS"]=1
["IMAP"]=1
["SMB"]=1
["OPENMEETINGS"]=1
["OPENFIRE"]=1
)

declare -A  web_public_enabled=(["HTTP"]=1
["HTTPS"]=1
)

# Functions
cping () {
#$1 Is the ip/host to curl/"ping"
IP="$1";
echo curl "$1";
curl "$1" 2> /dev/null;
echo $?;
#if [[ "0" -eq "$?" ]] ; then
#  printf "[${COLOR_GREEN}*${COLOR_DEFAULT}] ${COLOR_GREEN}Successfully${COLOR_DEFAULT} ${COLOR_DEFAULT}established connection with the client $IP\n"
#else
#  printf "[${COLOR_RED}*${COLOR_DEFAULT}] ${COLOR_RED}Couldn't${COLOR_DEFAULT} ${COLOR_DEFAULT}establish connection with the client $IP\n"
#fi
}



## WEB
printf "\nIniciant les probes al servidor WEB\n"
printf "ping al server WEB amb IP $ip_web\n"
cping $ip_web;

for service in "${!web_public_enabled[@]}"; do
    printf "Provant d'accedir al servidor $service amb port ${port_dict[$service]}\n"
    nc -vz $ip_web ${port_dict[$service]}
    printf "\n"
done

## BDD
#printf "ping al server BDD amb IP $ip_db\n"
#cping $ip_db;
printf "Provant d'accedir al servidor POSTGRESQL amb port ${port_dict["POSTGRESQL"]}\n"
nc -vz $ip_db ${port_dict["POSTGRESQL"]}
printf "\n"

## DMZ
printf "\nIniciant les probes al servidor DMZ\n"

printf "ping al server DMZ amb IP $ip_dmz\n"
cping $ip_dmz;

printf "Provant d'accedir als ports del DMZ\n"
for service in "${!dmz_local_enabled[@]}"; do
    printf "Intent d'accedir al servei $service amb port ${port_dict[$service]}\n"
    nc -vz $ip_dmz ${port_dict[$service]}
    printf "\n"
done

printf "Intent de comunicacio amb el client de la xarxa interna: $ip_employee\n"
cping $ip_employee;


echo "la nostra ip publica es: $(curl ifconfig.me.)"
echo "Iniciant CURL a google.es\n";
curl "google.es";

echo "Check de update\n";
#sudo apt-get uppdate