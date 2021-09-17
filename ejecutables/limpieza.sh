iptables -F 
iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT

tc qdisc del dev interfaz root

cat /dev/null > <ruta crontab>