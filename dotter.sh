#! /bin/bash

old_IFS=$IFS # sauvegarde du séparateur de champ
IFS=$'\n' # nouveau séparateur de champ, le caractère fin de ligne
fichierdot=$2

sed -i '$ s/.$//' $fichierdot >> $fichierdot

echo "Initialisation du fichier .dot"
if [ ! "$(head -n2 $fichierdot |cut -d" " -f1 |grep "strict" )" ]
  then echo -e "strict digraph essai1 { \nlocalhost [shape=house]; \n\"localhost\"" >> $fichierdot
  else
    echo -e "\nlocalhost [shape=house]; \n\"localhost\" " >> $fichierdot
fi

for ligne in $(cat $1)
do
  if echo $ligne |grep "Unknown"
    then
      echo -n -e " -> \"$ligne between\" \n\"$ligne\" [shape=box color=red]; \n\"$ligne\"" >> $fichierdot
    elif echo $ligne |grep "www."
      then 
        echo -n -e " -> \"$ligne\" \n\"$ligne\" [shape=house] " >> $fichierdot
      else
        echo " -> \"$ligne\"" >> $fichierdot
  fi
done

echo "}" >> $fichierdot

IFS=$old_IFS # rétablissement du séparateur de champ par défaut
