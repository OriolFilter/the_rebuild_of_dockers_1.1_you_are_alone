#!/usr/bin/env bash


### Hosts
#### Addr
ip_db="10.10.6.3"
ip_web="192.168.254.25"
ip_dmz="192.168.254.20"
#### Ports
db_name="POSTGRESQL"


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


## WEB
printf "\nIniciant les probes al servidor WEB\n"
printf "ping al server WEB amb IP $ip_web\n"
ping -c 4 $ip_web;

for service in "${!port_dict[@]}"; do
    printf "Intent d'accedir al servei $service amb port ${port_dict[$service]}\n"
    nc -vz $ip_dmz ${port_dict[$service]}
    printf "\n"
done

## BDD
printf "ping al server BDD amb IP $ip_web\n"
ping -c 4 $ip_db;
printf "Intent d'accedir al servei POSTGRESQL amb port ${port_dict["POSTGRESQL"]}\n"
nc -vz $ip_dmz ${port_dict["POSTGRESQL"]}
printf "\n"

## DMZ
printf "\nIniciant les probes al servidor DMZ\n"

printf "ping al server DMZ amb IP $ip_dmz\n"
ping -c 4 $ip_dmz;

printf "Comprovant els ports oberts del servidor DMZ"
for service in "${!port_dict[@]}"; do
    printf "Intent d'accedir al servei $service amb port ${port_dict[$service]}\n"
    nc -vz $ip_dmz ${port_dict[$service]}
    printf "\n"
done


echo "Iniciant ping a 8.8.8.8";
ping -c 4 8.8.8.8;