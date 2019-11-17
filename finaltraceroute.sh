#!/bin/bash

#-------------------------------------------------------------------------------#
#                                                                               # 
#                          Traceroute par Enzo ALBOUY                           #
#                                                                               #
#-------------------------------------------------------------------------------#


###### SYNTAXE ######

#Pour invoquer le script, veuillez faire :
# ./finaltraceroute.sh [Adresse recherchée] [Suffixe nom fichier]
# Adresse recherchée sera de la forme IP ou www.example.org
# Suffixe sera de la forme .methode.route, ou la méthode sera soit Ethernet, 4G ...


#Initialisation de l'argument 1 (adresse ciblée)
#On vérifie si on a bien un argument 1
echo "Demarrage du script"
echo "Verrifications des arguments"
if [ -z $1 ]
  then
    echo "Indiquez un serveur destination"
    exit
  #Si on a bien l'addresse, on vérifie si elle est de la forme hostname (www.example.org)
  elif [ "$(echo $1 |grep '[a-z]')" = "$1" ]
  then
    #Recherche de l'ip ciblée
    ipcible=$(host $1 |grep "has address" |cut -d " " -f4)
    echo "IP cible = "$ipcible  
  else  
    ipcible=$1
fi

#On vérifie qu'on a bien un second argument
if [ -z $2 ]
  then
    echo "Indiquez un nom suffixe au chemin pour définir le nom du fichier route."
    exit
fi

#Initialisation des variables
tMAX=10
star=0
unknownHOP=0
#Création de notre fichier route
fichierRTE="${1}${2}"
#Tableau de méthodes
tab=("-I" "-U -p 53" "-U -p 123" "-T -p 80" "-T -p443")


echo "Début du script"
#Boucle for pour ajouer 1TTL a chaque nouvelle boucle
for ttl in $(seq 1 30); do
  if [ $unknownHOP -ge 5 ];then
    break
  fi

#Boucle pour faire methode par methode
for methode in "${tab[@]}"
do
  res=$(traceroute "$1" -A -n -q 1 -w $tMAX -m $ttl $methode |tail -n1 |awk '{print $2 " " $3}' )
  resF=$(echo "$res" |awk '{print $1}')
  echo "$res"
  #On teste IP récupérée = cible ?
  if [ "$(echo $ipcible|grep "$resF")" ]
  then
    echo $ipcible "($1)" >> $fichierRTE
    break 2
  #On vérifie que notre IP n'est pas une étoile, on l'écrit dans notre fichier et on break pour passer au TTL suivant
  elif [ ! "$(echo "$res" |awk '{print $1}' |grep "*" )" ]
  then
    star=0
    echo "$res" >> $fichierRTE
    break
  #Si on a une étoile, on passe a la méthode d'apres, si 5 etoiles, on écrit unknown
  else
    star=$((star + 1))
    if [ $star -eq 5 ]
    then
      echo "Unknown" >> $fichierRTE
      unknownHOP=$((unknownHOP + 1))
      star=0
    fi
  fi

done
  
done


#--------------------------------Mise en forme---------------------------------#
#On compte le nombre de lignes du fichier (Qui indique le nombre de routeurs)
lFi=$(cat $fichierRTE|wc -l)
#On concatème les Unknown successifs pour créer des réseaux inconnus
cat $fichierRTE|uniq > tmp.txt
#On compte le nombre de réseaux inconnus
nbUk=$(cat tmp.txt|grep "Unknown" |wc -l)

echo "$nbUk Réseau(x) inconnu"
#Si on a des réseaux inconnus on va les mettres en forme
if [ $nbUk != 0 ]
then
#On lit le fichier ligne par ligne
for ((ligne=1;ligne<=lFi;ligne++))
do
  #Si on trouve un inconnu, on le met de la forme [Réseau entre IP Précédente et IP Suivante]
  if [ $(cat tmp.txt|head -n $ligne|tail -n1 |grep "Unknown") ]
  then
    var=$(cat tmp.txt |head -n $((($ligne+1)))|tail -n1|awk '{print $1}')
    var2=$(cat tmp.txt |head -n $((($ligne-1)))|tail -n1|awk '{print $1}')
    var3=$(echo "Réseau entre $var2 et $var")
    #Ce sed permet de remplacer le unknown par la phrase crée a var3
    sed -i "$ligne s|Unknown|$var3|" tmp.txt 
  fi
done
  else
    echo "fini"
fi

cp tmp.txt $fichierRTE

#On affiche notre fichier route
cat $fichierRTE
