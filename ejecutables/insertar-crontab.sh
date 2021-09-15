#$1 minuto
#$2 hora
#$3 ancho de banda ($3 = 3Mbit)
#$4 dirección mac
#$5 si es dinamico o estático ($4 = "ceil <MAX-BW>Mbit" | $4 = "")
while read -r linea
do
    IFS='='
    read -a parametros <<< "$linea"
    if [ ${parametros[0]} == "MAC1" ]; then MAC1=${parametros[1]}; fi
    if [ ${parametros[0]} == "MAC2" ]; then MAC2=${parametros[1]}; fi
    if [ ${parametros[0]} == "MAC3" ]; then MAC3=${parametros[1]}; fi
done < ../confs/MACS.conf

DEV=ens8
if [ $4 == $MAC1 ]; then
    echo "$1 $2 * * * /sbin/tc class change dev $DEV parent 1:1 classid 1:11 htb rate ${3}Kbit $5" #>> ruta.txt
fi
if [ $4 == $MAC2 ]; then
    echo "$1 $2 * * * /sbin/tc class change dev $DEV parent 1:1 classid 1:12 htb rate ${3}Kbit $5" #>> ruta.txt
fi
if [ $4 == $MAC3 ]; then
    echo "$1 $2 * * * /sbin/tc class change dev $DEV parent 1:1 classid 1:13 htb rate ${3}Kbit $5" #>> ruta.txt
fi