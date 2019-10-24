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
    echo "Indiquez un nom suffixe au chemin pour définir le nom du fichier route."
    exit
fi

tMAX=10
star=0
unknownHOP=0
fichierRTE="${1}${2}"
tab=("-I" "-U -p 53" "-U -p 123" "-T -p 80" "-T -p443")


echo "Début du script"
#Boucle for pour ajouer 1TTL a chaque nouvelle boucle
for ttl in $(seq 1 30); do
  if [ $unknownHOP -ge 5 ];then
    break
  fi

for methode in "${tab[@]}"
do
  res=$(traceroute "$1" -A -n -q 1 -w $tMAX -m $ttl $methode |tail -n1 |awk '{print $2 " " $3}' )
  #resF=$(echo "$res" |awk '{print $2}')
  echo "$res"
  if [[ "$ipcible" = "$(echo "$res" |awk '{print $1}')" ]]
  then
    echo "$ipcible ($1)" >> $fichierRTE
    break 2
  elif [ ! "$(echo "$res" |awk '{print $1}' |grep "*" )" ]
  then
    star=0
    echo "$res" >> $fichierRTE
    break
  else
    star=$((star + 1))
    if [ $star -eq 5 ]
    then
      echo "Unknown Router (Hop Nb : $ttl)" >> $fichierRTE
      unknownHOP=$((unknownHOP + 1))
      star=0
    fi
  fi

done
  
done


#--------------------------------Mise en forme------------------------

lFi=$(cat $fichierRTE|wc -l)
sed -i -r 's|.*Unknown.*|Unknown|g' $fichierRTE
cat $fichierRTE|uniq > tmp.txt
#cat tmp.txt
nbUk=$(cat tmp.txt|grep "Unknown" |wc -l)
numUk=1

echo "$nbUk Réseau(x) inconnu"
if [ $nbUk != 0 ]
then
for ((ligne=1;ligne<=lFi;ligne++))
do
  if [ $(cat tmp.txt|head -n $ligne|tail -n1 |grep "Unknown") ]
  then
    var=$(cat tmp.txt |head -n $((($ligne+1)))|tail -n1|awk '{print $1}')
    var2=$(cat tmp.txt |head -n $((($ligne-1)))|tail -n1|awk '{print $1}')
    var3=$(echo "Réseau entre $var2 et $var")
    sed -i "s|Unknown|$var3|" tmp.txt
    numUk=$((($numUk+1)))
  fi
done
  else
    echo "fini"
fi

cp tmp.txt $fichierRTE

#On affiche notre fichier route
cat $fichierRTE
