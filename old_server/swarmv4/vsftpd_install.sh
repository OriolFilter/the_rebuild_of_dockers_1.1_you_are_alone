#!/bin/bash

USERSFOLDER="$(dirname $0)/stack/users"

##### PAM

printf "
auth required pam_pwdfile.so pwdfile $USERSFOLDER/passwd
account required pam_permit.so" | sudo tee /etc/pam.d/vsftpd


SSLFOLDER="$(pwd)/$(dirname $0)/stack/cert_ssl"
USERLIST="$(pwd)/$(dirname $0)/user_list"
USERCONF="$(pwd)/$(dirname $0)/user_conf"

printf "
listen=YES
listen_ipv6=NO
max_per_ip=5
syslog_enable=YES


anonymous_enable=NO
dirmessage_enable=YES
ftpd_banner=Welcome to FTP server from domain OFA.itb

use_localtime=YES
xferlog_enable=YES
connect_from_port_20=YES

rsa_cert_file=$SSLFOLDER/servidor.crt
rsa_private_key_file=$SSLFOLDER/servidor.key

ssl_enable=YES
force_local_logins_ssl=YES

write_enable=NO
local_umask=333


chroot_local_user=YES
local_enable=YES
userlist_deny=NO
userlist_enable=YES
userlist_file=$USERLIST
user_config_dir=$USERCONF

" | sudo tee /etc/vsftpd.conf


sudo service vsftpd restart && sudo service vsftpd status
