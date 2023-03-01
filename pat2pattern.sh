#!/bin/bash

# Tool to for generating coolreader-hyphenation-patterns out of TeX .pat file
# These pattern file is also used for KOReader
# Date: 17. June 2014-2023
# Author: Martin Zwicknagl

INFILE="$1"

if [[ "$1" == "" ]] || [[ "$2" == "" ]] || [[ "$3" == "" ]] ; then
    echo "usage: gen-pattern.sh infile title lang > outfile"
    echo "    infile  ... output of patgen"
    echo "    title ... language in clear form, may contain commata"
    echo "    lang ... ISO 639-1 code of the language (e.g. de, de-AT, de-DE, en, en-UK, ja, zu)"
    echo "    outfile ... crengine pattern file"
    echo ""
    echo "This is a script to convert patgen output to a crengine readable pattern file."
    exit
fi

title="$1"
lang="$2"
lefthyphenmin="$3"
righthyphenmin="$4"

cat <<EOF
<?xml version="1.0" encoding="utf8"?>
<!--
See: http://projekte.dante.de/Trennmuster/WebHome GERMAN-HYPHENATION-PATTERNS

German hyphenations description (modern orphography) for FBReader (original was taken from the teTeX distribution)

###############################################################################
From the original /usr/share/texmf-texlive/tex/generic/hyphen/dehyphn.tex file:

% Copyright (C) 1988,1991 Rechenzentrum der Ruhr-Universitaet Bochum
%               [german hyphen patterns]
% Copyright (C) 1993,1994,1999 Bernd Raichle/DANTE e.V.
%               [macros, adaption for TeX 2]
% Copyright (C) 1998-2001 Walter Schmidt
%               [adaption to new German orthography]
%
% IMPORTANT NOTICE:
%
% This program can be redistributed and/or modified under the terms
% of the LaTeX Project Public License Distributed from CTAN
% archives in directory macros/latex/base/lppl.txt; either
% version 1 of the License, or any later version.

###############################################################################
Information from the original /crengine/Tools/HyphConv/mkpattern.cpp:

All the files *.pattern were produced from the original TeX files. All changes
are the notation changes:
        * we use XML notation (file format is obvious form any sample)
        * '.' in patterns is replaced by ' '
        * all accented characters were written as &xxx; entities, instead of TeX notation
        * all exceptions (\hyphenation{xxx-xx-xx} in TeX notation) were replaced
with the patterns with weights 7 and 8

original Author: Nikolay Pultsin (geometer@fbreader.org)
###############################################################################

preamble from pat-gen by Martin.Zwicknagl@kirchbichl.net
pattern file used: $1

EOF

PREAMBLE=1
while IFS='' read -r line || [[ -n "$line" ]]; do
    if [[ ${PREAMBLE} == "1" && "${line}" == *"\patterns{"* ]]; then
        echo "-->"
        echo ""
        echo '<HyphenationDescription"'
	echo '    title="${title}" lang="${lang}"'
        echo '    lefthyphenmin="${righthyphenmin}" righthyphenmin="${lefthyphenmin}">'
        PREAMBLE=0
        continue
    fi

    if [[ "${PREAMBLE}" == "1" ]]; then
        echo "${line}"
    elif [[ "${line}" =~ }.*|\\.*|%.* ]]; then
		continue
    else
        lnew=$(echo "${line}" | sed -e 's#\.# #g')
        echo "<pattern>${lnew}</pattern>"
    fi
done < "${INFILE}"

echo "</HyphenationDescription>"
echo "" 

