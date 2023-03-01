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

cd wortliste || exit

git fetch
git merge
sleep 4

#backup for git
cp wortliste wortliste.bak

#add my words
cat ../meineWorte/* >> wortliste

# generate exzerpte

if [ 1 -eq 1 ]
then
    #righthyphenmin3
    #~~~~~~~~~~~~~~~
    #Nach alter Buchdruckerregel werden zwei Buchstaben am Wortende nicht abgetrennt.
    #
    #  Fe-bruar, Brause, Fo-lien=her<stel-ler, Abend=er<zäh-lung
    #
    #Anwendung: Blocksatz, mittlere und breite Textspalten; Flattersatz
    echo "Creating exzerpts"
    [[ ! -d exzerpte ]] && mkdir exzerpte
    python skripte/wortliste/sprachauszug.py  -l 'de-1996,de-1996-x-versal' \
        -s 'standard,morphemisch,righthyphenmin3,einfach' < wortliste > exzerpte/de-1996_righthyphenmin3

else
    #hyphenmin3
    #~~~~~~~~~~
    #Keine Trennstellen „in der Nähe“ von „besseren“ Trennstellen.
    #
    #  Abend=erzäh-lung, un<gemüt-lich
    #
    #Anwendung: Flattersatz, Blocksatz in breiten Spalten, Web-Browser
    make exzerpte/de-1996_righthyphenmin3 ## the following command generates
fi

#restore wortliste for git
mv wortliste.bak wortliste

#generate patterns with patgen
cd exzerpte || exit
bash ../skripte/trennmuster/make-full-pattern.sh de-1996_righthyphenmin3 ../daten/german.tr

DATE=$(date '+%Y-%m-%d')
LEFTHYPHENMIN=$(sed 's/^\(..\).*/\1/;q' < ../daten/german.tr)
RIGHTHYPHENMIN=$(sed 's/^..\(..\).*/\1/;q' < ../daten/german.tr)
GIT_VERSION=$(git log --format=%H -1 HEAD --)

cat ../daten/dehyphn-x.1 \
    | sed -e "s/@DATE@/${DATE}/" \
          -e "s/@GIT_VERSION@/${GIT_VERSION}/" \
          -e "s/@LEFTHYPHENMIN@/${LEFTHYPHENMIN}/" \
          -e "s/@RIGHTHYPHENMIN@/${RIGHTHYPHENMIN}/"> de-1996_righthyphenmin3.pat

cat pattern.rules >> de-1996_righthyphenmin3.pat
cat ../daten/dehyphn-x.2 >> de-1996_righthyphenmin3.pat
cat pattern.8 >> de-1996_righthyphenmin3.pat
cat ../daten/dehyphn-x.3 >> de-1996_righthyphenmin3.pat

cp de-1996_righthyphenmin3.pat  ../..

rm pattmp* *.log de-1996_righthyphenmin3*

#back to wortliste
cd ..

#back to hypenation
cd ..

PAT=de-1996_righthyphenmin3-"${DATE}".pat
cp de-1996_righthyphenmin3.pat "${PAT}"
echo "$DATE"

echo converting "$PAT" in "${PAT}"tern
./pat2pattern.sh "$PAT" "German" de 2 3 > patterns/"${PAT}"tern
rm German.pattern
ln -s patterns/"${PAT}"tern German.pattern
ln -s patterns/"${PAT}"tern hyph-de-1996.pattern
echo
echo "Pattern written to patterns/${PAT}tern and linked to German.pattern"
rm "$PAT"

echo clean up ...
rm de-1996_righthyphenmin3.pat
