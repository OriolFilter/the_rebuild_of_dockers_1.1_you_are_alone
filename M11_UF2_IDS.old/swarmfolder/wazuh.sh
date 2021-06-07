#!/bin/sh
#https://documentation.wazuh.com/current/docker/wazuh-container.html
#https://www.elastic.co/blog/improve-security-analytics-with-the-elastic-stack-wazuh-and-ids
#
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