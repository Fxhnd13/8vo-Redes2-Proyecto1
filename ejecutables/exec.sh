#LEYENDO EL ARCHIVO DE TEXTO ENLACE.CONF------------------------------------------------------
echo "Leyendo el archivo de texto enlace-----------------------------------------------------------------------------------------------------------------------"
while read -r linea
do
    IFS='='
    read -a parametros <<< "$linea"
    if [ ${parametros[0]} == "down" ]; then BWD=${parametros[1]}; fi
    if [ ${parametros[0]} == "up" ]; then BWU=${parametros[1]}; fi
done < ../confs/enlace.conf
((BWG=(BWD+BWU)*1024))
echo "El ancho de banda total es de: ${BWG}Kbit"
echo

#LEYENDO EL ARCHIVO DE TEXTO MODO.CONF--------------------------------------------------------
echo "Leyendo el archivo de texto modo-------------------------------------------------------------------------------------------------------------------------"
while read -r linea
do
  #echo "$linea"
    IFS='='
    read -a parametros <<< "$linea"
    MODE=${parametros[1]}
done < ../confs/modo.conf
if [ $MODE -eq 1 ]; then echo "El modo de configuración es estricto."; fi
if [ $MODE -eq 2 ]; then echo "El modo de configuración es dinámico."; fi
echo

#LEYENDO EL ARCHIVO DE TEXTO USUARIO-BW.CONF-------------------------------------------------
echo "Leyendo el archivo de texto usuario-bw y escribiendo en crontab------------------------------------------------------------------------------------------"
if [ $MODE -eq 2 ]; then CEIL="ceil ${BWG}Kbit"; fi
while read -r linea
do
  #echo "$linea" son 5 parametros, mac,bajada,subida,horainicio,horafin
    IFS=','
    read -a parametros <<< "$linea"
    #ancho de banda total
    BWDT=${parametros[1]};
    BWUT=${parametros[2]};
    ((BWTT=(BWD*1024*BWDT/100)+(BWU*1024*BWUT/100)))
    IFS=":"
    read -a horarios_inicio <<< "${parametros[3]}"
    read -a horarios_fin <<< "${parametros[4]}"
    IFS=""
    ./insertar-crontab.sh ${horarios_inicio[1]} ${horarios_inicio[0]} $BWTT ${parametros[0]} $CEIL
    ./insertar-crontab.sh ${horarios_fin[1]} ${horarios_fin[0]} 0 ${parametros[0]}
done < ../confs/usuario_bw.conf
echo

#LEYENDO EL ARCHIVO DE TEXTO USUARIO-PROTO.CONF-----------------------------------------------
echo "Leyendo el archivo de texto usuario-proto---------------------------------------------------------------------------------------------------------------"
while read -r linea
do
    IFS=','
    read -a parametros <<< "$linea"

    if [ ${#parametros[@]} -eq 4 ]; then #Serian 4 parametros mac,protocolo,horainicio,horafin
      echo "iptables -A INPUT -p ${parametros[1]} -m --mac-address ${parametros[0]} -m time --timestart ${parametros[2]} --timestop ${parametros[3]} -j ACCEPT"
      echo "iptables -A FORWARD -p ${parametros[1]} -m --mac-address ${parametros[0]} -m time --timestart ${parametros[2]} --timestop ${parametros[3]} -j ACCEPT"
      echo "iptables -A OUTPUT -p ${parametros[1]} -m --mac-address ${parametros[0]} -m time --timestart ${parametros[2]} --timestop ${parametros[3]} -j ACCEPT"
    fi

    if [ ${#parametros[@]} -eq 5 ]; then #Serian 5 parametros mac,protocolo,puerto(s),horainicio,horafin
      IFS=':'
      read -a puertos <<< "${parametros[2]}"
      if [ ${#puertos[@]} -eq 2 ]; then
        echo "iptables -A INPUT -p ${parametros[1]} -m --mac-address ${parametros[0]} --sport ${puertos[0]}:${puertos[1]} --dport ${puertos[0]}:${puertos[1]} -m time --timestart ${parametros[3]} --timestop ${parametros[4]} -j ACCEPT"
        echo "iptables -A FORWARD -p ${parametros[1]} -m --mac-address ${parametros[0]} --sport ${puertos[0]}:${puertos[1]} --dport ${puertos[0]}:${puertos[1]} -m time --timestart ${parametros[3]} --timestop ${parametros[4]} -j ACCEPT"
        echo "iptables -A OUTPUT -p ${parametros[1]} -m --mac-address ${parametros[0]} --sport ${puertos[0]}:${puertos[1]} --dport ${puertos[0]}:${puertos[1]} -m time --timestart ${parametros[3]} --timestop ${parametros[4]} -j ACCEPT"
      else 
        echo "iptables -A INPUT -p ${parametros[1]} -m --mac-address ${parametros[0]} --sport ${parametros[2]} --dport ${parametros[2]} -m time --timestart ${parametros[3]} --timestop ${parametros[4]} -j ACCEPT"
        echo "iptables -A FORWARD -p ${parametros[1]} -m --mac-address ${parametros[0]} --sport ${parametros[2]} --dport ${parametros[2]} -m time --timestart ${parametros[3]} --timestop ${parametros[4]} -j ACCEPT"
        echo "iptables -A OUTPUT -p ${parametros[1]} -m --mac-address ${parametros[0]} --sport ${parametros[2]} --dport ${parametros[2]} -m time --timestart ${parametros[3]} --timestop ${parametros[4]} -j ACCEPT"
      fi
    fi
done < ../confs/usuario_proto.conf
echo