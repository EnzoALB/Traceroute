#!/bin/bash

#Traceroute par EnzoALBOUY

#Initialisation de l'argument 1 (adresse ciblée)
echo "Demarrage du script"
echo "Verrifications des arguments"
if [ -z $1 ]
  then
    echo "Indiquez un serveur destination"
    exit
  elif [ "$(echo $1 |grep '[a-z]')" = "$1" ]
  then
    #Recherche de l'ip ciblée
    ipcible=$(host $1 |grep "has address" |cut -d " " -f4)
    echo "IP cible = "$ipcible  
  else
    ipcible=$1
fi

if [ -z $2 ]
  then
    echo "Indiquez un nom pour le fichier d'écriture"
    exit
fi

tMAX=10
star=0
unknownHOP=0
tab=("-I" "-U -p 53" "-U -p 123" "-T -p 80" "-T -p443")
fichierdot=$2

#Réinitialisation du fichier
echo "Initialisation fichier route"
echo > hote.rte

sed -i '$ s/.$//' $fichierdot >> $fichierdot

echo "Initialisation du fichier .dot"
if [ ! "$(head -n2 $fichierdot |cut -d" " -f1 |grep "strict" )" ]
  then echo -e "strict digraph essai1 { \nlocalhost [shape=house]; \n\"localhost\"" >> $fichierdot
  else
    echo -e "\nlocalhost [shape=house]; \n\"localhost\" " >> $fichierdot
fi


echo "Début du script"
#Boucle for pour ajouer 1TTL a chaque nouvelle boucle
for ttl in $(seq 1 30); do
  if [ $unknownHOP -ge 5 ];then
    break
  fi

for methode in "${tab[@]}"
do
  res=$(traceroute "$1" -A -n -q 1 -w $tMAX -m $ttl $methode |tail -n1 |awk '{print $2 " " $3}' )
  #res=$(echo "$r" |awk '{print $2 " " $3}')
  echo "$res"
  if [[ "$ipcible" = "$(echo "$res" |awk '{print $1}')" ]]
  then
    echo "$res" >> hote.rte
    echo -n -e " -> \"$res\"" >> $fichierdot
    break 2
  elif [ ! "$(echo "$res" |cut -d" " -f1 |grep "*" )" ]
  then
    star=0
    echo "$res" >> hote.rte
    echo -n " -> \"$res\"" >> $fichierdot
    break
  else
    star=$((star + 1))
    if [ $star -eq 5 ]
    then
      echo "Unknown Router (Hop Nb : $ttl)" >> hote.rte
      echo -n -e " -> \"Unknown Router (Hop Nb : $ttl)\" \n\"Unknown Router (Hop Nb : $ttl)\" [shape=box color=red]; \n\"Unknown Router (Hop Nb : $ttl)\"" >> $fichierdot
      unknownHOP=$((unknownHOP + 1))
      star=0
    fi
  fi

done
  
done

echo -n -e " -> \"$ipcible ($1)\" \n\"$ipcible ($1)\" [shape=house] }" >> $fichierdot
echo "$1" >> hote.rte
echo "$1"

#On affiche notre fichier route
cat hote.rte
