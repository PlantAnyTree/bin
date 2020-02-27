#!/bin/bash
# ~/bin/pelis.sh
# CRE: 14/01/2020 v1.6

### PENDIENTE ###
# Sincronizar contenido. ¿Cómo?. No lo sé todavía.
# Actualizar aclaración de estatus de salida
# pelis.sh -x -> read no pausa a la espera de una respuesta.

## MEJORAS ##
# 'v2.0'
# Código depurado
# 'v1.91'
# Nuevas funciones de respaldo
# 'v1.9'
# Nueva renombra más eficientemente los fragmentos de películas divididas en videos más cortos.
# 'v1.8'
# Añadidas todas las opciones de pelisorden.sh
# 'v1.7'
# Añadidas funciones de manipulación de archivos '-v' y '-t'
# 'v1.6'
# Código depurado para su publicación en el 'wiki'.\\
# 'v1.5'
# Arreglado mensaje cuando no hay coincidencias en la búsqueda de películas.
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

## DEPENDENCIAS ##
# fdupes -> Para comprobar si ya existe el video y es exactamente igual.

## VARIABLES ##
# Ruta a videoteca
declare -r ruta_CINE="/var/media/Cine"
# Unidad donde están almacenadas los respaldos de las películas
declare -r ruta_RESPALDO="$HOME/cine"
# Ubicación de los logs
declare -r ruta_LOGS="$HOME/logs/cine"
# Directorio de los logs de las películas
declare -r dir_RESPALDO='respaldos'
# Archivo de registro de respaldos
declare -r archivo_LOG='lista_respaldos.log'
# Registro de películas repetidas
declare -r archivo_DUPES='duplicados.log'
# Retistro de respaldos
declare -r archivo_RESPALDO='respaldos.log'

# Ubicación del listado de duplicados
declare -r log_DUPES="$ruta_LOGS/$archivo_DUPES"
# Listado de las películas
declare -r log_LISTA="$ruta_LOGS/$archivo_LOG"
# Registro de respaldos
declare -r log_RESPALDO="$ruta_RESPALDO/$archivo_RESPALDO"

# Ubicación de los archivos resumen de los respaldos
declare -r ruta_ARCHIVOS="$ruta_LOGS/$dir_RESPALDO/"

declare -ir fecha_INICIO=$(date +%s)
declare -r fecha_INICIO_F=$(date +%c)

# Películas de las que buscar duplicados
declare -a arr_DUPES="[dual] [es] [lat] [VDE] [VO]"
# Grupos de películas donde buscar duplicados
declare -a arr_GRUPOS="[dual] [es] [lat] [VDE] [VO] [VOSE]"
# Extensiones de video para crear directorios con el arguento '-t'
declare -a arr_VIDEOS=( avi mpg mkv mpeg mp4 flv xvid )
# Extensiones de archivos a conservar al mover los datos
declare -a arr_EXTENSIONES=( -poster.jpg poster.jpg -fanart.jpg .es.srt .en.srt .spa.srt .eng.srt .nfo .txt -front.jpg front.jpg 1.jpg .jpg .jpeg )
# Grupos a buscar por películas actualizadas
declare -a arr_ACTUALIZADAS="[VDE] [VO] [VOSE]"

# Archivos a eliminar
declare -r -a arr_ELIMINAR=( 'RARBG.to.nfo' 'TuMejorTorrent.url' 'www.DIVXATOPE.com.url' 'TUmejorTorrent.url' 'CompucaliTV.url'
'Descargas torrent Gratis Serieshd,Peliculas hd - pctnew.org.URL' 'httptumejortorrent.com.url' 'divxatope1.url'
'Importante leer !!!!!.txt' 'www.newpct1.com.url' 'www.newpct.com.url' 'DESCARGAS2020.url' 'TorrentRapid.url'
'Tumejortorrent.url' 'Descargas torrent Gratis Serieshd,Peliculas hd - Descargas2020.org.website' 'NewPct1.url'  'NEWPCT.url'
'TorrentLocura.url' 'DivxATope.url' )


## TEXTOS ##
declare -r txt_ALMOHADILLAS="#########"
declare -r txt_SEPARADOR="------------------------------------------------------------------------------------------"
declare -r txt_INICIO="Listado $(date +%F)"

## SALIDAS EXIT ##
# 2 -> 'Error en los argumentos'
# 3 -> 'No se encuentra la videoteca'
# 4 -> 'No se encuentra el respaldo'


## FUNCIONES ##
# USAGE #
CODIGO=$0

