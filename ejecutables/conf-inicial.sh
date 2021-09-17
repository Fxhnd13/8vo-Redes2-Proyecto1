#Verificacion de dependencias
if ! command -v tc &> /dev/null
then
    echo "No se encuentra el comando tc instalado, instalelo e intente de nuevo."
    exit
fi	

if ! command -v iptables &> /dev/null
then
    echo "No se encuentra el comando iptables instalado, instalelo e intente de nuevo."
    exit
fi

if ! command -v crontab &> /dev/null
then
    echo "No se encuentra el comando crontab instalado, instalelo e intente de nuevo."
    exit
fi

#Configuración inicial iptables para rechazar TODA conexion de paquetes que no sea establecida
#en el archivo usuario_proto.conf
#Estas son politicas 
iptables -P INPUT DROP 
iptables -P FORWARD DROP
iptables -P OUTPUT DROP

#Configuración tc htb nodo raíz quien tendrá las clases hijas encargadas de regular el ancho
#de banda por mac
DEV=ens8 #Interfaz de debian que compartirá el enlace con los clientes 

#Leyendo las direcciones mac de los clientes
while read -r linea
do
    IFS='='
    read -a parametros <<< "$linea"
    if [ ${parametros[0]} == "MAC1" ]; then MAC1=${parametros[1]}; fi
    if [ ${parametros[0]} == "MAC2" ]; then MAC2=${parametros[1]}; fi
    if [ ${parametros[0]} == "MAC3" ]; then MAC3=${parametros[1]}; fi
done < ../confs/MACS.conf	

#No sé que hace esta linea, pero no tocar porque funciona
insmod sch_htb 2> /dev/null

#Creamos el nodo raíz con tc htb
tc qdisc add dev $DEV root handle 1: htb default 0xA

#Configuración tc htb nodos hojas
#Esta linea es utilizada (al concatenar con las de abajo) para matchear la mac en el filtrado
#de ancho de banda
TCF="tc filter add dev $DEV parent 1: protocol ip prio 5 u32 match u16 0x0800 0xFFFF at -2" //Esto es primordial para encontrar el protocolo ip ¿sólo ip? 

filter_mac() {
    M0=$(echo $1 | cut -d : -f 1)$(echo $1 | cut -d : -f 2)
    M1=$(echo $1 | cut -d : -f 3)$(echo $1 | cut -d : -f 4)
    M2=$(echo $1 | cut -d : -f 5)$(echo $1 | cut -d : -f 6)
    
    # mac aa:aa:aa:aa:aa:aa
    $TCF match u16 0x${M2} 0xFFFF at -4 match u32 0x${M0}${M1} 0xFFFFFFFF at -8 flowid $2 #matcheamos la mac si es origen
    $TCF match u32 0x${M1}${M2} 0xFFFFFFFF at -12 match u16 0x${M0} 0xFFFF at -14 flowid $2 #matcheamos la mac si es destino, probablemente esto no sea útil
} 

tc class add dev $DEV parent 1:1 classid 1:11 htb rate 0Mbit //para la modalidad estricta
tc class add dev $DEV parent 1:1 classid 1:12 htb rate 0Mbit //para la modalidad estricta
tc class add dev $DEV parent 1:1 classid 1:13 htb rate 0Mbit //para la modalidad estricta

filter_mac $MAC1 1:11      
filter_mac $MAC2 1:12      
filter_mac $MAC3 1:13      

echo "Se han finalizado las configuraciones predeterminadas iniciales..."
