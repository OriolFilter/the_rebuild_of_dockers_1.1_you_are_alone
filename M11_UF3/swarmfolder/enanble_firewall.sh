#!/usr/bin/env bash
# shellcheck disable=SC2059
##########################
# @Oriol Filter Anson    #
# @5/06/2021            #
##########################

#############################################
# Script intended for building the firewall #
#############################################

##############
# COLOR VARS #
##############

COLOR_DEFAULT='\e[39m'
COLOR_RED='\e[91m'
COLOR_GREEN='\e[92m'
COLOR_BLUE='\e[34m'
COLOR_YELLOW='\e[93m'


###############
#    VARS     #
###############

## Behaviour
kill="DROP"
allow="ACCEPT"

## Network

### Interfaces
iface_lo="lo"
iface_pub="enp0s3"  # INTERNET
iface_dmz="enp0s8"  # DMZ
iface_lan="enp0s9"  # LAN

### DMZ
net_dmz="192.168.254.0/24"
net_dmz_mask="24"

### Employee
net_emp="10.10.6/24"
net_emp_gateway="10.10.6.1"

### Hosts
#### Addr
ip_db="10.10.6.3"
ip_web="192.168.254.25"
ip_dmz="192.168.254.20"
#### Ports
db_name="POSTGRESQL"

#### Port dictionary
## UPPERCASE and NUMBERS ONLY
# Translates from STR to PORT
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

