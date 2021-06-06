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


echo 'Pulling required images to speed up a little';
#docker pull sameersbn/bind;
#docker pull networkboot/dhcpd;
#docker pull classcat/postfix-dovecot;

cd ./$FILESFOLDER/;

# Eliminem els fitxers .holder ja que s'han copiat les carpetes.
echo Removing .holder files;
rm -v \$(find -name '.holder');
printf '# Disable default dns\n';
#sudo systemctl stop systemd-resolved;
#sudo systemctl disable systemd-resolved;


# Deploy first stack, which contains the core services: DHCP & DNS;
#docker stack deploy --compose-file base_services.yml core;

printf \"updating resolv\n\";
printf \"domain $DOMAIN
search $DOMAIN
nameserver $IPL
nameserver 8.8.8.8
\" | sudo tee /etc/resolv.conf;


export INTERACTIVE=\"no\"
export PRIVATE_SUBNET=\"10.6.0.0/24\"
export SERVER_HOST=\"192.168.1.117\"
export SERVER_PORT=\"51820\"
export CLIENT_DNS=\"8.8.8.8,8.8.4.4\"

## Deploy the rest of services;

"
#watch docker service ls;

#sudo apt-get  update  && sudo apt-get  -y install  python3 git
#sudo apt-get  update  && sudo apt-get  -y install  python3 git
#sudo  curl -L \"https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)\" -o /usr/local/bin/docker-compose
#sudo  chmod +x /usr/local/bin/docker-compose
### Command end
ssh -p $SSHP $SSH -t $USERNAME@localhost "bash -c $CMD";

#
#echo "
#export INTERACTIVE='no';
#export PRIVATE_SUBNET='10.6.0.0/24'
#export SERVER_HOST='192.168.1.117';
#export SERVER_PORT='51820';
#export CLIENT_DNS='8.8.8.8,8.8.4.4';" > /tmp/cmd
##sudo su < 'bash /tmp/cmd';
##"
##
#scp -P $SSHP $SSH  -r /tmp/cmd $USERNAME@localhost:/tmp/cmd
#ssh -p $SSHP $SSH -t $USERNAME@localhost "cat /tmp/cmd | sudo bash";
