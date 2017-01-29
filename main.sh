#!/bin/bash

###################################
#Descarga los archivos correspondientes a los balances energeticos de la pagina del ministerio de energia de Espana
#Estos archivos son procesados para crear series temporales para cada provincia por cada tipo de produccion de energia
#Autor: Cristian Leonardo Rios Lopez
#Fecha: 29-01-2016
######################

#se crea un directorio temporal de trabajo
TEMP="temp"
mkdir $TEMP
cd $TEMP

#se ejecutan los scripts que realizan el trabajo
if ../download.sh; then
    ../process.sh
fi

#se borra el directorio temporal de trabajo
cd ..
rm -r $TEMP
