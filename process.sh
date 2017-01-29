#!/bin/bash

######################
#Procesa los archivos de los balances de produccion de energia de Espana obtenidos de la pagina del ministerio de energia
#para crear series temporales
#Autor: Cristian Leonardo Rios Lopez
#Fecha: 29-01-2016
######################

IDCOMUNIDADES=( '01' '02' '03' '04' '05' '06' '07' '08' '09' '10' '11' '12' '13' '14' '15' '16' '17' '18' '19' )
COMUNIDADES=( 'ANDALUCIA' 'ARAGON' 'ASTURIAS' 'BALEARES' 'CANARIAS' 'CANTABRIA' 'CASTILLALEON' 'CASTILLALAMANCHA' 'CATALUNA' 'COMUNITATVALENCIANA' 'EXTREMADURA' 'GALICIA' 'MADRID' 'MURCIA' 'NAVARRA' 'PAISVASCO' 'LARIOJA' 'CEUTA' 'MELILLA' )
IDPROVINCIAS=('21*41*14*23*11*29*18*04' '22*50*44' '33' '07' '38*35' '39' '24*34*09*49*47*42*40*37*05' '19*45*16*13*02' '25*17*08*43' '12*46*03' '10*06' '15*27*36*32' '28' '30' '31' '48*01*20' '26' '51' '52')
PROVINCIAS=('HUELVA*SEVILLA*CORDOBA*JAEN*CADIZ*MALAGA*GRANADA*ALMERIA' 'HUESCA*ZARAGOZA*TERUEL' 'ASTURIAS' 'BALEARES' 'TENERIFE*LASPALMAS' 'CANTABRIA' 'LEON*PALENCIA*BURGOS*ZAMORA*VALLADOLID*SORIA*SEGOVIA*SALAMANCA*AVILA' 'GUADALAJARA*TOLEDO*CUENCA*CIUDADREAL*ALBACETE' 'LLEIDA*GIRONA*BARCELONA*TARRAGONA' 'CASTELLON*VALENCIA*ALICANTE' 'CACERES*BADAJOZ' 'LACORU*LUGO*PONTEVEDRA*ORENSE' 'MADRID' 'MURCIA' 'NAVARRA' 'VIZCAYA*ALAVA*GUIPUZCOA' 'LARIOJA' 'CEUTA' 'MELILLA')
TYPES=( 'NUCLEAR' 'CARBONES' 'LIGNITOS' 'FUEL' 'GAS' 'OTRO' 'TOTAL' )
PROVINCIASONE=($( echo ${PROVINCIAS[@]} | sed 's/*/ /g' ))

#de los archivos que nos interese, modificamos los nombres de las provincias problematicas, seleccionamos solo las lines que necesitamos 
#y las guardamos en una variable temporal. Del nombre del archivo se obtiene el anio y la fecha.
#Para cada una de las provincias buscamos en el archivo temporal la informacion correspondiente a la provincia, de esa informacion
#se procesan los valores para quitarle el separador punto y por cada tipo de combustible y para cada provincia se crea un archivo
#donde se va volcando la informacion

echo "Procesando datos..."

for FILE in $(find ./ -type f -name "T_127P*.txt" | sort)
do
    FILENAME=$(echo ${FILE} | cut -f 2 -d '/' | cut -f 1 -d '.')
    sed "s/LA CORU/LACORU/g; s/LA RIOJA/LARIOJA/g; s/LAS PALMAS/LASPALMAS/g; s/S.C.TENERIFE/TENERIFE/g; s/CIUDAD REAL/CIUDADREAL/g; s/T O T A L/TOTAL/g" "${FILE}" | sed -n '10,63p' > "${FILENAME}.txt"
    for PROVINCIA in ${PROVINCIASONE[@]}
    do
        DATA=($(grep "${PROVINCIA}" "${FILENAME}.txt"))
        for k in ${!TYPES[@]}
        do
            VALUE=$(echo ${DATA[$k+1]} | sed 's/\.//g' )
            echo "${FILENAME} ${VALUE}" >> "${PROVINCIA}_${TYPES[$k]}.txt"
        done
    done
done

cd .. #me regreso un directorio para crear la estructura
SERIESDIR="seriesTemporales"
mkdir $SERIESDIR
cd $SERIESDIR

#para cada una de las comunidades se crea un direcotrio
#para cada una de las provincias se crea otro directorio
#para cada una de las provincias se mueven los archivos correspondientes al direcotrio de la provincia

echo "Creando estructura..."

for i in ${!COMUNIDADES[@]}
do
    COMUNIDAD=${COMUNIDADES[$i]}
    IDCOMUNIDAD=${IDCOMUNIDADES[$i]}
    DIR=${IDCOMUNIDAD}_${COMUNIDAD}
    mkdir $DIR
    cd $DIR
    PROVINCIASVAR=($( echo ${PROVINCIAS[$i]} | sed 's/*/ /g' ))
    IDPROVINCIASVAR=($( echo ${IDPROVINCIAS[$i]} | sed 's/*/ /g' ))
    for j in ${!PROVINCIASVAR[@]}
    do
        PROVINCIA=${PROVINCIASVAR[$j]}
        IDPROVINCIA=${IDPROVINCIASVAR[$j]}
        echo "${IDCOMUNIDAD}_${COMUNIDAD} ${IDPROVINCIA}_${PROVINCIA}"
        DIR2=${IDPROVINCIA}_${PROVINCIA}
        mkdir $DIR2
        cd $DIR2
        find ../../.. -type f -name "${PROVINCIA}*" -exec mv -t ./ {} +
        cd .. #me regreso al directorio de la comunidad
    done
    cd .. #me regreso al directorio raiz
done

echo "Terminado con exito!"
echo "Las series temporales se encuentran en el directorio ${SERIESDIR}"
