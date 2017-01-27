#!/bin/bash

#directorio temporal
TEMP="temp"
mkdir $TEMP
cd $TEMP

#se descarga la página y se guarda con el nombre indicado en la variable PAGINA
#se valida si la descarga fue exitosa, si ocurrió algún error se detiene el script
PAGINA="pagina"
wget "http://www.minetad.gob.es/energia/balances/Publicaciones/ElectricasMensuales/Paginas/ElectricasMensuales.aspx" -O "$PAGINA" -q
if [[ $? -ne 0 ]]; then
    echo "wget failed"
    rm $PAGINA
    exit 1
fi

#se busca en PAGINA todas las etiquetas que tengan <option>*</option>, se sabe que los option pertenencen a un select
#al resultado anterior se le extraen los números de 4 dígitos que empiezan por ", se hace porque cada option tiene el numero del año dos veces, uno en value y otro en el texto
#al resultado anterior hay que quitarle ", para ello se usa sed
YEARS=($(grep -Po '<option[\w\W]+</option>' "$PAGINA" | grep -Po '"[0-9]{4}' | sed 's/"//'))

#suponemos que cada año tiene todos los meses completos, no importa si falla alguno
MONTHS=( 'Enero' 'Febrero' 'Marzo' 'Abril' 'Mayo' 'Junio' 'Julio' 'Agosto' 'Septiembre' 'Octubre' 'Noviembre' 'Diciembre' )
URL="http://www.minetad.gob.es/energia/balances/Publicaciones/ElectricasMensuales"

#se recorren todos los años con sus respectivos meses, se crea la url correspondiente y se procede a su descarga
#algunos enlaces usan el guion bajo y otros un espacio como separador, se intentan los dos casos 
for YEAR in ${YEARS[@]}
do
    for MONTH in ${MONTHS[@]}
    do
        URL2="${URL}/${YEAR}/${MONTH}_${YEAR}.zip"
        URL3="${URL}/${YEAR}/${MONTH}%20${YEAR}.zip"
        FILENAME="${YEAR}_${MONTH}.zip"
        wget $URL2 -O $FILENAME -q
        #wget $URL2 -q
        if [[ $? -ne 0 ]]; then
            wget $URL3 -O $FILENAME -q
            #wget $URL3 -q
            if [[ $? -ne 0 ]]; then
                echo "Download failed $FILENAME"
                rm $FILENAME
            fi
        fi
    done
done

#se descomprimen los archivos .zip los borrramos
FILES=($(ls *.zip))
for FILE in ${FILES[@]}
do
    FILENAME=$(echo ${FILE} | cut -f 1 -d '.')
    echo $FILENAME
    unzip $FILE -d -q $FILENAME
    rm $FILE
done