#!/bin/bash
#https://github.com/a18danperllu/P19FINAL
#Menú d'ajuda
usage() {
	echo "Usage: ./show-attackers.sh [log-file] file
	Display the number of failed logins attemps by IP address and location
       	from a log file" 1>&2;
	exit 1;
}

#Comprobo que es proporciona fitxer
if [[ $# -eq 0 ]]
then
	echo "ERROR: Has de pasar un fitxer com argument."
	exit 1
fi

file "{$1}" >> /dev/null
if [[ $? -ne 0 ]]
then
	echo "ERROR: No es pot obrir el fitxer log: $1"
        exit 1
fi

#Agafo totes les IPs que han donat fallida en quant SSH
content=`cat $1 | grep Failed | grep -o -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | sort`

#Declaro la Array asociativa
declare -A llistaIP

#Guardo el nombre de vegades que es troba una IP en una Key de la array en aquesta funció.
guardarIP(){
	for i in $content;
	do
		if [[ -z "${llistaIP[$i]}" ]]
		then
			llistaIP[$i]=1
		else
			llistaIP[$i]+=1
		fi
	done
}

#Mostro per pantalla els continguts en funció dels valors de la array.
printContin(){
	echo " "
	echo "Count | Ip | Location (Country)"
	echo " "
	for i in "${!llistaIP[@]}";
	do
		att=`echo "${llistaIP[$i]}" | wc -m`
		geo=`geoiplookup $i | awk '{print $NF}'`
		echo "$att	$i	$geo"
		echo "	"
	done
}
guardarIP
printContin
