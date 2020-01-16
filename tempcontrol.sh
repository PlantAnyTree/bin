#!/bin/bash
# ~/bin/tempcontrol.sh
# CREADO: 10/12/2019
# MODIFICADO: 16/01/2019
# Controla la temperatura del procesador de una Raspberry

# v1.0

## USO ##

INFO="La aplicación precisa de 1 o 2 parámetros.
  El primero, determina la temperatura límite de trabajo de la CPU. Una vez superada apaga automáticamente la raspberry. Debe ser superior a $MIN.
  El segundo parámetro determina a partir de que temperatura se muestra en pantalla la temperatura del procesador.
  Se puede crear un registro de temperaturas ejecutando el programa en el cron y direccionando la salida del programa a un archivo.

Ejemplo:
  */3 * * * * /home/pi/bin/tempcontrol.sh 80 60 >> /home/pi/logs/temp.log 2>&1
   El progama se ejecuta cada 3 minutos.
   Todos los valores superiores a 60 se guardarán en el archivo de registro.
   Si la temperatura del cpu supera los 80º se apagará el sistema.
"

## CONTROL ARGUMENTOS ##
# Valor mínimo de temperatura de apagado
MIN=60
# Validación del valor del primer argumento. Si no es superior a 60 muestra la 'INFO' y sale del programa.
[[ ! "$1" =~ ^[6-9][0-9]+$ ]] && printf "$INFO" && exit 1


## VARIABLES
FECHA="$(date +'%F_%T')"

# Registra el valor de la temperatura del CPU:
REGISTRO=`vcgencmd measure_temp`
# Limpia la cadena recibida y se queda con el valor numérico:
let PUNTERO=${#REGISTRO}-6
TEMPERATURA=${REGISTRO:PUNTERO:2}

## EXCESO DE TEMPERATURA ##
# Cuando la temperatura registrada supera el varlor del segundo argumento ($2) muestra el valor en pantalla.
#Se puede programar para que la salida se produzca en un archivo de control (ver INFO).
[[ $TEMPERATURA -gt $2 ]] && printf "$FECHA -> $REGISTRO\n"

# Si la temperatura es superior al primer argumento ($1),
# crea un log y guarda información de los procesos activos en ese momento.
# Por último apaga el equipo.
if [[ $TEMPERATURA -gt $1 ]]; then
  archivo_alertas="/home/pi/logs/temp_alertas/$FECHA.log"
  printf "ALERTA: + INFO EN $archivo_alertas\n"
  ps aux k-pcpu | head -5 >> ${archivo_alertas}
  ps aux k-pmem | head -5 >> ${archivo_alertas}
  sudo shutdown -h
fi
