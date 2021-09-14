iptables -F INPUT
iptables -F FORWARD
iptables -F OUTPUT

tc qdisc del dev interfaz root

cat /dev/null > <ruta crontab> 