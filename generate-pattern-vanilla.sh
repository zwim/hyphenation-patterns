#!/bin/bash

cd wortliste

git pull


sleep 5

cp wortliste wortliste.bak
cat meineWorte/* >> wortliste

make pattern-refo &

make fugen pattern-refo &

make major pattern-refo &

wait

cp wortliste.bak wortliste

cd ..

DATUM=`date +%Y-%m-%d`

find . | grep `date +%Y-%m-%d` | grep \.pat$ | xargs -i cp  {} .

echo $DATUM

for i in `ls *${DATUM}\.pat`
do
	echo converting $i in ${i}tern
	./gen-pat $i ${i}tern
	rm $i
done

echo clean up ...
rm wortliste/dehyphn-x* -r

