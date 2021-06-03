#!/bin/bash
#DESCARREGAR AQUEST FITXER I EXECUTARLO

printf "\n" | smbclient -L router

declare -a USERARR=('al1' 'al2' 'al3' 'prof1' 'prof2')

printf "\n" | smbclient -L router | tail +5 | head -n -2 | cut -f 2 | sed 's/  */ /g' | cut -d ' ' -f 1

declare -a DIRARR=($(awk '{ gsub(","," "); gsub("  "," "); gsub(" ","\n"); print}' <<< "$(printf \"\\n\" | smbclient -L router | tail +5 | head -n -2 | cut -f 2 | sed 's/  */ /g' | cut -d ' ' -f 1 | grep -v 'uploads')"))

for user in "${USERARR[@]}" ;
do
  printf "User:\t$user\n\n"
  for folder in "${DIRARR[@]}";
  do
    printf "Folder:\t$folder\t\t$user\n"
    printf "a\nmkdir $user" | smbclient -U $user "//router/${folder}/" | grep -v "Enter WORKGROUP" | grep -v 'Try "help" to get a list of possible commands'
  done
  printf "\n\n\n"
done