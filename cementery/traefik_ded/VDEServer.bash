#!/bin/bash
# Server
SWITCHSERVER1="serverSwitch"
PORT=1
LPORT=9000

vde_switch -d -s /tmp/$SWITCHSERVER1 -M /tmp/$SWITCHSERVER1.mngmt &> /dev/null || printf "No s'ha pogut crear el switch, es possible que ja existeixi un document amb aquest nom\n" && printf "S'ha creat el switch\n" | # Crear switch

if [[ "$1" -eq 1 ]]; then # 0 is NO fer DPIPE, 1 ES fer DPIPE
	printf "S'ha iniciat el server amb el port $LPORT\n"  && dpipe vde_plug -p $PORT /tmp/$SWITCHSERVER1 = nc -l -u -p $LPORT && printf "S'ha finaliztat iniciar el server switch VDE\n"
fi 
