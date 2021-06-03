#!/bin/bash
#DESCARREGAR AQUEST FITXER A LA CARPETA DE DESCARREGAS

# bash ~/{Downloads,Baixades,Descargas}/checks_M11_UF1_samba.sh

#printf "\n" | smbclient -L router

printf "Carpetes disponibles:\n"

printf "\n" | smbclient -L router | tail +5 | head -n -2 | cut -f 2 | sed 's/  */ /g' | cut -d ' ' -f 1 | grep -v 'uploads'
printf "\n\n"

declare -a USERARR=('al1' 'al2' 'al3' 'prof1' 'prof2')

declare -a DIRARR=($(awk '{ gsub(","," "); gsub("  "," "); gsub(" ","\n"); print}' <<< "$(printf \"\\n\" | smbclient -L router | tail +5 | head -n -2 | cut -f 2 | sed 's/  */ /g' | cut -d ' ' -f 1 | grep -v 'uploads')"))

for user in "${USERARR[@]}" ;
do
  printf "User:\t$user\n\n"
  for folder in "${DIRARR[@]}";
  do
    printf "Folder:\t$folder\n"
    printf "a\nmkdir $user" | smbclient -U $user "//router/${folder}/" | grep -v "Enter WORKGROUP" | grep -v 'Try "help" to get a list of possible commands'
  done
  printf "\n\n\n"
done