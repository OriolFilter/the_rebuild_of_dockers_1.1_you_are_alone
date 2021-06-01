#!/bin/bash
SCRIPTFOLDER="$(dirname $0)"
SSH="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o loglevel=ERROR -i CLAU"
SSHP="2222"
NAMEVM="MAINS-OFA"
USERNAME="sjo"
STACK="stack"
FILESFOLDER="swarmfolder"


DOMAIN="OFA.itb"
IPL="10.10.6.1"

# Copiar files config

scp -P $SSHP $SSH  -r $SCRIPTFOLDER/$FILESFOLDER/ $USERNAME@localhost:~

### Command start

CMD="echo 'zzzzzzzzzz';
printf '# Transferint e iniciant lscript de configuracio\n';
cd ./$FILESFOLDER/;

docker stack deploy --compose-file docker-compose.yml $STACK;
echo docker stack deploy --compose-file docker-compose.yml $STACK;

printf '# Disable default dns\n';
sudo systemctl stop systemd-resolved;
sudo systemctl disable systemd-resolved;

printf \"updating resolv\n\";
printf \"domain $DOMAIN
search $DOMAIN
nameserver $IPL\n
nameserver 8.8.8.8
\" | sudo tee /etc/resolv.conf;

##docker stats;
watch docker stack services $STACK;"

### Command end

ssh -p $SSHP $SSH -t USERNAME@localhost "bash -c $CMD"
