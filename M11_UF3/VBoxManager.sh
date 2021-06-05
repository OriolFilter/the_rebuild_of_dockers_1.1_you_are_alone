#!/bin/bash

# Script VirtualBox
#
# Configuració de variables
#

SCRIPTFOLDER="$(dirname $0)"
echo $SCRIPTFOLDER
cd $SCRIPTFOLDER
PART2SCRIPT="config.sh"

SSHFILE="CLAU"
SSH="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o loglevel=ERROR -i $SSHFILE"

# VBOX
NAMEVM="MAINS-OFA" #Name Virtual Machine
RAMM=6144 # 2GB
#VMF="$1" # Virtual Machine File
VMF="../UbuSrvDockerNFS.vdi" # Virtual Machine File
echo $VMF
# Maquina

IPL="10.10.6.254" #IP local
IPL="10.10.6.1" #IP local
IPLN="10.10.6.0" #IP local NETWORK/24, podria fer una variable per la xarxa
IPDMZ="192.168.254.1" #IP DMZ
IPDMZN="192.168.254.0" #IP DMZ/24
USER='sjo'

# SSH
SSHP=2222


# Mostrar Config

printf "~~~~~~\ :$NAMEVM:
~~~~~~\ $RAMM MB RAM
~~~~~~\ $VMF HDD
~~~~~~\ $IPL/24
~~~~~~\ $SSHP port SSH
" 
# ~~~~~~\ $DGVM: Gateway (DISABLED)

## Neteja
rm CLAU


# Administrar VBox

# Comprovar si existeix una màquina amb el nom designat, en cas de que existeixi preguntar si es vol borrar

if VBoxManage list vms | grep -q "$NAMEVM" ; then # Si existeix una màquina amb el mateix nom preguntem si volem borrar
	printf "Ja existeix una màquina amb el nom seleccionat, vols substituïr-la? (y/n)";read -e RESP
	if [[ "$RESP" == "y" ]] || [[ "$RESP" == "s" ]] ; then
		VBoxManage controlvm "$NAMEVM" poweroff # Apaga, per si està en us
		sleep 1 # Espera un segon
		VBoxManage unregistervm --delete "$NAMEVM"
		sleep 1
	else
		exit
	fi
fi
VBoxManage createvm --name "$NAMEVM" -register --ostype "Ubuntu_64" # Creem una entrada ubuntu_64 bits
VBoxManage storagectl "$NAMEVM" --name jgdiscos --add ide # Afegim un port de HDD
VBoxManage storageattach "$NAMEVM" --storagectl jgdiscos --port 0 --device 0 --type hdd --medium "$VMF" --mtype immutable # Afegim HDD


vbTUNEJOS="--memory $RAMM --vram 32 --pae on --hwvirtex on --boot1 disk --audio none --accelerate3d on --usb off " # Variable Holder 1

vbNICS="--nic1 nat --nictype1 virtio --nic2 intnet --nic3 intnet"
VBoxManage modifyvm "$NAMEVM" --ostype "Ubuntu_64" --ioapic off $vbTUNEJOS $vbNICS --natpf1 "guestssh,tcp,,$SSHP,,22" # Port forwarding Virtualbox
VBoxManage modifyvm "$NAMEVM" --ostype "Ubuntu_64" --ioapic off $vbTUNEJOS $vbNICS --natpf1 "ovpn,udp,,1194,,1194" # Port forwarding Virtualbox
# Create DMZ NETWORK

# Iniciar maquina virtual sense finestra (headless)

VBoxManage startvm "$NAMEVM" --type headless

# Generar claus SSH sense contrasenya

rm -v CLAU* # per eliminar fitxers ja existents i evitar conflictes
ssh-keygen -N "" -f CLAU # Genera una clau SSH,  -N 'CONTRASENYA' en aquest cas està buida  -f Fitxer de destí
WORKED=1 # Variable que mantindrà el bucle obert
until [ "$WORKED" = "0" ] ; do
	printf "·" # sí, es una dieresi
	ssh-copy-id -p $SSHP $SSH.pub $USER@localhost # Registra la clau generada
	WORKED="$?" # Retorna 1 si ha fallat l'anterior comanda, 0 si ha funcionat correctament
	sleep 1
done

printf '\n'


# Creem un fitxer que li afegirem una comanda per a ser executada posteriorment, FINAL s'utilitza per a marcar un punt d'inici i un de fi, no entenc perque no estem fent servir una variable i ja, no hi ha necessitat de fer servir un fitxer no?
cat << FINAL >/tmp/cmd
echo "$USER ALL=(ALL) NOPASSWD: ALL" | sudo EDITOR='tee -a' visudo
FINAL
# FINAL, no es pot ficar res a la mateixa linea de FINAL per tancar, sinó compta com una linea més i per tant no queda tancat

