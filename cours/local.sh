

echo "
nameserver 127.0.0.1

nameserver 10.200.24.250
nameserver 8.8.8.8
" > "/etc/resolv.conf"
# nameserver 192.168.1.254
interface=$(ip route get 1 | awk '{print $5}')

ip addr add 10.200.24.250/24 dev $interface
