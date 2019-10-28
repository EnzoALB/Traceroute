#! /bin/bash

old_IFS=$IFS # sauvegarde du séparateur de champ
IFS=$'\n' # nouveau séparateur de champ, le caractère fin de ligne
prefixRTE=$1
fichierdot=$2
var=""

echo > $fichierdot
for i in $(ls *.$prefixRTE.route)
do
  color=$(echo $RANDOM|md5sum|cut -c 1-6)
  echo "Initialisation du fichier $i"
  if [ ! "$(head -n2 $fichierdot |cut -d" " -f1 |grep "digraph" )" ]
    then echo -e "digraph essai1 { \nlocalhost [shape=house]; \n\"localhost\"" >> $fichierdot
    else
      echo -e -n "\"localhost\"\n" >> $fichierdot
  fi

  for ligne in $(cat $i)
  do
    if echo $ligne |grep "Réseau"
      then
        echo -n -e " -> \"$ligne\"\n" >> $fichierdot
        var="$var \"$ligne\" [shape=box color=red];\n"
      elif echo $ligne |grep "(.*)"
        then 
          echo -n -e " -> \"$ligne\" [color=\"#$color\"]\n" >> $fichierdot
       	  var="$var \"$ligne\" [shape=house];\n"
        else
          echo " -> \"$ligne\"" >> $fichierdot
    fi
  done
done

echo -n -e $var >> $fichierdot
echo "}" >> $fichierdot

IFS=$old_IFS # rétablissement du séparateur de champ par défaut
