#!/bin/sh
# BRIDGED NETWORK
#https://fabianlee.org/2019/04/01/kvm-creating-a-bridged-network-with-netplan-on-ubuntu-bionic/
#https://documentation.wazuh.com/current/docker/wazuh-container.html
#https://www.elastic.co/blog/improve-security-analytics-with-the-elastic-stack-wazuh-and-ids

# Suricata

curl -O https://copr.fedorainfracloud.org/coprs/jasonish/suricata-stable/repo/epel-7/jasonish-suricata-stable-epel-7.repo
apt-get install -y suricata
wget https://rules.emergingthreats.net/open/suricata-4.0/emerging.rules.tar.gz
tar zxvf emerging.rules.tar.gz
rm /etc/suricata/rules/* -f
mv rules/*.rules /etc/suricata/rules/
rm -f /etc/suricata/suricata.yaml
wget -O /etc/suricata/suricata.yaml http://www.branchnetconsulting.com/wazuh/suricata.yaml
systemctl daemon-reload
systemctl enable suricata
systemctl start suricata
# Show current suricata info
suricata --build-info
sleep 5



# Wazuh Agent
printf "
<agent_config>
    <localfile>
        <log_format>json</log_format>
        <location>/var/log/suricata/eve.json</location>
    </localfile>
</agent_config>
" | sudo tee  /var/ossec/etc/shared/agent.conf

# Trigger alerts
#curl http://testmyids.com
#suricata -s signatures.rules -i enp0s8

# Check logs
#tail -n1 /var/log/suricata/fast.log
#tail -n1 /var/log/suricata/eve.json | jq .

#
#wget -O /usr/bin/tc-mirror https://raw.githubusercontent.com/SteveMcGrath/mirror_tools/master/tc-mirror.sh
#chmod 755 /usr/bin/tc-mirror

### Wazuh Manager
## Changes the memory limit for the virtual machines
sudo sysctl -w vm.max_map_count=262144
## Clones Repository
git clone https://github.com/wazuh/wazuh-docker.git -b v4.1.5 --depth=1
### Deploys Default Container with default values
cd wazuh-docker
docker-compose up -d


# Wazuh Agent
curl -so wazuh-agent.deb https://packages.wazuh.com/4.x/apt/pool/main/w/wazuh-agent/wazuh-agent_4.1.5-1_amd64.deb && sudo WAZUH_MANAGER='wazuh' WAZUH_AGENT_GROUP='default' dpkg -i ./wazuh-agent.deb
sudo systemctl daemon-reload
sudo systemctl enable wazuh-agent
sudo systemctl start wazuh-agent

#Start Wazuh Manager
cd wazuh-docker
docker-compose -f generate-opendistro-certs.yml run --rm generator
docker-compose -f production-cluster.yml up