function f_usage {
    echo "uso: ${CODIGO##*/} [-b CADENA] [-c][-d][-h][-l][-t] [-o <origen>] [-p <pelicula>] [-a <año>] [-e <etiquetas>] [-g <grupo>]"
    echo "  -a <cadena>  año de estreno de la película"
    echo "  -b <cadena>  busca películas coincidentes con la cadena en la lista de respaldo."
    echo "  -c           compara el listado con los archivos del disco (duplicados.log)"
    echo "  -d           muestra el uso de disco de las películas"
    echo "  -e <cadena>  etiquetas identificativas del archivo a añadir al nombre."
    echo "  -g <cadena>  grupo donde se va a archivar la película"
    echo "  -h           muestra la ayuda"
    echo "  -i <cadena>  recupera películas desde el respaldo (Respaldo -> Videoteca)"
    echo "  -l           genera lista de respaldos (lista_respaldos.log)"
    echo "  -o <cadena>  archivo de video o directorio con la película que se va a clasificar"
    echo "  -p <cadena>  nombre de la película"
    echo "  -r <cadena>  respaldar videoteca"
    echo "  -s <cadena>  nombra los archivos del directorio en orden con -part1, -part2, part3..."
    echo "  -t           crea directorios para todos los archivos de video y los mete dentro"
    echo "  -x		 Busca duplicados de películas duales en otros grupos para su eliminación"
    echo "
Ejemplos:
$CODIGO -b '(2001)'     -> Muestra las películas de 2001.
$CODIGO -d              -> Muestra el uso de disco de la videoteca.
$CODIGO -h              -> Muestra esta ayuda
$CODIGO -o <video>      -> Crea un directorio del mismo nombre del video y lo mete dentro
$CODIGO -o ./dir_con_pelicula -p \"Nombre de la pelicula\" -a 1998 -e \"Drip 1080p\" -g dual
$CODIGO -r <grupo>	-> Copia de seguridad del grupo
"
}

function f_control {
 [[ -d $ruta_CINE ]] || echo "Videoteca no localizada"; EXIT 4
 [[ -d $ruta_RESPALDO ]] && echo "Unidad de respaldos localizada y montada" || echo "No se pueden realizar respaldos."
}

function f_control_grupo {
  [[ ! -d "$dir_origen" ]]  && echo "No existe el grupo de origen: $dir_origen"  && exit 2
  [[ ! -d "$dir_destino" ]] && echo "No existe el grupo de destino: $dir_destino" && exit 3
}

function f_tiempo_pasado {
  local segundos=$(($(date +%s)-$fecha_INICIO))
  local minutos=$((segundos/60))
  local resto=$(($segundos-($minutos*60)))
  echo "$fecha_INICIO_F"
  echo "$minutos m. $resto s."
}

# No estoy usando esta función. Puede necesitar alguna actualización.
function r_lee_diffs {
  find "$ruta_LOGS"/ -type f -iname "*log" -exec cat {} +
}

# Lista de películas ya respaldadas:
function f_respaldo_cine {
  while read peli
    do
        dir_pelicula="${peli##*/}"
        respaldo="$dir_destino/$dir_pelicula"
        if [[ -d $respaldo ]]; then
          ls -ahQs1 "$respaldo" | tail -n +4 > "$ruta_LOGS/temp/_bak.log"
          ls -ahQs1 "$peli" | tail -n +4 > "$ruta_LOGS/temp/_ori.log"
#          if [[  $(diff -q "$ruta_LOGS/temp/_bak.log" "$ruta_LOGS/temp/_ori.log") ]]; then
	  if diff -q "$ruta_LOGS/temp/_bak.log" "$ruta_LOGS/temp/_ori.log" > /dev/null ; then
            printf "\n$txt_ALMOHADILLAS $dir_pelicula $txt_ALMOHADILLAS\n$peli\n" > "$ruta_LOGS/diffs/$dir_pelicula.log"
            echo "$respaldo" | cat "$ruta_LOGS/temp/_ori.log" - "$ruta_LOGS/temp/_bak.log" >> "$ruta_LOGS/diffs/$dir_pelicula.log"
          fi

        # Si no existe el directorio de la pélicula...
        # Muestro los datos del video y lo copio en el destino.
        # Por último calculo el tiempo transcurrido si todo ha ido bien.
        else
          f_eliminar_basura
          printf "\n$txt_ALMOHADILLAS $dir_pelicula $txt_ALMOHADILLAS\n"
          du -h "$peli"
          cp -brv "$peli" -t "$dir_destino"
          [[ $? ]] && f_tiempo_pasado; exit 0 || echo "$txt_ALMOHADILLAS Error copiando archivos $txt_ALMOHADILLAS" && tiempo_pasado && exit 1
        fi
    done < <(find "$dir_origen" -maxdepth 1 -mindepth 1 -type d | sort)
    echo "Todos los respaldos al día en $dir_origen"
}

