#$1 tipo 0-2 (icmp, tcp/udp unico puerto, tcp/udp varios puertos)
#$2 PROTOCOLO
#$3 MAC
#$4 TIEMPO-INICIO
#$5 TIEMPO-FINAL
#$6 PUERTO INICIAL
#$7 PUERTO FINAL
while read -r linea
do
    IFS='='
    read -a parametros <<< "$linea"
    if [ ${parametros[0]} == "MAC1" ] && [ $3 == "MAC1" ]; then MAC=${parametros[1]}; fi
    if [ ${parametros[0]} == "MAC2" ] && [ $3 == "MAC2" ]; then MAC=${parametros[1]}; fi
    if [ ${parametros[0]} == "MAC3" ] && [ $3 == "MAC3" ]; then MAC=${parametros[1]}; fi
done < ../confs/MACS.conf

if [ $1 -eq 0 ]; then
    echo "iptables -I FORWARD 1 -p icmp -m mac --mac-source $MAC -m time --timestart $4 --timestop $5 -j ACCEPT"
    echo "iptables -I FORWARD 1 -p icmp -m state --state RELATED,ESTABLISHED -m time --timestart $4 --timestop $5 -j ACCEPT"
fi
if [ $1 -eq 1 ]; then
    echo "iptables -I FORWARD 1 -p $2 -m mac --mac-source $MAC -m $2 --dport $6:$7 -m time --timestart $4 --timestop $5 -j ACCEPT"
    echo "iptables -I FORWARD 1 -p $2 -m state --state RELATED,ESTABLISHED -m $2 --sport $6:$7 -m time --timestart $4 --timestop $5 -j ACCEPT"
fi
if [ $1 -eq 2 ]; then
    echo "iptables -I FORWARD 1 -p $2 -m mac --mac-source $MAC -m $2 --dport $6 -m time --timestart $4 --timestop $5 -j ACCEPT"
    echo "iptables -I FORWARD 1 -p $2 -m state --state RELATED,ESTABLISHED -m $2 --sport $6 -m time --timestart $4 --timestop $5 -j ACCEPT"
fi