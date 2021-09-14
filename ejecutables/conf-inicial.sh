#$1 BWG
#$2 MODE

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

#Configuración inicial iptables
iptables -P INPUT REJECT
iptables -P FORWARD REJECT
iptables -P OUTPUT REJECT

#Configuración tc htb nodo raíz
BWG=5Mbit #Podriamos decir que es el ancho de banda general que tendrá, en este caso 5 mb (bajada y subida)
DEV=ens8 #Interfaz de debian que compartirá el enlace

MAC1=<mac> //direcciones mac de los clientes
MAC2=<mac> //direcciones mac de los clientes
MAC3=<mac> //direcciones mac de los clientes	

insmod sch_htb 2> /dev/null
tc qdisc add dev $DEV root handle 1: htb default 0xA

#Configuración tc htb nodos hojas
TCF="tc filter add dev $DEV parent 1: protocol ip prio 5 u32 match u16 0x0800 0xFFFF at -2" //Esto es primordial para encontrar el protocolo ip ¿sólo ip? 

filter_mac() {
    M0=$(echo $1 | cut -d : -f 1)$(echo $1 | cut -d : -f 2)
    M1=$(echo $1 | cut -d : -f 3)$(echo $1 | cut -d : -f 4)
    M2=$(echo $1 | cut -d : -f 5)$(echo $1 | cut -d : -f 6)
    $TCF match u16 0x${M2} 0xFFFF at -4 match u32 0x${M0}${M1} 0xFFFFFFFF at -8 flowid $2
    $TCF match u32 0x${M1}${M2} 0xFFFFFFFF at -12 match u16 0x${M0} 0xFFFF at -14 flowid $2
} 

tc class add dev $DEV parent 1:1 classid 1:11 htb rate 0Mbit //para la modalidad estricta
tc class add dev $DEV parent 1:1 classid 1:12 htb rate 0Mbit //para la modalidad dinamica (usamos el total establecido en el doc enlace.conf)
tc class add dev $DEV parent 1:1 classid 1:13 htb rate 0Mbit //para la modalidad estricta

filter_mac $MAC1 1:11      
filter_mac $MAC2 1:12      
filter_mac $MAC3 1:13      

echo "Se han finalizado las configuraciones predeterminadas iniciales..."