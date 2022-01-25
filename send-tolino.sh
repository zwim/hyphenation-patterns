#!/bin/bash

#adb push $1 /mnt/sdcard/.cr3/hyph/
cp $1 $1.tmp
adb push $1.tmp /sdcard/koreader/hyph/German.pattern
rm $1.tmp
