#!/bin/bash

versiones="/versiones"

#Creamos un vector que contenga todos los argumentos pasados
declare -a directorios=("$@") 

die() 
{
    echo $1 >&2
    exit 1
}



#Función de ayuda, muestra información de uso y funcionalidad del script
menosh()
{	

	echo "Modo de empleo: ./versiones.sh direcciónAMonitorizar [direcciónAMonitorizar2] .." 
	echo -e "\t     Monitoriza uno o más directorios en lo relativo a la creación y modificación"
	echo -e "\t	de archivos en su interior, el o los directorios se pasan como parámentro en " 
	echo -e "\t     direcciónAMonitorizar [direcciónAMonitorizar2]. "
	echo -e "\t     Por cada creación de fichero o modificación se crea un archivo de versión "
	echo -e "\t     con nombre ficheromodificadoOCreado.A.YYYYMMDDTHH:MM:SS"
	echo -e "\t     El fichero es creado en $versiones"

	die

}

#Comprobamos si existe en directorio a guardar los ficheros de las versiones
#En caso de que no lo creamos
if [[ ! -d "$versiones" ]]
then
	mkdir $versiones
fi

#Comprobación de la correcta llamada al script
#Primero comprobamos si el primero argumento pasado es -h
#si ese es el caso se llama a la función de información
if [[ $1 == "-h" ]]
then
	menosh
fi

#Si el primero argumento no es -h comprobamos el número de argumentos pasados,
#en caso de que no se pase ninguno se enviará un mensaje de error y un consejo

if [[ $# -eq 0 ]]
then 
	die "Error con los argumentos prueba ./versiones.sh [-h]"
	
fi

#Si los argumentos pasados son correctos en ese caso nos aseguramos de que cada
#argumento es una dirección que exista

for dir in $@ 
do
	[[ ! -d "$dir" ]] && die "No existe el directorio $dir a monitorizar"
done

#Función principal, recibe por parámetros los directorios a monitorizar
#Se encarga de hacer una llamada por cada directorios a una función auxiliar
#que monitoriza los directorios

main(){

for monitorizar in "${directorios[@]}"

do

	moni $monitorizar &

done

}

#Función auxiliar que recibe un directorio a monitorizar y cuando haya cambios
#crea un archivo de versión con cada cambio
moni(){


	inotifywait -m "$1" -e create -e modify -e delete |
    		while read -r file; do
        	name=$(stat --format %U $file 2>/dev/null) 
        	date=$(stat --format %y $file 2>/dev/null)
        	fichero=${file/* CREATE /}
        	echo " Fecha y hora de creación: ${date%.*} Nombre del fichero creado: '$fichero' Persona creadora: $name" > "$versiones""/""$fichero"".""$(date +"%F_%T")"
		
    		done


}


main directorios
