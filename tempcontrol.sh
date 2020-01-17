#!/bin/bash
# ~/bin/tempcontrol.sh
# CREADO: 10/12/2019
# MODIFICADO: 16/01/2019
# Controla la temperatura del procesador de una Raspberry

## VERSIONES ##
# 'v1.2'
#  Opciones gestionadas con 'getopts'
#  Nuevas opciones [-r <TEMP>][-p][-h][-i]
#  Salidas de programa diferenciadas en normales o con orden de apagado o reinicio.
# 'v1.00'

## PENDIENTE ##
# Resumen total de uso de CPU, memoria y otros parámetros que puedan afectar o informar
# sobre consumo electríco y aumento de temperatura.
# Controlar que los archivos existen antes de intentar abrirlos

## POSIBLES MEJORAS ##
# OTROS CONTROLES:
# vcgencmd read_ring_osc -> Temperatura, voltaje y velocidad de procesador
# tvservice -l -> Info sobre salida de video
# AHORRO DE ENERGÍA:
# vcgencmd display_power 0 -> Apaga la salida de video.

## USO ##
CODIGO=$0

function usage {
    echo "Uso: ${CODIGO##*/} [hipt] [-l TEMP] [-s TEMP] [-r TEMP]"
    echo "  -h		Muestra la ayuda"
    echo "  -i		Muestra información sobre procesos y temperaturas"
    echo "  -l <TEMP>	Temperatura mínima a la que se anota en el log"
    echo "  -p		Muestra el registro de temperatura y la última ALERTA"
    echo "  -r <TEMP>	Reinicia el sistema al alcanzar la temperatura marcada"
    echo "  -s <TEMP>	Temperatura a la que se apaga la Rpis"
    echo "  -t		Imprime en pantalla la temperatura actual"
    echo "
Ejemplo:
  */3 * * * * /home/pi/bin/tempcontrol.sh -l 60 -s 80 -r 75>> /home/pi/logs/temp.log 2>&1
   El progama se ejecuta cada 3 minutos.
   Todos los valores superiores a 60 se guardarán en el archivo de registro.
   Si la temperatura del cpu supera los 80º se apaga el sistema.
   Si no llega a 80º, pero si supera los 75ª se reinicia la Rpi.
   El orden de los argumentos es muy importante para conseguir los resultados buscados."
    echo "
Ejemplo 2:
   tempcontrol.sh -tp -s 80 -r 70
   Muestra la temperatura actual del CPU, luego las últimas entradas del registro y
   por último reinicia o apaga el sistema dependiendo de la temperatura."
}

## VARIABLES ##
  file_LOG="$HOME/logs/temp.log"
  OUTPUT=`vcgencmd measure_temp`

  FECHA="$(date +'%F_%T')"
  let PUNTERO=${#OUTPUT}-6
  TEMPERATURA="${OUTPUT:PUNTERO:2}"
  REGISTRO="$FECHA -> $TEMPERATURA"
  REGISTROf="Temperatura Actual del procesador:\n$REGISTRO\n"
  dir_ALERTA="$HOME/logs/temp_alertas"
  file_ALERTA="$dir_ALERTA/$FECHA.log"
  file_ULTIMAALERTA=$(find /home/pi/logs/temp_alertas/ -type f -name "*.log" -print -quit | sort -r)

# Si la temperatura es superior al valor del argumento '-s <TEMP>'
# crea un log y guarda información de los procesos activos en ese momento.
# Por último apaga el equipo.
function alerta {
  printf "\nUSO DEL PROCESADOR:\n"
  ps aux k-pcpu | head -5
  printf "\nUSO DE MEMORIA:\n"
  ps aux k-pmem | head -5
  printf "\nUSO TOTAL DE MEMORIA\n"
  free
#  printf "\nConsumo total de recursos:\n"
#  ps --no-headers -u $USER -o pcpu,rss | awk '{cpu += $1; rss += $2} END {print cpu, rss}'
}

function imprimir_registro {
  printf "\n$file_LOG\nÚltimas registros por encima del límite:\n"
  tail -n 10 "$file_LOG"
}

function imprimir_alerta {
  printf "\nÚltima ALERTA:\n"
  cat $file_ULTIMAALERTA
}

function info {
  clear
  alerta
  imprimir_registro
  echo ""
  printf "$REGISTROf"
  printf "\nConsumo eléctrico:\n"
  vcgencmd measure_volts
}

# PARÁMETROS ##
while getopts hil:s:pr:t option
 do
    case "${option}"
    in
	h) usage;;
	i) info
	   exit 0;;
	l) [[ "$TEMPERATURA" -gt "${OPTARG[*]}" ]] && printf "$REGISTROf"
	   exit 0;;
	p) imprimir_registro
	   imprimir_alerta;;
	r) [[ "$TEMPERATURA" -gt "${OPTARG[*]}" ]] && echo "$REGISTRO" && echo -e "ALERTA:\n+ INFO en $file_ALERTA\n$( alerta )" >> "$file_ALERTA" && sudo shutdown -r && exit 2
	   exit 0;;
	s) [[ "$TEMPERATURA" -gt "${OPTARG[*]}" ]] && echo "$REGISTRO" && alerta >> "$file_ALERTA" && sudo shutdown -h && exit 3
	   exit 0;;
	t) vcgencmd read_ring_osc;;
	\?) echo "ERROR: argumento no a válido"
	    usage
	    exit 1;;
    esac
 done
