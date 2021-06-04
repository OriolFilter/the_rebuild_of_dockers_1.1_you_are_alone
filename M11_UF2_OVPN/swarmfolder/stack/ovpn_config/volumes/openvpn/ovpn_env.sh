declare -x OVPN_AUTH=
declare -x OVPN_CIPHER=
declare -x OVPN_CLIENT_TO_CLIENT=
declare -x OVPN_CN=83.43.134.21
declare -x OVPN_COMP_LZO=0
declare -x OVPN_DEFROUTE=1
declare -x OVPN_DEVICE=tun
declare -x OVPN_DEVICEN=0
declare -x OVPN_DISABLE_PUSH_BLOCK_DNS=1
declare -x OVPN_DNS=1
declare -x OVPN_DNS_SERVERS=([0]="8.8.8.8" [1]="8.8.4.4")
declare -x OVPN_ENV=/etc/openvpn/ovpn_env.sh
declare -x OVPN_EXTRA_CLIENT_CONFIG=()
declare -x OVPN_EXTRA_SERVER_CONFIG=()
declare -x OVPN_FRAGMENT=
declare -x OVPN_KEEPALIVE='10 60'
declare -x OVPN_MTU=
declare -x OVPN_NAT=1
declare -x OVPN_PORT=1194
declare -x OVPN_PROTO=udp
declare -x OVPN_PUSH=()
declare -x OVPN_ROUTES=([0]="192.168.1.0/24")
declare -x OVPN_SERVER=192.168.255.0/24
declare -x OVPN_SERVER_URL=udp://83.43.134.21
declare -x OVPN_TLS_CIPHER=

#echo 0 > /proc/sys/net/ipv4/conf/tun0/rp_filter
echo 1 > /proc/sys/net/ipv4/conf/all/rp_filter
#echo 1 > /proc/sys/net/ipv4/conf/tun0/rp_filter
#sysctl -w net.ipv4.conf.all.rp_filter=0


iptables -A FORWARD -i tun0 -s 192.168.255.0/24 -d 192.168.1.1 -j ACCEPT
iptables -A FORWARD -i tun0 -s 192.168.255.0/24 -d 192.168.1.2 -j ACCEPT
iptables -A FORWARD -i tun0 -s 192.168.255.0/24 -d 192.168.1.70 -j ACCEPT
iptables -A FORWARD -i tun0 -s 192.168.255.0/24 -d 192.168.1.0/24 -j REJECT
#iptables -t nat -A POSTROUTING -s 192.168.255.0/24 -o eno2 -j MASQUERADE
#iptables -t nat -A POSTROUTING -s 192.168.255.0/24 -o eth0 -j MASQUERADE

#iptables -t nat -A POSTROUTING -s 192.168.255.0/24 -o eth0 -j MASQUERADE
#echo 0 > /proc/sys/net/ipv4/conf/tun0/rp_filter

#iptables -A POSTROUTING -s 192.168.255.0/24 -o eth0 -j MASQUERADE

#iptables -A FORWARD -i tun0 -j ACCEPT
#iptables -A FORWARD -i tun0 -o eth0 -m state --state RELATED,ESTABLISHED -j ACCEPT
#iptables -A FORWARD -i eth0 -o tun+ -j ACCEPT

#iptables -t nat -A POSTROUTING -s 192.168.255.0/24 -o eth0 -j MASQUERADE

eth='eth0'
proto='udp'
port=1194

# OpenVPN
iptables -A INPUT -i "$eth" -m state --state NEW -p "$proto" --dport "$port" -j ACCEPT

# Allow TUN interface connections to OpenVPN server
iptables -A INPUT -i tun+ -j ACCEPT

# Allow TUN interface connections to be forwarded through other interfaces
iptables -A FORWARD -i tun+ -j ACCEPT
iptables -A FORWARD -i tun+ -o "$eth" -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i "$eth" -o tun+ -m state --state RELATED,ESTABLISHED -j ACCEPT

# NAT the VPN client traffic to the internet
iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o "$eth" -j MASQUERADE
