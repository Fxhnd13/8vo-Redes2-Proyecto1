# Filtrado de paquetes a través de Sistema operativo debian, utilizando iptables y tc-htb

  En este proyecto se aceptarán 4 archivos de entrada (1 extra en el que irán escritas las direcciones MAC), después de esto, se generarán las reglas necesarias para
tener el control necesario sobre el filtrado de paquetes.

## Archivos .conf

### Archivo enlace.conf
  Este archivo definirá el ancho de banda que tendrán de subida y de bajada, su estructura estará definida por:

`down = <cantidad en Mbps>
up = <cantidad en Mbps>`

### Archivo modo.conf
  Este archivo definirá el modo en el que estará trabajando el ancho de banda, estará definido por la siguiente estructura:

`modalidad = <número que identifica al tipo de modalidad>`

Los tipos pueden ser:
* 1 = (fijo) de este modo el ancho de banda será únicamente el especificado, no más.
* 2 = (dinámico) de este modo el ancho de banda será como mínimo lo especificado o más.

### Archivo usuario_BW.conf
  Este archivo definirá la configuración por MAC del ancho de banda que tendrá cada equipo conectado, su estructura será:

`<MAC>,<BW bajada>,<BW subida>,<hora_inicio>,<hora_fin>`

* El formato de hora es siempre de 24 hrs.
* El ancho de banda se maneja en porcentaje un valor de 0 - 100

### Archivo usuario_Proto.conf
  Este archivo definirá la configuración por MAC del protocolo por el cual se enviará la información así como los puertos.

`<MAC>,<protocolo>,<puerto>,<hora_inicio>,<hora_fin>`

* Protocolo pueden ser: UDP, TCP y ICMP

## Archivos ejecutables

### conf-inicial.sh
  Este script debe ser el primero en ejecutarse, este da por sentado las politicas y restricciones iniciales que tendrá el sistema, creando las clases para cada
equipo cliente con un ancho de banda 0Kbit y denegando el envio de paquetes que no cumplan con ninguna regla.

### insertar-crontab.sh
  Este script será ejecutado dentro de otro, este programará tareas a horas específicas para que sean ejecutadas, y de esta forma cambiar el ancho de banda del que 
dispondra determinado cliente en determinado momento.

### limpieza.sh
  Este script deberá ser ejecutado cuando deseen eliminarse todas las politicas escritas en ejecuciones anteriores.
  
### exec.sh
  Este script es el que se encargará de leer los archivos conf de entrada para establecer las reglas y de esta forma filtrar los paquetes que se envien a través del
sistema operativo.
