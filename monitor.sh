#!/bin/bash

die() 
{
    echo $1 >&2
    exit 1
}
#Función de ayuda, muestra información de uso y funcionalidad del script
menosh()
{	

	echo "Modo de empleo: ./monitor.sh direcciónAMonitorizar ficheroDeRegistro" 
	echo -e "\t     Monitoriza un directorio en lo relativo a la creación y modificación"
	echo -e "\t	de archivos en su interior, el directorio se pasa como parámentro en " 
	echo -e "\t     direcciónAMonitorizar. Por cada creación de fichero se añade una línea en "
	echo -e "\t     ficheroDeRegistro con fecha y hora de creación, nombre y usuario que lo creó"

	die

}

#Comprobación de la correcta llamada al script
#Primero comprobamos si el primero argumento pasado es -h
#si ese es el caso se llama a la función de información
if [[ $1 == "-h" ]]
then
	menosh
fi

#Si el primeroargumento no es -h comprobamos el número de argumentos pasados,
#en caso de que no sean dos se enviará un mensaje de error y un consejo

[[ $# -ne 2 ]] && die "Error con los argumentos prueba ./monitor.sh [-h]"

#Finalmente si el número de argumentos es el correcto nos aseguramos
#de que el primer argumento es una dirección existente y válida,
#en caso contrario envía un mensaje de error
[[ ! -d "$1" ]] && die "No existe el directorio a monitorizar"


#Función principal del script,
#recibe la dirección del directorio a crear y
#la del fichero donde se guardarán los datos si existe la creacion de ficheros
#La monitorización se realiza llamando a inotifywait encargándole de monitorizar los eventos de tipo create
main(){

monitorizar="$1"


 
inotifywait -m "$monitorizar" -e create |
    while read -r file; do
        name=$(stat --format %U $file 2>/dev/null) 
        date=$(stat --format %y $file 2>/dev/null)
        fichero=${file/* CREATE /}
        echo " Fecha y hora de creación: ${date%.*} Nombre del fichero creado: '$fichero' Persona creadora: $name" >>$2
    done

}
 
main $1 $2 & #Con & nos aseguramos de que la ejecución sea en segundo plano
