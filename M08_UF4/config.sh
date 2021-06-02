#!/bin/bash
SCRIPTFOLDER="$(dirname $0)"
SSH="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o loglevel=ERROR -i CLAU"
SSHP="2222"
NAMEVM="MAINS-OFA"
USERNAME="sjo"
FILESFOLDER="swarmfolder"


DOMAIN="OFA.itb"
IPL="10.10.6.1"

# Copiar files config

scp -P $SSHP $SSH  -r $SCRIPTFOLDER/$FILESFOLDER/ $USERNAME@localhost:~

### Command start

CMD="echo '.';
printf '# Transferint e iniciant lscript de configuracio\n';


#echo 'Pulling required images to speed up a little';
docker pull sameersbn/bind;
docker pull networkboot/dhcpd;
docker pull classcat/postfix-dovecot;
#docker pull quantumobject/docker-openfire;
docker pull atmoz/sftp;
docker pull nginx;
#docker pull gersilex/cvlc;
docker pull \"ccrisan/motioneye:master-amd64\";
docker pull apache/openmeetings;

cd ./$FILESFOLDER/;

# Eliminem els fitxers .holder ja que s'han copiat les carpetes.
echo Removing .holder files;
rm -v \$(find -name '.holder');
printf '# Disable default dns\n';
sudo systemctl stop systemd-resolved;
sudo systemctl disable systemd-resolved;


# Deploy first stack, which contains the core services: DHCP & DNS;
docker stack deploy --compose-file base_services.yml core;

printf \"updating resolv\n\";
printf \"domain $DOMAIN
search $DOMAIN
nameserver $IPL\n
nameserver 8.8.8.8
\" | sudo tee /etc/resolv.conf;


## Deploy the rest of services;
docker stack deploy -c docker-compose.sftp.yml sftp;
docker stack deploy -c docker-compose.web.yml web;
docker stack deploy -c docker-compose.mail.yml mail;
#docker stack deploy -c docker-compose.openfire.yml openfire;
docker stack deploy -c docker-compose.motioneye.yml motioneye;

watch docker service ls;
"

### Command end

ssh -p $SSHP $SSH -t $USERNAME@localhost "bash -c $CMD";