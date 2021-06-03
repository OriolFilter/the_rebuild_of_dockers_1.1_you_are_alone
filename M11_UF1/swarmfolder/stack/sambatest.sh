declare -a USERARR=('al1' 'al2' 'al3' 'prof1' 'prof2')

SAMBAOUTPUT=printf "\n" | smbclient -L router | tail +5 | head -n -2 | cut -f 2 | sed 's/  */ /g' | cut -d ' ' -f 1,3
declare -a DIRARR="$(printf $SAMBAOUTPUT | cut -d ' ' -f 1)"
declare -a DIRNAMEARR="$(printf $SAMBAOUTPUT | cut -d ' ' -f 2)"



for (( i=0; i<${USERARR}; i++ ));
do
  printf "User:\t${USERARR[$i]}\n"
  for (( d=0; d<${USERARR}; d++ ));
  do
    printf "Folder:\t${USERARR[$d]}\t\t(${$DIRNAMEARR[$d]})\n"
    printf "a\nmkdir folder" | smbclient -U prof2 '//router/shared/'

  done
done