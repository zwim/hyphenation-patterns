#!/bin/bash

echo checking for patgen
which patgen
if [[ $? -ne 0 ]];
then
    echo
    echo "patgen program is missing."
    echo "Either install it or install texlive."
    exit
fi

cd wortliste

git fetch
sleep 4

#backup for git
cp wortliste wortliste.bak

#add my words
cat ../meineWorte/* >> wortliste

#make wordlist
make exzerpte/de-1996_hyphenmin3

#restore wortliste for git
mv wortliste.bak wortliste

#generate patterns with patgen
cd exzerpte
bash ../skripte/trennmuster/make-full-pattern.sh de-1996_hyphenmin3 ../daten/german.tr

DATE=$(date '+%Y-%m-%d')
LEFTHYPHENMIN=$(sed 's/^\(..\).*/\1/;q' < ../daten/german.tr)
RIGHTHYPHENMIN=$(sed 's/^..\(..\).*/\1/;q' < ../daten/german.tr)
GIT_VERSION=$(git log --format=%H -1 HEAD --)

cat ../daten/dehyphn-x.1 \
    | sed -e "s/@DATE@/${DATE}/" \
          -e "s/@GIT_VERSION@/${GIT_VERSION}/" \
          -e "s/@LEFTHYPHENMIN@/${LEFTHYPHENMIN}/" \
          -e "s/@RIGHTHYPHENMIN@/${RIGHTHYPHENMIN}/"> de-1996_hyphenmin3.pat

#echo "% HYPENMIN3" >> de-1996_hyphenmin3.pat
cat pattern.rules >> de-1996_hyphenmin3.pat
cat ../daten/dehyphn-x.2 >> de-1996_hyphenmin3.pat
cat pattern.8 >> de-1996_hyphenmin3.pat
cat ../daten/dehyphn-x.3 >> de-1996_hyphenmin3.pat

cp de-1996_hyphenmin3.pat  ../..

rm pattmp* *.log de-1996_hyphenmin3*

#back to wortliste
cd ..

#back to hypenation
cd ..

DATUM=`date +%Y-%m-%d`

PAT=de-1996_hyphenmin3-"${DATE}".pat
cp de-1996_hyphenmin3.pat de-1996_hyphenmin3-${DATUM}.pat
echo $DATUM

echo converting "$PAT" in "${PAT}"tern
./pat2pattern.sh "$PAT" > patterns/"${PAT}"tern
rm German.pattern
ln -s patterns/"${PAT}"tern German.pattern
echo
echo "Pattern written to patterns/${PAT}tern and linked to German.pattern"
rm "$PAT"

echo clean up ...
rm de-1996_hyphenmin3.pat

