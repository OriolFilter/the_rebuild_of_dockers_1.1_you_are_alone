#
server_ip="192.168.1.212"

declare -A port_dict=(["SFTP"]=23
["SMTP"]=25
["DNS"]=53
["HTTP"]=80
["POP3"]=110
["NETBIOS"]=139
["IMAP"]=143
["HTTPS"]=443
["SMB"]=445
["OPENMEETINGS"]=5443
["OPENFIRE"]=9090
["POSTGRESQL"]=5432
)

printf "ping al server amb IP $server_ip"
ping -c 4 $server_ip;

printf "Comprovant els ports oberts del servidor $server_ip"
for service in "${!port_dict[@]}"; do
    printf "Intent d'accedir al servei $service amb port ${port_dict[$service]}\n"
    nc -vz $server_ip ${port_dict[$service]}
    printf "\n"
done
