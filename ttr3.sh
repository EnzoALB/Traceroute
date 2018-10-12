#!/bin/bash

#Traceroute par EnzoALBOUY

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

echo > hote2.rte

ipcible=$(dig +short "$1" | tail -n1)

for ttl in $(seq 1 30); do
  rUDP=$(traceroute "$1" -A -n -q $tMAX -m $ttl -p $pUDP |tail -n1 )
  resUDP=$(echo "$rUDP" | awk '{print $2 " " $3}')
  if [[ "$ipcible" = "$(echo "$resUDP" |awk '{print $1}')" ]]
  then
    echo "$resUDP" >> hote2.rte
    break
  elif [ ! "$(echo "$resUDP" |grep "*" )" ]
  then
    echo "$resUDP" >> hote2.rte
    continue
  else
    star=$((star + 1))
  fi

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
  echo "*" >> hote2.rte
  if [ "$star" -ge "9" ]
  then
    break
  fi
star=0
done

cat hote2.rte
