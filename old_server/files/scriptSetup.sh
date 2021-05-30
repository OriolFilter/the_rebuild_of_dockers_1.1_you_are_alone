#!/bin/bash

# VARS
FILESFOLDER="./files"

## Bind
BINDFOLDERCFG="$FILESFOLDER/bind"
BINDFOLDERSERVER="/etc/bind"

# Dhcp

ISCFOLDERCFG="$FILESFOLDER/dhcp"
ISCFOLDERSERVER="/etc/dhcp"

# Apache

APACHEFOLDERCFG="$FILESFOLDER/apache2"
APACHEFOLDERSERVER="/etc/apache2"

#WEBFOLDERSERVER="/var/serverwebs"
WEBFOLDERSERVER="/var/www/serverwebs"

#
#FTPFOLDERCFG="$FILESFOLDER/apache2"   # ??
FTPFOLDERSERVER="/etc/vsftpd"
FTPCONFIGFILESERVER="/etc/vsftpd.conf"


sudo apt-get update # bruh
#sudo apt-get upgrade


# Netplan, esta configurat a l'script VBoxManager.sh
#sudo apt install netplan
#sudo mv ./$FILESFOLDER/netplan.yaml /etc/dhcpd/dhcpd.conf

# DHCP

sudo apt-get install isc-dhcp-server --fix-missing -y
sudo mv $ISCFOLDERCFG/dhcpd.conf $ISCFOLDERSERVER/dhcpd.conf
echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf
#sudo sysctl -p /etc/sysctl.conf
sudo service isc-dhcp-server stop
sudo service isc-dhcp-server start


# DNS

#sudo apt-get install bind9  --fix-missing -y
#sudo mv $BINDFOLDERCFG/* $BINDFOLDERSERVER
#sudo service bind9 stop && sudo service bind9 start


# Resolv
sudo mv $FILESFOLDER/resolv.conf /etc/resolv.conf


## WEB
#
#
#sudo apt-get install apache2 --fix-missing -y
#
## Moure fitxers i crear carpetes
#
#sudo mkdir $WEBFOLDERSERVER && echo "S'ha creat la carpeta de pagines web" || echo "Hi ha hagut un error durant la creacio de la carpeta de pagines web"
#sudo mkdir $APACHEFOLDERSERVER/ssl && echo "S'ha creat la carpeta dels certificats SSL" || echo "Hi ha hagut un error durant la creacio de la carpeta dels certificats SSL"
#
#
#sudo mv $APACHEFOLDERCFG/webcontent/* $WEBFOLDERSERVER/
#sudo mv $APACHEFOLDERCFG/sites-available/* $APACHEFOLDERSERVER/sites-available/
#sudo mv $APACHEFOLDERCFG/ssl/* $APACHEFOLDERSERVER/ssl/
#
#
##Desactivar Default i Activar webs
#
#sudo a2dissite 000-default.conf
#sudo a2dissite default-ssl
#sudo a2ensite web11.conf
#sudo a2ensite web22.conf
#
#
##sudo mkdir /var/www/serverwebs/web11/credentials
#
## Activar el modul d'autenticacio de grup mitjancant un fitxer
#
#sudo a2enmod authz_groupfile
#sudo a2enmod info
#sudo a2enmod status
#sudo a2enmod ssl
#
#sudo service apache2 stop && sudo service apache2 start
#
#
#
## vsftpd
#
#
#
#sudo apt-get install vsftpd --fix-missing -y
#
#sudo mkdir $FTPFOLDERSERVER
#
#printf "### Config File for vsftpd service \"$FTPCONFIGFILESERVER\"
#
#listen=YES
#listen_ipv6=NO
#max_per_ip=5
#syslog_enable=YES
#
#
#anonymous_enable=NO
#dirmessage_enable=YES
#ftpd_banner=Welcome to FTP server from domain OFA.itb
#
#use_localtime=YES
#xferlog_enable=YES
#connect_from_port_20=YES
#
#rsa_cert_file=/etc/apache2/ssl/servidor.crt
#rsa_private_key_file=/etc/apache2/ssl/servidor.key
#
#ssl_enable=YES
#force_local_logins_ssl=YES
#
#write_enable=NO
#local_umask=333
#
#
#chroot_local_user=YES
#local_enable=YES
#userlist_deny=NO
#userlist_enable=YES
#userlist_file=/etc/vsftpd/user_list
#user_config_dir=/etc/vsftpd/user_conf
#
#
#" | sudo tee $FTPCONFIGFILESERVER
#
#
#sudo service vsftpd stop && sudo service vsftpd start
#
##printf "prof\n" | sudo tee /etc/vsftpd/user_list
#
#
#
## Create users
#
##echo "chequejant
##chequejant
##
##
##y" | sudo adduser prof &> /dev/null && echo "S'ha creat lusuari prof" ||  echo "No s'ha pogut creat lusuari prof"
#
#printf "prof:x:1500:1500:,,y,:/tmp:/bin/bash\n" | sudo tee -a /etc/passwd
##printf "prof:$6$9zTD.1tN$EBWj2mSBzSmu2vdxaeFa/MX1VOPWhU8BfSEj.Z8KNAtlYCBZmXGgDpyRHuq6UEpQdSomp2xnxIqeTfKxajp8d0:18590:0:99999:7:::\n" | sudo tee -a /etc/shadow
#printf "prof:$6$UmUNVbLg$atOuJhndVxWtoYEVdqTJMokKwRtOX4xV1Q1b.T10HVlnw7eddHy22PkZGwKD1bR9YR.SmMYf5K1/z18lFfj2q0:18590:0:99999:7:::\n" | sudo tee -a /etc/shadow
#printf "prof:x:1500:" | sudo tee -a /etc/group
#
## Create user file config for vsftpd
#
#sudo mkdir $FTPFOLDERSERVER/user_conf
#
#printf "chroot_enable=YES
#local_root=/var/www/serverwebs
#write_enable=YES
#local_umask=002\n" | sudo tee $FTPFOLDERSERVER/user_conf/prof
#
#
##echo "chequejant
##chequejant" | sudo htpasswd -c $FTPFOLDERSERVER/ftp.passwd profe
#
#sudo mkdir $WEBFOLDERSERVER/web22/modificacions
#
#
#sudo service vsftpd restart
