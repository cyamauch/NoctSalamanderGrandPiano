#!/bin/sh

PKG=$1
if [ -d $PKG ]; then
  cd $PKG
  zip -r ../${PKG}.zip *
  cd ..
fi




