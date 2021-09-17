#LEYENDO EL ARCHIVO DE TEXTO ENLACE.CONF------------------------------------------------------
echo "Leyendo el archivo de texto enlace-----------------------------------------------------------------------------------------------------------------------"
while read -r linea
do
    IFS='='
    read -a parametros <<< "$linea"
    if [ ${parametros[0]} == "down" ]; then BWD=${parametros[1]}; fi #ancho de banda de bajada en Mbit
    if [ ${parametros[0]} == "up" ]; then BWU=${parametros[1]}; fi #ancho de banda de subida en Mbit
done < ../confs/enlace.conf
((BWG=(BWD+BWU)*1024)) #ancho de banda total (bajada y subida) en Kbit
echo "El ancho de banda total es de: ${BWG}Kbit"
echo

#LEYENDO EL ARCHIVO DE TEXTO MODO.CONF--------------------------------------------------------
echo "Leyendo el archivo de texto modo-------------------------------------------------------------------------------------------------------------------------"
while read -r linea
do
    IFS='='
    read -a parametros <<< "$linea"
    MODE=${parametros[1]}
done < ../confs/modo.conf
if [ $MODE -eq 1 ]; then echo "El modo de configuración es estricto."; fi
if [ $MODE -eq 2 ]; then echo "El modo de configuración es dinámico."; fi
echo

#LEYENDO EL ARCHIVO DE TEXTO USUARIO-BW.CONF-------------------------------------------------
echo "Leyendo el archivo de texto usuario-bw y escribiendo en crontab------------------------------------------------------------------------------------------"
if [ $MODE -eq 2 ]; then CEIL="ceil ${BWG}Kbit"; fi #Cadena que se agregará si es el modo dinámico
while read -r linea
do
  #echo "$linea" son 5 parametros, mac,bajada,subida,horainicio,horafin
    IFS=','
    read -a parametros <<< "$linea"
    BWDT=${parametros[1]}; #porcentaje de ancho de banda de bajada
    BWUT=${parametros[2]}; #porcentaje de ancho de banda de subida
    ((BWTT=(BWD*1024*BWDT/100)+(BWU*1024*BWUT/100))) #cantidad de ancho de banda a dar a la clase en Kbit
    IFS=":"
    read -a horarios_inicio <<< "${parametros[3]}" #Dividir 12:14 en 12 y 14
    read -a horarios_fin <<< "${parametros[4]}"
    IFS=""
    #Programar los cambios en el ancho de banda
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
      ./iptable-command.sh 0 icmp ${parametros[0]} ${parametros[2]} ${parametros[3]}
    fi

    if [ ${#parametros[@]} -eq 5 ]; then #Serian 5 parametros mac,protocolo,puerto(s),horainicio,horafin
      IFS=':'
      read -a puertos <<< "${parametros[2]}"
      IFS=""
      if [ ${#puertos[@]} -eq 2 ]; then
        ./iptable-command.sh 1 ${parametros[1]} ${parametros[0]} ${parametros[3]} ${parametros[4]} ${puertos[0]} ${puertos[1]}
      else 
        ./iptable-command.sh 1 ${parametros[1]} ${parametros[0]} ${parametros[3]} ${parametros[4]} ${parametros[2]}
      fi

    fi
done < ../confs/usuario_proto.conf
echo
