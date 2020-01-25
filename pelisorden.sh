#!/bin/bash
# ~/bin/pelisorden.sh
# CREADO: 22/01/2020
# v1.0

## CONFIGURACIÓN ##
RUTA_CINE="/var/media/Cine"
# Archivos a eliminar
declare -a A_ELIMINAR=( 'TuMejorTorrent.url' 'www.DIVXATOPE.com.url' 'TUmejorTorrent.url' 'CompucaliTV.url'
'Descargas torrent Gratis Serieshd,Peliculas hd - pctnew.org.URL' 'httptumejortorrent.com.url'
'Importante leer !!!!!.txt' 'www.newpct1.com.url' 'www.newpct.com.url' 'DESCARGAS2020.url' 'TorrentRapid.url'
'Tumejortorrent.url' 'Descargas torrent Gratis Serieshd,Peliculas hd - Descargas2020.org.website' )
# Extensiones de archivos de video
declare -a A_VIDEOS=( avi mpg mpeg mkv mp4 )
# Extensiones de otros archivos a conservar
declare -a A_EXTENSIONES=( .avi .mpg .mpeg .mkv .mp4 -poster.jpg -fanart.jpg .es.srt .en.srt .spa.srt .eng.srt .nfo .txt )

CODIGO=$0
function usage () {
  echo "Uso: $CODIGO [-h] [-a] [-f <archivo>] [-o <origen>] [-p <nombre de la pelicula>] [-a <año de estreno>] [-e <etiquetas>] [-t <target>]"
  echo "  -a			Crear directorios para todos los archivos de vídeo"
  echo "  -h			Ayuda"
  echo "  -f  <archivo>		Crea un directorio donde se mete el video"
  echo "  -o  <origen>		Archivo de la película o directorio que la contiene"
  echo "  -p  <pelicula>	Nombre de la película, puede contener el año entre paréntesis"
  echo "  -y  <year>		Año del estreno de la película"
  echo "  -e  <etiquetas>	Etiquetas con info sobre el formato y contenido de la película, entre comillas y separadas por espacios"
  echo "  -g  <grupo>		Mueve la película al directorio del grupo asignado"
  echo "
Ejemplos:
  $CODIGO -a		->  Crea directorios para todos los archivos del directorio actual.
  $CODIGO -f <archivo>	->  Crea un directorio del mismo nombre del archivo sin extensión y guarda el video en el.
  $CODIGO -o <directorio> -e <etiquetas> -t <dual> -> El vídeo se encuentra en un directorio con el nombre de la película y el año de estreno
  $CODIGO -o "Ya_no_puedo_mas.mkv" -p "Ya no puedo más" -y 2015 -e "Brip 1080p" -t es
"
}

# Crea un directorio y guarda el video y otros archivos con el mismo nombre pero diferente extensión.
function archivo () {
  dir_origen="${1%.*}"
  mkdir "$dir_origen"
  mv -vb "$1" "$dir_origen"/
}

# Busca archivos de vídeo y los envía a la función 'archivo ()'
function archivar_todo () {
  while read peli
    do
      local ext=${peli##*.}
      for fin in "${A_VIDEOS[@]}"
	do
	  if [[ "$fin" == "$ext" ]]; then  archivo "$peli"; fi
	done
    done < <(find ./ -maxdepth 1 -type f | sort)
}

# Imprime datos de control para comprobar si va todo bien
function control {
  echo "Origen: $opt_origen"
  echo "Origen (dir): $dir_origen"
  echo "Destino: $pelicula_dir'"
  echo "pelicula: $pelicula'"
  exit 0
}

# Gestión de argumentos
while getopts aho:e:f:p:y:g: option
  do
    case "${option}"
    in
	h) usage
   	exit 0;;
	f) archivo "$OPTARG"
   	exit 0;;
	y) opt_anyo=$OPTARG;;
	o) opt_origen="${OPTARG%/*}";;
	e) opt_etiquetas=$(printf '[%s]' ${OPTARG[*]});;
	p) opt_pelicula="${OPTARG%/*}";;
	a) archivar_todo
	  exit 0;;
	g) opt_grupo="[$OPTARG]";;
       \?) echo "ERROR: argumento no aceptado en este programa"
	  usage
	  exit 1;;
    esac
  done

# Si la fuente es un video y no un directorio:
[ -f "$opt_origen" ] && archivo "$opt_origen" || dir_origen="$opt_origen"

# Si no paso el argumento '-p <pelicula>', la película tiene el nombre del directorio '$dir_origen'
# Si he pasado el año como argumento. lo añado al final del nombre de la película
pelicula_dir="${opt_pelicula:-${dir_origen}}${opt_anyo:+ (${opt_anyo})}"
# Nueva variable con etiquetas y grupo
# No puedo generar directamente el nombre del archivo de video por culpa del espacio entre el nombre del directorio y las etiquetas
tags="${opt_etiquetas:+$opt_etiquetas}${opt_grupo:+$opt_grupo}"
# Creo el nombre del archivo de video con el nombre del directorio más las etiquetas y grupo
pelicula="$pelicula_dir${tags:+ $tags}"
# Si existe la etiqueta 'target' añado el dato a las etiquetas y a la ruta de destino
[ -n "$opt_grupo" ] && pelicula_dir="$RUTA_CINE/$opt_grupo/$pelicula_dir"

mkdir -v "$pelicula_dir"

function eliminar_basura {
  for basura in "${A_ELIMINAR[@]}"
    do
      [[ -f "$dir_origen/$basura" ]] && rm -v -- "$dir_origen/$basura"
    done
}

function conservar_subdirectorios {
  find "$dir_origen/"  -mindepth 1 -maxdepth 1 -type d -exec mv -b -t "$pelicula_dir"/ {} \;
}

function conservar_extensiones {
  for extension in "${A_EXTENSIONES[@]}"
    do
      find "$dir_origen/" -maxdepth 1 -type f -iname "*$extension" -exec mv -b --backup=numbered {} "$pelicula_dir/$pelicula$extension" \;
    done
}

#control
eliminar_basura
conservar_subdirectorios
conservar_extensiones

rmdir -v "$dir_origen"

ls -ahl "$pelicula_dir"
