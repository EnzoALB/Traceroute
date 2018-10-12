#!/bin/bash

#Traceroute par EnzoALBOUY

#Initialisation de l'argument 1 (adresse ciblée)
if [ -z $1 ]
  then
        echo "Indiquez un serveur destination"
  else

#demande d'info complémentaire
        echo 'Indiquez le port UDP utilisé [1149-3343(4-8)-5060-5004]:'
        read pUDP
        echo 'Indiquez le port TCP utilisé [21-22-80-443-42]:'
        read pTCP
        echo 'Indiquez le nombre de trames envoyées [10 max] :'
        read tMAX
        echo ''
fi

#Réinitialisation du fichier
echo > hote2.rte

#Recherche de l'ip ciblée
ipcible=$(dig +short "$1" | tail -n1)

#Boucle for pour ajouer 1TTL a chaque nouvelle boucle
for ttl in $(seq 1 30); do
#Commande traceroute UDP
  rUDP=$(traceroute "$1" -A -n -q $tMAX -m $ttl -p $pUDP |tail -n1 )
#Traitement de la réponse et récupération unique de l'IP et de l'AS
  resUDP=$(echo "$rUDP" | awk '{print $2 " " $3}')
#Comparaison de l'IP ciblée avec L'IP récupérée
  if [[ "$ipcible" = "$(echo "$resUDP" |awk '{print $1}')" ]]
  then
#Si cible=Ip récupérée un ajoute au ficher route
    echo "$resUDP" >> hote2.rte
    break
#Recherche du caractère * dans le résultat du traceroute précédent
  elif [ ! "$(echo "$resUDP" |grep "*" )" ]
  then
#Si pas d'étoile on ajoute au fichier route et on continue
    echo "$resUDP" >> hote2.rte
    continue
#Sinon on ajoute +1 a star (On verra l'utilité plus tard) et on change de protocole 
  else
    star=$((star + 1))
  fi

#Pareil que pour UDP mais protocole ICMP
  rICMP=$(traceroute "$1" -A -n -q $tMAX -m $ttl |tail -n1 )
  resICMP=$(echo "$rICMP" |awk '{print $2 " " $3}')
  if [[ "$ipcible" = "$(echo "$resICMP" |awk '{print $1}')" ]]
  then
    echo "$resICMP" >> hote2.rte
    break
  elif [ ! "$(echo "$resICMP" |grep "*" )" ]
  then
    echo "$resICMP"  >> hote2.rte
    continue
  else
    star=$((star + 1))
  fi

#Pareil que pour UDP mais protocole TCP
  rTCP=$(traceroute "$1" -A -n -q $tMAX -m $ttl -p $pTCP |tail -n1 )
  resTCP=$(echo "$rTCP" |awk '{print $2 " " $3}')
  if [[ "$ipcible" = "$(echo "$resTCP" |awk '{print $1}')" ]]
  then
    echo "$resTCP" >> hote2.rte
    break
  elif [ ! "$(echo "$resTCP" |grep "*" )" ]
  then
    echo "$resTCP" >> hote2.rte
    continue
  else
    star=$((star + 1))
  fi
#Si aucun protocole ne donne d'IP on note une étoile dans notre fichier route
  echo "*" >> hote2.rte
#Si star = 9 on arrête le script (Permet d'avorter le script en cas de destruction du paquet
  if [ "$star" -ge "9" ]
  then
    break
  fi
#On remet star a 0 si une adresse est rencontrée (Permet d'arreter le script en cas de 3 étoiles consécutives et non 3 étoiles totales)
star=0
done

#On affiche notre fichier route
cat hote2.rte
