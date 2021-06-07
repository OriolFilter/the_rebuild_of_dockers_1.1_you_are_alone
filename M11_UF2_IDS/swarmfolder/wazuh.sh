#!/bin/sh
# BRIDGED NETWORK
#https://fabianlee.org/2019/04/01/kvm-creating-a-bridged-network-with-netplan-on-ubuntu-bionic/
#https://documentation.wazuh.com/current/docker/wazuh-container.html
#https://www.elastic.co/blog/improve-security-analytics-with-the-elastic-stack-wazuh-and-ids

cd ~/swarmfolder

## Changes the memory limit for the virtual machines
sudo sysctl -w vm.max_map_count=262144

# We are currently working in the directory ~/swarmfolder

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
# Configuration that allows the agent to parse the json data from suricata.
printf "
<agent_config>
    <localfile>
        <log_format>json</log_format>
        <location>/var/log/suricata/eve.json</location>
    </localfile>
</agent_config>
" | sudo tee  /var/ossec/etc/shared/agent.conf



## Clones Repository
#cd wazuh-docker
### Deploys Default Container with default values
#docker-compose up -d

# Wazuh Agent
curl -so wazuh-agent.deb https://packages.wazuh.com/4.x/apt/pool/main/w/wazuh-agent/wazuh-agent_4.1.5-1_amd64.deb && sudo WAZUH_MANAGER='wazuh' WAZUH_AGENT_GROUP='default' dpkg -i ./wazuh-agent.deb
sudo systemctl daemon-reload
sudo systemctl enable wazuh-agent
sudo systemctl start wazuh-agent

#Start Wazuh Manager in background
### Wazuh Manager
cd wazuh-docker
git clone https://github.com/wazuh/wazuh-docker.git -b v4.1.5 --depth=1
docker-compose -f generate-opendistro-certs.yml run --rm generator
docker-compose -f production-cluster.yml up -d

echo "ways to trigger events:"
printf "
## Trigger alerts (sorted by less to higher)
curl http://testmyids.com # This will detect that a page is trying to leak information from the system, alert danger 3;
# Connecting via SSH and successfully logging in creates an alert of danger 3;
nmap 10.10.6.1 # Triggers 'Suspicious scan to port X', where X means the port scanned, alert of danger 3;
# Having access to the sudo account and or changing the user UID to 0 triggers an alert of danger 3;
# Managing packages with apt trigger an alert o
suricata -s signatures.rules -i enp0s8  # This will detect that an interface is currently sniffing traffic, alert danger 8;
hping3 -c 15000 -d 120 -S -w 64 -p 80 --flood --rand-source  # DoS attack, alter danger 12, suricata detects it as 'FLOW_EMERGENCY', this would mean that an attacker gained access to the system.;
"
# Check logs
#tail -n1 /var/log/suricata/fast.log
#tail -n1 /var/log/suricata/eve.json | jq .