function f_estructura_logs {
  [[ -d '$ruta_ARCHIVOS' ]] || mkdir -p "$ruta_ARCHIVOS"
}

function f_archivar_todo () {
  while read peli
    do
      local ext=${peli##*.}
      for fin in "${arr_VIDEOS[@]}"
        do
          if [[ "$fin" == "$ext" ]]; then  f_archivo "${peli##*/}"; fi
        done
    done < <(find ./ -maxdepth 1 -type f | sort)
}

function f_archivo () {
  local dir_origen="${1%.*}"
  mkdir "$dir_origen"
  mv -vb "${1}" -t "$dir_origen"/
}

function f_dual {
  declare -r dir_actualizados="/home/pi/cine"
  declare -r dir_actualizados2="/var/media/Cine"
  while read peli
   do
    pelif=${peli##*/}
    f_buscar_actualizada "$dir_actualizados"
    f_buscar_actualizada "$dir_actualizados2"
   done < <(find "$dir_actualizados/[dual]" -maxdepth 1 -type d | sort )
}

function f_buscar_actualizada {
    for grupo in $arr_ACTUALIZADAS
     do
      while read actualizado
       do
        f_peli_actualizada "$actualizado"
       done < <(find "$1/$grupo/" -iname "$pelif" | sort )
     done
}

function f_peli_actualizada {
    read -p "¿Eliminar película obsoleta? Si/no: " read_OBSOLETA
    read_obsoleta=${read_OBSOLETA:=si}
    obsoleta=${read_obsoleta,,}
    [[ "$obsoleta" == "si" ]] && echo "aquí borro el duplicado: $1"
}

# Recorre cada grupo de la videoteca buscando directorios con películas (arr_DUPES)
# Busca en los respaldos archivos de video con el mismo nombre que los directorios de la videoteca
# Copia el nombre de los archivos encontrados en la lista 'duplicados.log'
function f_dupes {
  [[ ! -d $ruta_CINE ]] && echo "Sin acceso a la videoteca" && exit 3 || echo "Accediendo a la videoteca"
  [[ ! -d $ruta_RESPALDO ]] && echo "Respaldos no localizados" && exit 4 || echo "Accediendo a los respaldos"
  declare -i i=0
  echo $(date +%F) > $log_DUPES
  for dir in $arr_DUPES
  do
    while read peli
     do
       pelif=${peli##*/}
       if [[ $i -eq 0 ]]
       then
         echo "Escaneando videoteca: $pelif" # El primer resultado es el directorio principal
         echo "$txt_ALMOHADILLAS $pelif $txt_ALMOHADILLAS" >> $log_DUPES
       else
         while read file
         do
            peso=$(stat -c '%s' "$file" | numfmt --to=iec)
            echo "$peso: $dir / $pelif" >> $log_DUPES
         done < <(find $ruta_RESPALDO -type f -iname "${pelif}*" | sort)
       fi
       i=1
     done < <(find "$ruta_CINE/$dir" -maxdepth 1 -type d | sort )
     i=0
  done
}

function f_lista {
  echo "$txt_INICIO" > "$log_LISTA"
  for grupo in $arr_GRUPOS
    do
      while read peli
        do
          pelif=${peli##*/}
          if [[ $i -eq 0 ]]; then
            echo "Directorio de búsqueda: $pelif"
#           directorio="$pelif"
            echo $txt_SEPARADOR >> "$log_LISTA"
            echo "$txt_ALMOHADILLAS $grupo $txt_ALMOHADILLAS" >> "$log_LISTA"
          else
            echo "$pelif" >> "$log_LISTA"
            ls -Qsh "$peli" > "$ruta_ARCHIVOS$dir/$pelif.log"
          fi
        i=1
    done < <(find "$ruta_RESPALDO/$grupo" -maxdepth 1 -type d | sort | uniq)
    i=0
  done
}

function f_uso_disco {
 sudo du -h -d 1 $ruta_CINE
}

function f_buscar_dupes {
    read -p "¿Buscar archivos duplicados? Si/no: " read_dupes
    dupes=${read_dupes:=si}
    dupes=${read_dupes,,}
    [[ "$dupes" == "si" ]] && fdupes -rd "$dir_origen" "$dir_pelicula"
}

function f_eliminar_basura {
  for basura in "${arr_ELIMINAR[@]}"
    do
      [[ -f "$dir_origen$basura" ]] && rm -v -- "$dir_origen$basura"
    done
}

function f_conservar_subdirectorios {
  find "$dir_origen"  -mindepth 1 -maxdepth 1 -type d -exec mv -b -t "$dir_pelicula"/ {} \;
}

# Si no se añade el argumento 'readarray -t' la salida de cada elemento del array lleva al final de la línea unos caracteres que impide que se pueda seleccionar el achivo para renaombrarlo.
# mv: no se puede efectuar `stat' sobre 'nombre_del_archivo.avi'$'\n': No existe el fichero o el directorio
function f_mover_archivos {
  for ext in "${arr_VIDEOS[@]}"
    do
      declare -a array
      readarray -t array < <(find "$dir_origen" -maxdepth 1 -type f -iname "*.$ext" | sort)
      [[ ${#array[@]} -eq 1 ]] && mv -vb "${array[0]}" "${dir_pelicula}/${pelicula}.${ext}"
      if [[ ${#array[@]} -gt 1 ]]; then
        declare post=-part
        declare -i i=1
	for elemento in "${array[@]}"; do
	  mv -vb "$elemento" "${dir_pelicula}/${pelicula}${post}${i}.${ext}"
	  ((i++))
	done
      fi
    done
}

function f_mover_otros_archivos {
  local portada=front
  find "$dir_origen" -maxdepth 1 -type f -iname "*${portada}.jpg" -exec mv -b -- {} "$dir_pelicula/${pelicula}.jpg" \;
  for extension in "${arr_EXTENSIONES[@]}"
    do
      find "$dir_origen" -maxdepth 1 -type f -iname "*$extension" -exec mv -b -- {} "$dir_pelicula/$pelicula$extension" \;
    done
}

function f_pelis {
  [ -f "$opt_origen" ] && f_archivo "$opt_origen" && exit 0 || dir_origen="$opt_origen"
  dir_pelicula="${opt_pelicula:-${dir_origen}}${opt_anyo:+ (${opt_anyo})}"
  etiquetas="${opt_etiquetas:+$opt_etiquetas}${opt_grupo:+$opt_grupo}"
  pelicula="$dir_pelicula${etiquetas:+ $etiquetas}"
  [ -n "$opt_grupo" ] && dir_pelicula="$ruta_CINE/$opt_grupo/$dir_pelicula"

  if [[ ! -d "$dir_pelicula" ]]
    then
      mkdir -v "$dir_pelicula"
    else
      echo "El directorio de destino ya existe: $dir_pelicula"
      ls -ahl "$dir_pelicula"
      f_buscar_dupes
      read -p "¿Continuar moviendo el archivo $pelicula en este directorio? Si/no: " read_continuar
      continuar=${read_continuar,,}
      [[ "$continuar" == "no" ]] && exit 2
    fi
}

## PARÁMETROS ##
while getopts :cdhlstxa:b:e:g:i:o:p:r: option
  do
    case "${option}"
    in
      a) opt_anyo=$OPTARG;;
      b) grep -i "${OPTARG[*]}" $log_LISTA || echo "No hay resultados."
        exit 0;;
      c) f_dupes
        wait $!
        echo "cat $log_DUPES"
        cat "$log_DUPES"
        exit 0;;
      d) f_uso_disco
        exit 0;;
      e) opt_etiquetas=$(printf '[%s]' ${OPTARG[*]});;
      g) opt_grupo="[$OPTARG]";;
      h) f_usage
	exit 0;;
      i) dir_origen="$ruta_RESPALDO/[$OPTARG]"
         dir_destino="$ruta_CINE/[$OPTARG]"
	 f_control_grupo
	 f_eliminar_basura
	 f_respaldo_cine
	 exit 0;;
      l) f_lista
        exit 0;;
      o) opt_origen=${OPTARG};;
      p) opt_pelicula="${OPTARG%/*}";;
      r) dir_destino="$ruta_RESPALDO/[$OPTARG]"
         dir_origen="$ruta_CINE/[$OPTARG]"
         f_control_grupo
         f_eliminar_basura
         f_respaldo_cine
	 exit 0;;
      s) opt_split=true;;
      t) f_archivar_todo
        exit 0;;
      x) f_dual
	exit 0;;
      \?) echo "ERROR: argumento no aceptado en este programa"
        f_usage
	exit 2;;
      :) echo "ERROR: no se recibió el argumento correctamente"
	f_usage
	exit 2;;
    esac
  done

[[ -z $1 ]] && echo "ERROR: al menos debes elegir el directorio de origen u otras opciones." && f_usage && exit 2
# [[ -v 1 ]] && echo "ERROR: al menos debes elegir el directorio de origen u otras opciones." && f_usage && exit 2

  f_pelis
  f_eliminar_basura
  f_conservar_subdirectorios
  f_mover_archivos
  f_mover_otros_archivos
  rmdir -v "$dir_origen"
  ls -ahl "$dir_pelicula"