scp -P $SSHP $SSH  /tmp/cmd $USER@localhost:/home/$USER/cmd  # Ara mateix amb scp estem copiant un fitxer del nostre equip, al equip servidor, utilitzant un usuari del sistema servidor, en aquest cas com volem accedir a una màquina virtual, que està sent hostejada per el nostre sistema, i hem ficat que escolti al port  2222, utilitzarem @localhost com a adreça del sistema servidor, també podria utilitzar-se 127.0.0.1 (sempre que estigui ben configurat el sistema)
ssh -p $SSHP $SSH -t $USER@localhost "bash /home/$USER/cmd" # Connectant-se al mateix servidor i al mateix usuari d'abans, executarem el fitxer que hem mogut al servidor, amb la comanda creada anteriorment
# NOTA, crec que podem iniciar amb cualsevol usuari, no ens ha demanat crear cap en cap moment


# NETWORKING


# Generar el fitxer de xarxa, tindre en compte que es un 'yaml' al igual que python s'ha de respectar els caracters d'espai, si s'utilitzar la mateixa formatació (espais o tabuladors) per les columnes germanes

cat << FINAL > /tmp/netplan.yaml
# This file describes the network interfaces available on your system
# For more information, see netplan(5).
network:
  version: 2
  renderer: networkd
  ethernets:
    enp0s3:
      dhcp4: yes
      dhcp6: no
    enp0s8:
      dhcp4: no
      dhcp6: no
      addresses: [$IPDMZ/24]
      nameservers:
        addresses: [127.0.0.1,8.8.4.4]
    enp0s9:
      dhcp4: no
      dhcp6: no
      addresses: [$IPL/24]
      nameservers:
        addresses: [127.0.0.1,8.8.4.4]
FINAL

scp -P $SSHP $SSH /tmp/netplan.yaml $USER@localhost:/home/$USER # Copiem al servidor el fitxer creat

CMD="ls ;
sudo hostname '$NAMEVM';
sudo hostnamectl set-hostname '$NAMEVM' ;
sudo cp /home/$USER/netplan.yaml /etc/netplan/01-netcfg.yaml ;
sudo netplan apply;
" # Hem guardat una serie de comandes dins una variable
echo preSPC
ssh -p $SSHP $SSH -t $USER@localhost "bash -c $CMD" # Executem la variable creada
echo postSPC


# Modificar IP de xarxa/IP forwarding (iptables)

cat << "FINAL" > /tmp/cmd
#cat $0
sudo bash -c 'echo 1 > /proc/sys/net/ipv4/ip_forward'
sudo iptables -A FORWARD -j ACCEPT
sudo iptables -t nat -A POSTROUTING -s 10.10.6.0/24 -o enp0s3 -j MASQUERADE

FINAL
# Hem guardat comandes dins del cmd

scp -P $SSHP $SSH  /tmp/cmd "$USER@localhost:/home/$USER/cmd" # Movem el fitxer de comandes al servidor
ssh -p $SSHP $SSH -t $USER@localhost bash "/home/$USER/cmd" # Executem el fitxer de comandes al servidor



echo ssh -p $SSHP $SSH -t $USER@localhost "$CMD"
ssh -p $SSHP $SSH -t $USER@localhost "$CMD"

cat << "FINAL" > /tmp/cmd
echo "127.0.0.1 localhost
127.0.1.1 $hostname

# The following lines are desirable for IPv6 capable hosts
::1     localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters" | sudo tee /etc/hosts;
FINAL
# Hem guardat comandes dins del cmd

scp -P $SSHP "$SSH"  /tmp/cmd "$USER@localhost:/home/$USER/cmd" # Movem el fitxer de comandes al servidor
ssh -p $SSHP "$SSH" -t "$USER@localhost" "bash /home/$USER/cmd" # Executem el fitxer de comandes al servidor



### Docker, modificar

echo "##############################Adaptem la xarxa xq no coincideixi amb la de VBox"
CMD="ls ;
sudo systemctl stop docker.service ;
"
ssh -p $SSHP $SSH -t $USER@localhost "bash -c $CMD"
cat << FINAL >/tmp/daemon.json
{
  "default-address-pools":
  [
  {"base":"10.66.0.0/16","size":24}
  ]
}
FINAL
scp -P $SSHP $SSH  /tmp/daemon.json $USER@localhost:/home/$USER/daemon.json
CMD="ls ;
sudo cp /home/$USER/daemon.json /etc/docker/daemon.json;
sudo systemctl start docker.service ;
"
ssh -p $SSHP $SSH -t $USER@localhost "bash -c $CMD"

echo "##############################Cració de docker swarm"

## Swarm INIT

ssh -p $SSHP $SSH -t $USER@localhost "docker swarm init --advertise-addr $IPL --default-addr-pool 10.77.0.0/16 --default-addr-pool-mask-length 24" # Iniciar swarm

# Executar config.sh

./$PART2SCRIPT

