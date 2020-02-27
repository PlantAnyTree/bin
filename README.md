# bin
***Código para mi servidor Plex-Kodi, sobre raspbian lite, ejecutándose en una Raspberry pi4 2GB***  
****
## pelis.sh
Realiza varias tareas con la colección de películas.  
Ahora, también incluye las funciones que ejecutaba -'pelisorden.sh'-
1. Crea listados de películas en almacenamiento y en respaldo
2. Renombra las películas y los directorios que las alojan según plantilla
   * Crea directorios para archivos de vídeos con el nombre de la película y el año de estreno.  
   * Renombra los archivos de video incorporando etiquetas sobre idioma y formato.  
   * Mueve los directorios con los videos al directorio correspondiente en mi videoteca.  
   * Elimina archivos de publicidad o innecesarios descargados con los videos.  
3. Busca películas sin respaldo y guarda una copia  
   * En este ejemplo, busca en el directorio 'dual' del respaldo por películas que no se encuentren en la videoteca.  
   * Una vez encontrada una película la copia a la videoteca.  
   * Después de copiar la película acaba el programa.  
   * Este comportamiento permite que se ejecute desde el crontab cada cierto tiempo y que no ocupe demasiados recursos durante demasiado tiempo.  
4. Recupera una película perdida desde el respaldo.  

**Ejemplos:**  
   ```pelis.sh -r dual```  
   ```pelis.sh -i VDE```  
**Estructura de videoteca:**  
 */var/media/Cine/*  
* [dual]
* [es]
* [lat]
* [VDE]
* [VDL]
* [VO]
* [VOSE]
***
## tempcontrol.sh
* Registra temperaturas altas en el procesador
* En caso de superar un cierto límite apaga la Rpi.
* Se puede ejecutar desde 'crontab' cada ciertos minutos
* Permite también solicitar la info desde la terminal.

***
## pelisorden.sh
. Programa integrado en pelis.sh
