#!/bin/bash
for i in *.jpg; 
do 
	if [ ! -e ".$i.thm" ]
	then
		convert -thumbnail 150x150 "$i" ".$i.thm"; 
		echo "Finished $i"; 
	fi
done


for i in *.JPG; 
do 
	if [ ! -e ".$i.thm" ]
	then
		convert -thumbnail 150x150 "$i" ".$i.thm"; 
		echo "Finished $i"; 
	fi
done

for i in *.tif; 
do 
	if [ ! -e ".$i.thm" ]
	then
		convert -thumbnail 150x150 "$i" ".$i.thm"; 
		echo "Finished $i"; 
	fi
done

for i in *.TIF; 
do 
	if [ ! -e ".$i.thm" ]
	then
		convert -thumbnail 150x150 "$i" ".$i.thm"; 
		echo "Finished $i"; 
	fi
done

for i in * ;
do
	if [ -d "$i" ]
	then
		cd "$i";
		echo "Processing Folder $i" ;
		bash /home/andrew/Pictures/CreateAlbum.sh "$i" ;
		cd .. ;
	fi

done

sed "s/TITLETEXT/$1/" /home/andrew/Pictures/index.php >index.php

