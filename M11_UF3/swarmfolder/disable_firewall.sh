#!/usr/bin/env bash
# shellcheck disable=SC2059
##########################
# @Oriol Filter Anson    #
# @5/06/2021            #
##########################

#############################################
# Script intended for flushing the firewall #
#############################################


###############
#    VARS     #
###############

## Behaviour
kill="DROP"
allow="ACCEPT"

iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X
iptables -t raw -F
iptables -t raw -X
iptables -t security -F
iptables -t security -X
iptables -P INPUT $allow
iptables -P FORWARD $allow
iptables -P OUTPUT $allow
