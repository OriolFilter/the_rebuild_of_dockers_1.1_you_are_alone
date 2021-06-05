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
ptables  -X
ptables  -Z
ptables  -t nat -F

iptables -P INPUT $allow
iptables -P OUTPUT $allow
iptables -P FORWARD $allow