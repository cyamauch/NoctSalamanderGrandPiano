#!/bin/sh

if [ "$1" = "" ]; then
  echo "[USAGE]"
  echo "$0 directory_name"
  echo "$0 directory_name sfzonly"
  exit
fi

PKG=$1
FLG=$2

if [ -d $PKG ]; then
  cd $PKG
  if [ "$FLG" != "" ]; then
    if [ "$FLG" = "sfzonly" ]; then
      zip -r ../${PKG}.sfz-only.zip *.sfz src -x *_test-only*.sfz
    else
      echo "Invalid arg: $FLG"
      exit 127
    fi
  else
    zip -r ../${PKG}.zip * -x *_test-only*.sfz
  fi
  cd ..
fi