#### DISABLED/ENABLED  0/1
declare -A  dmz_public_enabled=(["SFTP"]=1
["DNS"]=1
["POP3"]=1
["NETBIOS"]=1
["IMAP"]=1
["SMB"]=1
["OPENMEETINGS"]=1
["OPENFIRE"]=1
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

#
# Main
printf "Start\n"

### Reset/Flush
iptables -F
iptables -X
iptables -Z
iptables -t nat -F
#
### Default DROP
iptables -P INPUT $kill
iptables -P OUTPUT $kill
iptables -P FORWARD $kill
#
### Enable communication

iptables -A INPUT -m state --state ESTABLISHED,RELATED -j $allow && \
iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j $allow && \
iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j $allow  && \
printf "[${COLOR_GREEN}*${COLOR_DEFAULT}] ${COLOR_GREEN}Successfully${COLOR_DEFAULT} ${COLOR_DEFAULT}Enabled communication between clients that already connected\n"
#
### Enable forwarding
#
echo 1 > /proc/sys/net/ipv4/ip_forward && \
printf "[${COLOR_GREEN}*${COLOR_DEFAULT}] ${COLOR_GREEN}Successfully${COLOR_DEFAULT} ${COLOR_DEFAULT}Enabled port forwarding in the system\n"
#
##https://serverfault.com/questions/371316/iptables-difference-between-new-established-and-related-packets
#
#### Enable CONNECT to public services
iptables -A FORWARD -p tcp --dport ${port_dict["HTTP"]} -m state --state NEW -j $allow && \
iptables -A FORWARD -p tcp --dport ${port_dict["HTTPS"]} -m state --state NEW -j $allow && \
iptables -A FORWARD -p tcp --dport ${port_dict["DNS"]} -m state --state NEW -j $allow && \
iptables -A FORWARD -p udp --dport ${port_dict["DNS"]} -m state --state NEW -j $allow && \
printf "[${COLOR_GREEN}*${COLOR_DEFAULT}] ${COLOR_GREEN}Successfully${COLOR_DEFAULT} ${COLOR_DEFAULT}Enabled connection public services (WEB && DNS)\n"
#
#### MASQUERADE (enable outgoing traffic)
iptables -t nat -A POSTROUTING -s $net_emp -o $iface_pub -j MASQUERADE && \
iptables -t nat -A POSTROUTING -s $net_dmz -o $iface_pub -j MASQUERADE && \
printf "[${COLOR_GREEN}*${COLOR_DEFAULT}] ${COLOR_GREEN}Successfully${COLOR_DEFAULT} ${COLOR_DEFAULT}Enabled connection to the internet\n"



### PREROUTING
# NAT to DMZ PREROUTING
for service in "${!dmz_public_enabled[@]}"; do
  if [[ 1 -eq "${dmz_public_enabled[$service]}" ]] ; then
      iptables -t nat -A PREROUTING -i $iface_pub -p tcp --dport "${port_dict[$service]}" -j DNAT --to "${ip_dmz}:${port_dict[$service]}" && \
      printf "[${COLOR_GREEN}*${COLOR_DEFAULT}] ${COLOR_GREEN}Successfully${COLOR_DEFAULT} ${COLOR_DEFAULT}Enabled from the ${COLOR_RED}INTERNET${COLOR_DEFAULT} to the ${COLOR_BLUE}DMZ${COLOR_DEFAULT}\t\tprotocol: ${COLOR_RED}${port_dict[$service]}${COLOR_DEFAULT} (${COLOR_YELLOW}${service}${COLOR_DEFAULT})\n"
    fi
done

# NAT to WEB PREROUTING
for service in "${!port_dict[@]}"; do
  if [[ 1 -eq "${web_public_enabled[$service]}" ]] ; then
      iptables -t nat -A PREROUTING -i $iface_pub -p tcp --dport "${port_dict[$service]}" -j DNAT --to "${ip_web}:${port_dict[$service]}" && \
      printf "[${COLOR_GREEN}*${COLOR_DEFAULT}] ${COLOR_GREEN}Successfully${COLOR_DEFAULT} ${COLOR_DEFAULT}Enabled from the ${COLOR_RED}INTERNET${COLOR_DEFAULT} to the ${COLOR_BLUE}WEB Server${COLOR_DEFAULT}\tprotocol:${COLOR_DEFAULT} ${COLOR_RED}${port_dict[$service]}${COLOR_DEFAULT} (${COLOR_YELLOW}${service}${COLOR_DEFAULT})\n"
    fi
done

### FORWARDING
# WEB to DB  ENABLE
service=$db_name
iptables -A FORWARD -s $ip_web -d $ip_db -p tcp --dport "${port_dict[$service]}" -j $allow && \
printf "[${COLOR_GREEN}*${COLOR_DEFAULT}] ${COLOR_GREEN}Successfully${COLOR_DEFAULT} ${COLOR_DEFAULT}Enabled from the ${COLOR_RED}WEB Server${COLOR_DEFAULT} to the ${COLOR_BLUE}DATABASE${COLOR_DEFAULT}\tprotocol:${COLOR_DEFAULT} ${COLOR_RED}${port_dict[$service]}${COLOR_DEFAULT} (${COLOR_YELLOW}${service}${COLOR_DEFAULT})\n"
# DB to WEB  ENABLE
iptables -A FORWARD -s $ip_db -d $ip_web -p tcp --dport "${port_dict[$service]}" -j $allow && \
printf "[${COLOR_GREEN}*${COLOR_DEFAULT}] ${COLOR_GREEN}Successfully${COLOR_DEFAULT} ${COLOR_DEFAULT}Enabled from the ${COLOR_RED}DATABASE${COLOR_DEFAULT} to the ${COLOR_BLUE}WEB Server${COLOR_DEFAULT}\tprotocol:${COLOR_DEFAULT} ${COLOR_RED}${port_dict[$service]}${COLOR_DEFAULT} (${COLOR_YELLOW}${service}${COLOR_DEFAULT})\n"

# LAN to DMZ ENABLE
for service in "${!dmz_local_enabled[@]}"; do
  if [[ 1 -eq "${dmz_local_enabled[$service]}" ]] ; then
      iptables -A FORWARD -s $net_emp -d $net_dmz -p tcp --dport "${port_dict[$service]}" -m state --state NEW -j $allow && \
      printf "[${COLOR_GREEN}*${COLOR_DEFAULT}] ${COLOR_GREEN}Successfully${COLOR_DEFAULT} ${COLOR_DEFAULT}Enabled from the ${COLOR_RED}LAN${COLOR_DEFAULT} to the ${COLOR_BLUE}DMZ${COLOR_DEFAULT}\t\tprotocol: ${COLOR_RED}${port_dict[$service]}${COLOR_DEFAULT} (${COLOR_YELLOW}${service}${COLOR_DEFAULT})\n"
    fi
done

# END


### PRINT CURRENT FIREWALL RULES
sleep "0.2" && printf "." && sleep "0.2" && printf "." && sleep "0.2" && printf "." && sleep "0.2" && printf "." && sleep "0.2" && printf "."
printf "\nFinished configuring the firewall"
printf "\nPrinting current INPUT rules:\n"
printf "." && sleep "0.2" && printf "." && sleep "0.2" && printf "." && sleep "0.2" && printf "." && sleep "0.2" && printf "." && sleep "0.2" && printf "." && sleep "0.2" && printf "." && sleep "0.2"
printf "\n"
iptables -L INPUT
printf "." && sleep "0.2" && printf "." && sleep "0.2" && printf "." && sleep "0.2" && printf "." && sleep "0.2" && printf "." && sleep "0.2" && printf "." && sleep "0.2" && printf "." && sleep "0.2"
printf "\nPrinting current OUTPUT rules:\n"
printf "." && sleep "0.2" && printf "." && sleep "0.2" && printf "." && sleep "0.2" && printf "." && sleep "0.2" && printf "." && sleep "0.2" && printf "." && sleep "0.2" && printf "." && sleep "0.2"
printf "\n"
iptables -L OUTPUT
printf "." && sleep "0.2" && printf "." && sleep "0.2" && printf "." && sleep "0.2" && printf "." && sleep "0.2" && printf "." && sleep "0.2" && printf "." && sleep "0.2" && printf "." && sleep "0.2"
printf "\nPrinting current FORWARD rules:\n"
printf "." && sleep "0.2" && printf "." && sleep "0.2" && printf "." && sleep "0.2" && printf "." && sleep "0.2" && printf "." && sleep "0.2" && printf "." && sleep "0.2" && printf "." && sleep "0.2"
printf "\n"
iptables -L FORWARD
sleep 2
printf "\n(END)\n"