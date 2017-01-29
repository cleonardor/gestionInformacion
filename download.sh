#!/bin/bash

######################
#Descarga y descomprime los balances de produccion de energia de Espana obtenidos de la pagina del ministerio de energia
#Autor: Cristian Leonardo Rios Lopez
#Fecha: 29-01-2016
######################

#se descarga la pagina y se guarda con el nombre indicado en la variable PAGINA
#se valida si la descarga fue exitosa, si ocurrio algun error se detiene el script
PAGINA="pagina"
echo "Descargando pagina Electricas Mensuales..."
wget "http://www.minetad.gob.es/energia/balances/Publicaciones/ElectricasMensuales/Paginas/ElectricasMensuales.aspx" -O "$PAGINA" -q
if [[ $? -ne 0 ]]; then
    echo "Descarga fallida. Proceso terminado!"
    rm $PAGINA
    exit 1
fi

#se busca en PAGINA todas las etiquetas que tengan <option>*</option>, se sabe que los option pertenencen a un select
#al resultado anterior se le extraen los numeros de 4 digitos que empiezan por ", se hace porque cada option tiene el numero del anio dos veces, uno en value y otro en el texto
#al resultado anterior hay que quitarle ", para ello se usa sed
YEARS=($(grep -Po '<option[\w\W]+</option>' "$PAGINA" | grep -Po '"[0-9]{4}' | sed 's/"//'))

#suponemos que cada anio tiene todos los meses completos, no importa si falla alguno
MONTHS=( 'Enero' 'Febrero' 'Marzo' 'Abril' 'Mayo' 'Junio' 'Julio' 'Agosto' 'Septiembre' 'Octubre' 'Noviembre' 'Diciembre' )
MONTHSNUM=( '01' '02' '03' '04' '05' '06' '07' '08' '09' '10' '11' '12' )
URL="http://www.minetad.gob.es/energia/balances/Publicaciones/ElectricasMensuales"

#se recorren todos los anios con sus respectivos meses, se crea la url correspondiente y se procede a su descarga
#algunos enlaces usan el guion bajo y otros un espacio como separador, se intentan los dos casos 
echo "Descargando archivos .zip"
for YEAR in ${YEARS[@]}
do
    for i in ${!MONTHS[@]}
    do
        MONTH=${MONTHS[$i]}
        MONTHNUM=${MONTHSNUM[$i]}
        URL2="${URL}/${YEAR}/${MONTH}_${YEAR}.zip"
        URL3="${URL}/${YEAR}/${MONTH}%20${YEAR}.zip"
        FILENAME="${YEAR}${MONTHNUM}.zip"
        wget $URL2 -O $FILENAME -q
        if [[ $? -ne 0 ]]; then
            wget $URL3 -O $FILENAME -q
            if [[ $? -ne 0 ]]; then
                echo "Descarga fallida $FILENAME"
                rm $FILENAME
            else
                echo "Descarga exitosa $FILENAME"
            fi
        else
            echo "Descarga exitosa $FILENAME"
        fi
    done
done

#se borra pagina una vez descargados los archivos
#rm $PAGINA

#se descomprimen los archivos .zip y  los borrramos
echo "Descomprimiendo archivos .zip"
FILES=($(ls *.zip))
for FILE in ${FILES[@]}
do
    FILENAME=$(echo ${FILE} | cut -f 1 -d '.')
    echo $FILENAME
    unzip -jq $FILE -d $FILENAME
    #rm $FILE
done
