#!/bin/sh

MF2T="/cygdrive/c/archives/Piano/mf2t-win64/mf2t.exe"
T2MF="/cygdrive/c/archives/Piano/mf2t-win64/t2mf.exe"

if [ "$1" = "" ]; then
  echo "Specify midi files."
  exit
fi

while [ "$1" != "" ]; do

  OUTBASENAME=`echo $1 | sed -e 's/[.][^.][^.]*$//'`
  OUTSUFFIX=`echo $1 | sed -e 's/^.*[.]//'`
  OUTFILENAME=${OUTBASENAME}_no-eff.${OUTSUFFIX}

  $MF2T $1 | tr -d '\r' > _tmp_input.txt

  cat _tmp_input.txt | tr -d '\r' | awk '{ \
    if ( $4 == "\"<Master" && ($5 == "Reverve>\"" || $5 == "Volume>\"") ) { FLG=1; } \
    else { \
      if ( FLG == 1 ) { \
        if ( $2 == "SysEx" ) {FLG=1;} \
        else {FLG=0; print;} \
      } \
      else {print;} \
    } \
  }' > _tmp_output.txt

  $T2MF _tmp_output.txt > $OUTFILENAME

  #rm _tmp_input.txt _tmp_output.txt

  shift

done

