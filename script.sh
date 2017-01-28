#!/bin/bash

TEMP="temp"
cd $TEMP

PROVINCIAS=('ALAVA' 'ALBACETE' 'ALICANTE' 'ALMERIA' 'AVILA' 'BADAJOZ' 'BALEARES' 'BARCELONA' 'BURGOS' 'CACERES' 'CADIZ' 'CASTELLON' 'CIUDADREAL' 'CORDOBA' 'LACORU' 'CUENCA' 'GIRONA' 'GRANADA' 'GUADALAJARA' 'GUIPUZCOA' 'HUELVA' 'HUESCA' 'JAEN' 'LEON' 'LLEIDA' 'LARIOJA' 'LUGO' 'MADRID' 'MALAGA' 'MURCIA' 'NAVARRA' 'ORENSE' 'ASTURIAS' 'PALENCIA' 'LASPALMAS' 'PONTEVEDRA' 'SALAMANCA' 'TENERIFE' 'CANTABRIA' 'SEGOVIA' 'SEVILLA' 'SORIA' 'TARRAGONA' 'TERUEL' 'TOLEDO' 'VALENCIA' 'VALLADOLID' 'VIZCAYA' 'ZAMORA' 'ZARAGOZA' 'CEUTA' 'MELILLA')
TYPES=( 'NUCLEAR' 'CARBONES' 'LIGNITOS' 'FUEL' 'GAS' 'OTRO' 'TOTAL' )

#de los archivos que nos interese, modificamos los nombres de las provincias problematicas, seleccionamos sólo las lines que necesitamos 
#y las mantenemos en una variable temporal. Del nombre del archivo se obtiene el año y la fecha.
#Para cada una de las provincias buscamos en el archivo temporal la informaciòn correspondiente a la provincia, de esa informacipon
#se procesan los valores para quitarle el separador punto y por cada tipo de combustible y para cada provincia se crea un archivo
#donde se va volcando la información

for FILE in $(find ./ -type f -name "T_127P*.txt")
do
    FILENAME=$(echo ${FILE} | cut -f 2 -d '/' | cut -f 1 -d '.')
    FILETEMP=$(sed "s/LA CORU/LACORU/g; s/LA RIOJA/LARIOJA/g; s/LAS PALMAS/LASPALMAS/g; s/S.C.TENERIFE/TENERIFE/g; s/CIUDAD REAL/CIUDADREAL/g; s/T O T A L/TOTAL/g" "${FILE}" | sed -n '10,63p')
    for PROVINCIA in ${PROVINCIAS[@]}
    do
        DATA=($(echo ${FILETEMP} | grep ${PROVINCIA}))
        for k in ${!TYPES[@]}
        do
            VALUE=$(echo ${DATA[k+1]} | sed 's/\.//g' )
            echo "${FILENAME} ${VALUE}" >> "${PROVINCIA}_${TYPES[k]}.txt"
        done
    done
done


