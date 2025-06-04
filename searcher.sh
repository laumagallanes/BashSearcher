#!/bin/bash

#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"
#variables globales
main_url="https://htbmachines.github.io/bundle.js"

function ctrl_c(){
  echo -e "\n\n${redColour}[!]saliendo...${endColour}\n"
  echo -e "\t m) Buscar por nombre de maquina"
  echo -e "\t h) Panel de Ayuda"
  exit 1
}

#ctrl + C
trap ctrl_c INT


function panelAyuda(){
  echo -e "\n [+] Se usa asi.."
  echo -e "\th) para Ayuda"
  echo -e "\tu) para Descargar o actualizar archivo"
  echo -e "\tm) para buscar una maquina"
  echo -e "\ti) Buscar por Direccion IP"
}

function updateFile(){
  echo -e "\n comprobando si hay actualizaciones"
  if  [ ! -f bundle.js ]; then
    echo -e "bajando archivos"
    curl -S $main_url > bundle.js
    js-beautify bundle.js | sponge bundle.js
  else
    curl -S $main_url > bundle_temp.js
    js-beautify bundle_temp.js | sponge bundle_temp.js
    md5_temp_val=$(md5sum bundle_temp.js | awk '{print $1}')
    md5_original_val=$(md5sum bundle.js | awk '{print $1}')
    if [ "$md5_temp_val"  == "$md5_original_val" ] ; then
      echo -e "\nno hay actualizaciones" 
      rm  bundle_temp.js
    else
      echo -e "\nhay actualizaciones"
      rm bundle.js && mv bundle_temp.js bundle.js
    fi
  fi

}


function searchMachine (){
  machineName="$1"
  echo -e "\n ${redColour}[+]${endColour}${grayColour}Listando propiedades de la maquina ${endColour}${blueColour} $machineName ${endColour}"

  cat bundle.js  | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "resuelta|id:|sku" | tr -d '"' | tr -d ',' | sed 's/^ *//'
  
}

function searchIP () {
ipAddress="$1"
echo -e "buscando por IP:$ipAddress"
machineName="$(cat bundle.js  | grep "ip: \"$ipAddress\"" -B 3 | grep name | awk 'NF{print$NF}' | tr -d '"' | tr -d ',')"
echo -e "\n${redColour}La maquina de la ip $ipAddress es ${endColour}${yellowColour}$machineName${endColour}"

}

#indicador

declare -i parameter_counter=0


while getopts "m:i:uh" arg; do
  case $arg in
    m) machineName=$OPTARG; let parameter_counter+=1;;
    u) let parameter_counter+=2;;
    i) ipAddress=$OPTARG; let parameter_counter+=3;;
    h) panelAyuda; exit 0;;
  esac
done

if [ $parameter_counter -eq 1 ]; then
  searchMachine $machineName
elif [ $parameter_counter -eq 2 ]; then
  updateFile
elif [ $parameter_counter -eq 3 ]; then
  searchIP $ipAddress
else
  panelAyuda
fi
