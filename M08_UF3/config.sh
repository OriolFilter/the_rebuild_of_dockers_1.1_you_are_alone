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
echo 'Pulling DNS and docker image';
docker pull sameersbn/bind;
docker pull networkboot/dhcpd;

cd ./$FILESFOLDER/;
printf '# Disable default dns\n';
sudo systemctl stop systemd-resolved;
sudo systemctl disable systemd-resolved;


docker stack deploy --compose-file base_services.yml $STACK;
echo docker stack deploy --compose-file base_services.yml $STACK;
watch docker stack ps $STACK;


printf \"updating resolv\n\";
printf \"domain $DOMAIN
search $DOMAIN
nameserver $IPL\n
nameserver 8.8.8.8
\" | sudo tee /etc/resolv.conf;

sudo apt-get update && sudo apt-get install -y git curl python3;
sudo curl -L \"https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)\" -o /usr/local/bin/docker-compose;
sudo chmod +x /usr/local/bin/docker-compose;

docker stack deploy -c docker-compose.mail.yml mail;

##docker stats;

echo '# INFO MESSAGE, COMMON ISSUE (thunderbird)
To check if OCSP is the cause of the trouble disable it temporarily and retry to connect to your server.
Preferences -> Advanced -> Certificates -> Validation -> Uncheck Use the Online Certificate Status Protocol (OCSP) to confirm the current validity of certificates'
"

### Command end

ssh -p $SSHP $SSH -t $USER@localhost "bash -c $CMD"

#docker container exec -it (docker container ls | grep postfix_srv | cut -d ' ' -f 1) chmod 777 /var/mail -R;
#docker run -e "ADMIN_USERNAME=root" -e "ADMIN_PASSWD=password" -e "DOMAIN_NAME=ofa.itb" -e "USERS=a:a,b:b"  \
#           -d -v /data/mysql:/var/lib/mysql -v /data/vmail/:/var/vmail -v /data/log:/var/log  \
#           -p 25:25 -p 80:80 -p 110:110 -p 143:143 -p 465:465 -p 993:993 -p 995:995 \
#           marooou/postfix-roundcube


