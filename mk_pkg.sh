#!/bin/sh

if [ "$1" = "" ]; then
  echo "[USAGE]"
  echo "$0 directory_name"
  exit
fi

PKG=$1

if [ -d $PKG ]; then
  cd $PKG
  zip -r ../${PKG}.zip *
  cd ..
fi




