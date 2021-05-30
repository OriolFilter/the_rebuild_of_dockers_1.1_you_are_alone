#!/bin/bash
FOLDER=$(dirname $0)
SERVERKEYFOLDER="/etc/ssh/"
DOCKERKEYFOLDER="./stack/key_ssh/"

sudo rm /etc/ssh/ssh_host_*
sudo dpkg-reconfigure openssh-server
sudo cp $SERVERKEYFOLDER/ssh_host_* $DOCKERKEYFOLDER
sudo chmod 755 stack/key_ssh -R
