iptables -F 

iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT

tc qdisc del dev ens8 root

cat /dev/null > /var/spool/cron/crontabs/root
