#!/bin/bash
FOLDER=$(dirname $0)
SERVERKEYFOLDER="/etc/ssh/"
DOCKERKEYFOLDER="./stack/key_ssh/"

sudo rm /etc/ssh/ssh_host_*
sudo cp $DOCKERKEYFOLDER/ssh_host_* $SERVERKEYFOLDER/
sudo chmod 755 stack/key_ssh -R
