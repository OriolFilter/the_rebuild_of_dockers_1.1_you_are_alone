#!/bin/bash
SCRIPTFOLDER="$(dirname $0)"
SSH="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o loglevel=ERROR -i CLAU"
SSHP="2222"
NAMEVM="MAINS-OFA"
USER="sjo"
STACK="stack"
FILESFOLDER="swarmfolder"


DOMAIN="OFA.itb"
IPL="10.10.6.1"

# Copiar files config

scp -P $SSHP $SSH  -r $SCRIPTFOLDER/$FILESFOLDER/ $USER@localhost:~

### Command start

CMD="echo 'zzzzzzzzzz';
printf '# Transferint e iniciant lscript de configuracio\n';
cd ./$FILESFOLDER/;
sudo apt-get update && sudo apt-get install -y git curl python3;
sudo curl -L \"https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)\" -o /usr/local/bin/docker-compose;
sudo chmod +x /usr/local/bin/docker-compose;
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
watch docker stack services $STACK;


echo 'POSTFIX';

docker run -d --name postfix-dovecot -p 2022:22 -p 25:25 -p 587:587 -p 110:110 -p 143:143 -v (pwd)/stack/postfix/mail:/var/mail -e  ROOT_PASSWORD=mypassword \
  -e HOSTNAME=mail.$DOMAIN -e DOMAINNAME=$DOMAIN  -e USERS=profe:chequejant,alumne:a classcat/postfix-dovecot

docker container exec -it (docker container ls | grep postfix_srv | cut -d ' ' -f 1) chmod 777 /var/mail -R;


echo '# INFO MESSAGE, COMMON ISSUE
To check if OCSP is the cause of the trouble disable it temporarily and retry to connect to your server.
Preferences -> Advanced -> Certificates -> Validation -> Uncheck Use the Online Certificate Status Protocol (OCSP) to confirm the current validity of certificates'


docker run -p -v $(pwd)/data:/data --name 'filterserver' -h 'carter.ofa.itb' -e 'HTTPS_PORT=4433' -t analogic/poste.io

http://unix.stackexchange.com/questions/123367/thunderbird-fails-to-connect-to-dovecot-and-postfix


"

### Command end

ssh -p $SSHP $SSH -t $USER@localhost "bash -c $CMD"
