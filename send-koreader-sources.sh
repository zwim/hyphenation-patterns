#!/bin/bash

if [[ "$1" == "" ]]; then
  echo USAGE: send-koreader-sources.sh pattern
  exit 1
fi

cp $1 ../koreader/base/thirdparty/kpvcrlib/crengine/cr3gui/data/hyph/German.pattern
ls -al $1
ls -al ../koreader/base/thirdparty/kpvcrlib/crengine/cr3gui/data/hyph/German.pattern
