#!/bin/bash
# ~/bin/pelis.sh
# CRE: 14/01/2020
# v1.3

### PENDIENTE ###
# Crear un listado para el disco de respaldo (listo)
# Leer el disco principal 'seagate 5TB' y por cada película hacer una búsqueda en el listado anterior. (de momento con fechas de estreno)
# Si encuentra una coincidencia copia el nombre de la película en un nuevo archivo.

### USO ###
# Crea una lista de mi colección de películas
# Recorre los subdirectorios del array 'GRUPOS'
# Crea un archivo por cada película con el nombre del archivo de video y su tamaño.
# Busca cadenas en el registro de películas. Si se busca una fecha hay que ponerlo entre comillas 'pelis.sh -b "(1998)"'

## MEJORAS ##
# v1.3
# Manejo de parámetros con opciones de búsqueda, comparación, listados y ayuda.
# Diferentes opciones de uso ordenadas en funciones.
# v1.2
# Modificadas rutas a películas y logs para hacer el código más fácil.
# Arreglado el condicional para la opción de búsqueda de cadenas en el resgistro de películas.
# v1.1
# Añadida función de búsqueda de cadenas en el registro existente.
# Al añadir cualquier parámetro realiza la búsqueda y sale sin hacer un listado o registros nuevos.
# v1.0
# Si no existen los directorios donde se guardan los registros, se crean.

## VARIABLES ##
# Unidad donde están almacenadas las películas
ruta_PELIS="$HOME/cine"
# Directorio raiz de las películas
dir_CINE='cine'
# Ubicación de los logs
ruta_LOGS="$HOME/logs"
# Archivo de registro
file_LOG='pelis.log'
# Grupos de películas (subdirectorios)
arr_GRUPOS="[dual] [es] [lat] [VDE] [VO] [VOSE]"


# Listado de las películas
log_LISTA="$ruta_LOGS/$file_LOG"
# Ubicación de los archivos resumen de las películas
ruta_ARCHIVOS="$ruta_LOGS/$dir_CINE/"

## TEXTOS ##
txt_ALMOHADILLAS="#########"
txt_SEPARADOR="------------------------------------------------------------------------------------------"
txt_INICIO="Listado $(date +%F)"

i=0

CODIGO=$0

function usage {
    echo "uso: ${CODIGO##*/} [-clht] [-b CADENA]"
    echo "  -c      compara el listado con los archivos del disco"
    echo "  -d      muestra el uso de disco de las películas"
    echo "  -l      genera nuevos listados"
    echo "  -h      muestra la ayuda"
    echo "  -t      función de test"
    echo "  -b CADENA   busca películas coincidentes con la cadena"
    exit 1
}

function uso_disco {
 sudo du -h -d1 $ruta_PELIS
}

function listados {
  crea_estructura_logs
  # Comienzo del registro
  echo "$txt_INICIO" > "$log_LISTA"
# Comienzo del registro
echo "$txt_INICIO" > "$log_LISTA"

# Recorrido por los grupos
for dir in $arr_GRUPOS
do
 while read peli
 do
#  wc -c "$peli" | awk '{print ($1)}'
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
 done < <(find "$ruta_PELIS/$dir" -maxdepth 1 -type d | sort | uniq)
i=0
done
}

function crea_estructura_logs {
  # Si no existen los directorios donde se guardan los registros los creo.
  [[ -d '$ruta_ARCHIVOS' ]] || mkdir -p "$ruta_ARCHIVOS"
}

function test {
# Código de testeo sobre tratamiento de cadenas
# Explorando la posibilidad de añadir la información de tamaño de los archivos o directorios.
for dir in $arr_GRUPOS
do
 while read peli
 do
  echo "$peli" | awk '{print ($1)}'
  anyo="${peli##*\ }"
  pelicula="${peli##*/}"
  titulo="${pelicula%\ *}"
  echo "titulo: $titulo"
  echo "año: $anyo"
  pelif=
  echo $peli | cut -d' ' -f1
  echo $peli | cut -d' ' -f2
  echo $peli | cut -d' ' -f3
  vars=( $peli )
  echo "Number of words in vars: '${#vars[@]}'"
  echo ${vars[0]}
  echo ${vars[1]}
  echo ${vars[2]}

#  wc -c "$peli" | awk '{print ($1)}'

 done < <(du -h -d1 "$ruta_PELIS/$dir" | sort)
i=0
done
}

## PARÁMETROS ##

while getopts b:cdhlt option
do
case "${option}"
in
b) grep -i "${OPTARG[*]}" $log_LISTA && wait $! && exit 0;;
c) COMPARAR=1
   exit 0;;
d) uso_disco
   exit 0;;
h) usage;;
l) listados
   exit 0;;
t) test
   exit 0;;
\?) echo "ERROR: argumento no aceptado en este programa"
   usage;;
esac
done

echo "ERROR: argumento no aceptado en este programa"
usage
exit 1
