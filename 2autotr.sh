#!/bin/bash

#Traceroute par EnzoALBOUY

nbUk=$(cat $1 |grep "Unknown" |wc -l)
echo $nbUk
if [ $nbUk != 0 ]
then
for ((nbRtr=1;nbRtr<=nbUk;nbRtr++))
do
  unknown=$(cat $1 |grep "Unknown" |head -n $nbRtr |tail -n1)
  echo $unknown
  ttl=$(echo $unknown |awk '{print $1}')
  var=$(cat $1 |head -n $((($ttl+1)))|tail -n1 |awk '{print $2}') 
  var2=$(cat $1 |head -n $((($ttl-1))) |tail -n1|awk '{print $2}')
  var3=$(echo "Routeur entre $var et $var2")
  echo $var3
  sed -i 's|$unknown|$var3|g' $1
done
else
	echo "fini"
fi

