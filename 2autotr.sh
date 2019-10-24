#!/bin/bash

#Traceroute par EnzoALBOUY

lFi=$(cat $1|wc -l)
sed -i -r 's|.*Unknown.*|Unknown|g' $1
cat $1|uniq > tmp.txt
#cat tmp.txt
nbUk=$(cat tmp.txt|grep "Unknown" |wc -l)

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
    sed -i "s|Unknown|$var3|g" tmp.txt
    cp tmp.txt $1
    echo "fini"
  fi
done
  else
    echo "fini"
fi

