#!/bin/bash
# ~/bin/pelis.sh
# CRE: 14/01/2020
# v1.1

### PENDIENTE ###
# Guardar el resultado de la búsqueda en un array y mostrarlo en pantalla con la opción de ver más detalles de los resultados
# mostrando el nombre y tamaño de la película.
# Poder mostrar resultados de búsqueda en los dos listados para comprobar coincidencias

### USO ###
# Crea una lista de mi colección de películas
# Recorre los subdirectorios del array 'GRUPOS'
# Crea un archivo por cada película con el nombre del archivo de video y su tamaño.
# Busca cadenas en el registro de películas. Si se busca una fecha hay que ponerlo entre comillas pelisbacklog.sh "(1998)"

## MEJORAS ##
# v1.1
# Añadida función de búsqueda de cadenas en el registro existente.
# Al añadir cualquier parámetro realiza la búsqueda y sale sin hacer un listado o registros nuevos.
# v1.0
# Si no existen los directorios donde se guardan los registros, se crean.

## VARIABLES ##
# Unidad donde están almacenadas las películas
ruta_RAIZ='/home/pi'
# Directorio raiz de las películas
dir_CINE='cine'
# Ubicación de los logs
dir_LOGS='logs'
# Archivo de registro
file_LOG='pelis.log'
# Grupos de películas (subdirectorios)
arr_GRUPOS="[dual] [es] [lat] [VDE] [VO] [VOSE]"


# Ubicación de las películas
ruta_DIRECTORIO="$ruta_RAIZ/$dir_CINE/"
# Listado de las películas
log_LISTA="$ruta_RAIZ/$dir_LOGS/$file_LOG"
# Ubicación de los archivos resumen de las películas
ruta_ARCHIVOS="$ruta_RAIZ/$dir_LOGS/$dir_CINE/"

## TEXTOS ##
txt_ALMOHADILLAS="#########"
txt_SEPARADOR="------------------------------------------------------------------------------------------"
txt_INICIO="Listado $(date +%F)"

## CONTROL ##
# [[ -z "$1" ]] || echo "$1"
# [[ -z "$@" ]] || echo "$@"
# [[ -z "$@" ]] || grep $1 $log_LISTA
# [[ -z "$@" ]] || export GREP_OPTIONS='--color=auto' GREP_COLOR='333;2' && grep "$1" $log_LISTA
[[ -z "$@" ]] || grep -i "${*}" $log_LISTA && wait $! && exit 0

i=0

## Si no existen los directorios donde se guardan los registros los creo ##
[[ -d '$ruta_ARCHIVOS' ]] || mkdir -p "$ruta_ARCHIVOS"

## CÓDIGO ##

# Comienzo del registro
echo "$txt_INICIO" > "$log_LISTA"

# Recorrido por los grupos
for dir in $arr_GRUPOS
do
 while read peli
 do
  pelif=${peli##*/}
  if [[ $i -eq 0 ]]
   then
     echo "Directorio de búsqueda: $pelif" # El primer resultado es el directorio principal
     directorio="$pelif"
     # Comienzo el registro eliminando las entradas anteriores y escribiendo una linea de separación.
     echo $txt_SEPARADOR >> "$log_LISTA"
     echo "$txt_ALMOHADILLAS $dir $txt_ALMOHADILLAS" >> "$log_LISTA"
   else
	echo "$pelif" >> "$log_LISTA"
	ls -Qsh "$peli" > "$ruta_ARCHIVOS$dir.$pelif.log"
   fi
  i=1
 done < <(find "$ruta_DIRECTORIO$dir" -maxdepth 1 -type d | sort | uniq)
i=0
done
