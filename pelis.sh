#!/bin/bash
# ~/bin/pelis.sh
# CRE: 14/01/2020
# v1.41

### PENDIENTE ###
# Crear un menú para eliminar duplicados
# Sincronizar contenido

### USOS ###
## LISTADOS ##
# '-l' -> Crea una lista de mis películas de respaldo.
# Crea un archivo por cada película con el nombre del archivo de video y su tamaño.
## COPIAS - Versión de test ##
# '-c' -> Recorre la colección de películas y busca coincidencias en la lista de películas de respaldo.
## BÚSQUEDA ##
# '-b' -> Busca películas en la lista de películas de respaldo con una 'cadena'.
# Para buscar fechas o cadenas con espacios se debe entrecomillar 'pelis.sh -b "(1998)"'
## USO DE DISCO ##
# '-d' -> Muestra la cantidad de espacio de disco usada por las películas.
## AYUDA ##
# '-h' -> Muestra la ayuda del programa con las distintas opciones
# '-s' -> Sincroniza la videoteca con el disco de respaldo. Voy a hacer uso del comando diff
## TEST ##
# '-t' -> Código de prueba para proóximos desarrollos.

## MEJORAS ##
# 'v1.5'
# Mejora en el formato del registro de duplicados: 'function dupes{}'
# 'v1.4'
# Mejora en la presentación y explicación del código.
# Crea un listado con duplicados en el disco de respaldo de las películas de ciertos directorios: '[dual]' '[es]' y '[lat]'
# 'v1.3'
# Manejo de parámetros con opciones de búsqueda, comparación, listados y ayuda.
# Diferentes opciones de uso ordenadas en funciones.
# 'v1.2'
# Modificadas rutas a películas y logs para hacer el código más fácil.
# Arreglado el condicional para la opción de búsqueda de cadenas en el resgistro de películas.
# 'v1.1'
# Añadida función de búsqueda de cadenas en el registro existente.
# Al añadir cualquier parámetro realiza la búsqueda y sale sin hacer un listado o registros nuevos.
# 'v1.0'
# Si no existen los directorios donde se guardan los registros, se crean.

## VARIABLES ##
# Unidad donde están almacenadas los respaldos de las películas
ruta_PELIS="$HOME/cine"
# Directorio de los logs de las películas
dir_CINE='cine'
# Ubicación de los logs
ruta_LOGS="$HOME/logs"
# Archivo de registro de respaldos
file_LOG='pelis.log'
# Grupos de películas donde buscar duplicados
arr_GRUPOS="[dual] [es] [lat] [VDE] [VO] [VOSE]"

# Registro de películas repetidas
file_DUPES='duplicados.log'
# Ruta a disco principal
ruta_CINE="/var/media/Cine"
# Películas de las que buscar duplicados
arr_DUPES="[dual] [es] [lat] [VDE] [VO]"
# Ubicación del listado de duplicados
log_DUPES="$ruta_LOGS/$file_DUPES"

# Listado de las películas
log_LISTA="$ruta_LOGS/$file_LOG"
# Ubicación de los archivos resumen de los respaldos
ruta_ARCHIVOS="$ruta_LOGS/$dir_CINE/"

## TEXTOS ##
txt_ALMOHADILLAS="#########"
txt_SEPARADOR="------------------------------------------------------------------------------------------"
txt_INICIO="Listado $(date +%F)"

i=0

CODIGO=$0

function usage {
    echo "uso: ${CODIGO##*/} [-b CADENA] [-c][-d][-h][-l][-s][-t]"
    echo "  -b CADENA   busca películas coincidentes con la cadena"
    echo "  -c      compara el listado con los archivos del disco"
    echo "  -d      muestra el uso de disco de las películas"
    echo "  -h      muestra la ayuda"
    echo "  -l      genera nuevos listados"
    echo "  -s      sincroniza la videoteca con el disco de respaldo"
    echo "  -t      función de test"
    exit 1
}

function sincronizar {
 echo "sincronizando"
}

function dupes {
# Elimino el registro anterior
rm "$log_DUPES"

# Recorrido por los grupos
for dir in $arr_DUPES
do
 while read peli
 do
  pelif=${peli##*/}
  if [[ $i -eq 0 ]]
   then
     echo "Directorio de búsqueda: $pelif" # El primer resultado es el directorio principal
     directorio="$pelif"
   else
#        grep "$pelif" "$log_LISTA" >> $log_DUPES
	while read file
	do
            peso=$(stat -c '%s' "$file" | numfmt --to=iec)
            echo "$peso: $dir / $pelif" >> $log_DUPES
	done < <(find $ruta_PELIS -type f -iname "${pelif}*" | sort)
   fi
  i=1
 done < <(find "$ruta_CINE/$dir" -maxdepth 1 -type d | sort | uniq)
i=0
done
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

while getopts b:cdhlst option
do
case "${option}"
in
b) grep -i "${OPTARG[*]}" $log_LISTA && wait $! && exit 0;;
c) dupes
   wait $!
   cat "$log_DUPES"
   exit 0;;
d) uso_disco
   exit 0;;
h) usage;;
l) listados
   exit 0;;
s) sincronizar
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
