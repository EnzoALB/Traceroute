#!/bin/bash

#Traceroute par EnzoALBOUY

#Initialisation de l'argument 1 (adresse ciblée)
#if [ -z $1 ]
#  then
#        echo "Indiquez un serveur destination"
#  else

#demande d'info complémentaire
#        echo 'Indiquez le port UDP utilisé [1149-3343(4-8)-5060-5004]:'
#        read pUDP
#        echo 'Indiquez le port TCP utilisé [21-22-80-443-42]:'
#        read pTCP
#        echo 'Indiquez le nombre de trames envoyées [10 max] :'
#        read tMAX
#        echo ''
#fi

pUDP=80
pTCP=443
tMAX=1
star=0
#Réinitialisation du fichier
echo > hote2.rte
echo > essai1.dot

#Recherche de l'ip ciblée
ipcible=$(dig +short "$1" |tail -n1)

#if [ ! "$(head -n2 essai1.dot |cut -d" " -f1 |grep "strict" )" ]
#  then
    echo "strict digraph essai1 { localhost " >> essai1.dot
#  else
#    echo "digraph essai1 { localhost " >> essai1.dot
#fi

#Boucle for pour ajouer 1TTL a chaque nouvelle boucle
for ttl in $(seq 1 30); do
  if [ $star -ge 9 ];then
    break
  fi
#Commande traceroute UDP
  rUDP=$(traceroute "$1" -A -n -q $tMAX -m $ttl -p $pUDP |tail -n1 )
#Traitement de la réponse et récupération unique de l'IP et de l'AS
  resUDP=$(echo "$rUDP" |awk '{print $2 " " $3}')
  echo "$resUDP"
#Comparaison de l'IP ciblée avec L'IP récupérée
  if [[ "$ipcible" = "$(echo "$resUDP" |awk '{print $1}')" ]]
  then
#Si cible = Ip récupérée un ajoute au ficher route
    echo "$resUDP" >> hote2.rte
    echo -n " -> \"$resUDP\"" >> essai1.dot
    break
#Recherche du caractère * dans le résultat du traceroute précédent
  elif [ ! "$(echo "$resUDP" |cut -d" " -f1 |grep "*" )" ]
  then
#Si pas d'étoile on ajoute au fichier route et on continue
    star=0
    echo "$resUDP" >> hote2.rte
    echo -n " -> \"$resUDP\"" >> essai1.dot
    continue
#Sinon on ajoute +1 a star (On verra l'utilité plus tard) et on change de protocole 
  else
    star=$((star + 1))
  fi

#Pareil que pour UDP mais protocole ICMP
  rICMP=$(traceroute "$1" -A -n -q $tMAX -m $ttl |tail -n1 )
  resICMP=$(echo "$rICMP" |awk '{print $2 " " $3}')
  echo "$resICMP"
  if [[ "$ipcible" = "$(echo "$resICMP" |awk '{print $1}')" ]]
  then
    echo "$resICMP" >> hote2.rte
    echo -n " -> \"$resICMP\"" >> essai1.dot
    break
  elif [ ! "$(echo "$resICMP" |cut -d" " -f1 |grep "*" )" ]
  then
    star=0
    echo "$resICMP"  >> hote2.rte
    echo -n " -> \"$resICMP\"" >> essai1.dot
    continue
  else
    star=$((star + 1))
  fi

#Pareil que pour UDP mais protocole TCP
  rTCP=$(traceroute "$1" -A -n -q $tMAX -m $ttl -p $pTCP |tail -n1 )
  resTCP=$(echo "$rTCP" |awk '{print $2 " " $3}')
  echo "$resTCP"
  if [[ "$ipcible" = "$(echo "$resTCP" |awk '{print $1}')" ]]
  then
    echo "$resTCP" >> hote2.rte
    echo -n " -> \"$resTCP\"" >> essai1.dot
    break
  elif [ ! "$(echo "$resTCP" |cut -d" " -f1 |grep "*" )" ]
  then
    star=0
    echo "$resTCP" >> hote2.rte
    echo -n " -> \"$resTCP\"" >> essai1.dot
    continue
  else
    star=$((star + 1))
  fi
#Si aucun protocole ne donne d'IP on note une étoile dans notre fichier route
  echo "*" >> hote2.rte
done

echo "}" >> essai1.dot


#On affiche notre fichier route
cat hote2.rte
