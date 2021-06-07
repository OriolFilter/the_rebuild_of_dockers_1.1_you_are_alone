#!/bin/sh
# BRIDGED NETWORK
#https://fabianlee.org/2019/04/01/kvm-creating-a-bridged-network-with-netplan-on-ubuntu-bionic/
#https://documentation.wazuh.com/current/docker/wazuh-container.html
#https://www.elastic.co/blog/improve-security-analytics-with-the-elastic-stack-wazuh-and-ids

# Utilities for debugging
sudo apt-get install bridge-utils -y;
## NETPLAN
#
#echo -e "
##network:
##  version: 2
##  renderer: networkd
##
##  ethernets:
##    enp1s0:
##      dhcp4: true
##      dhcp6: false
##      addresses: [192.168.1.239/24]
##      gateway4: 192.168.1.1
##      mtu: 1500
##      nameservers:
##        addresses: [8.8.8.8]
#  bridges:
#    br0:
#      interfaces: [enp1s0]
#      addresses: [192.168.1.239/24]
#      gateway4: 192.168.2.1
#      mtu: 1500
#      nameservers:
#        addresses: [8.8.8.8]
#      parameters:
#        stp: true
#        forward-delay: 4
#      dhcp4: no
#      dhcp6: no
#" | tee -a /etc/netplan/01-netcfg.yaml;
## Update netplan
#sudo netplan generate;
#sudo netplan --debug apply;
##

wget -O /usr/bin/tc-mirror https://raw.githubusercontent.com/SteveMcGrath/mirror_tools/master/tc-mirror.sh
chmod 755 /usr/bin/tc-mirror
#printf "
#auto span0
#iface span0 inet manual
#        bridge_stp off
#        bridge_fd 0
#        bridge_maxwait 0
#        bridge_ageing 0
#        post-up /usr/bin/tc-mirror build ens192 span0
#        pre-down /usr/sbin/tc-mirror teardown ens192
#        " | tee -a /etc/netplan/01-netcfg.yaml
printf "
  bridges:
    br0:
      interfaces: [enp0s8, enp0s3]
      addresses: [192.168.0.4/24]
#      gateway4: 192.168.0.1
      nameservers:
        search: []
        addresses: [192.168.0.2]
        " | tee -a /etc/netplan/01-netcfg.yaml

sudo iptables -A FORWARD -p all -i br0 -j ACCEPT
# Permanent changes
iptables-save > /etc/iptables/rules.v4


### WAZUH
## Changes the memory limit for the virtual machines
sudo sysctl -w vm.max_map_count=262144
## Clones
git clone https://github.com/wazuh/wazuh-docker.git -b v4.1.5 --depth=1
### Deploys demo
cd wazuh-docker
docker-compose up -d
#https://documentation.wazuh.com/current/installation-guide/wazuh-agent/deployment_variables/linux/deployment_variables_apt.html#deployment-variables-apt
# Agent
curl -so wazuh-agent.deb https://packages.wazuh.com/4.x/apt/pool/main/w/wazuh-agent/wazuh-agent_4.1.5-1_amd64.deb && sudo WAZUH_MANAGER='wazuh' WAZUH_AGENT_GROUP='default' dpkg -i ./wazuh-agent.deb
sudo systemctl daemon-reload
sudo systemctl enable wazuh-agent
sudo systemctl start wazuh-agent

#http://openaccess.uoc.edu/webapps/o2/bitstream/10609/107166/6/lgstogujTFM1219memoria.pdf

#git clone https://github.com/wazuh/wazuh-docker.git -b v4.1.5 --depth=1
#cd wazuh-docker
#docker-compose -f generate-opendistro-certs.yml run --rm generator
#docker-compose -f production-cluster.yml up