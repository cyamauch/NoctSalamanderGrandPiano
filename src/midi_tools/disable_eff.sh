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

  cat _tmp_input.txt | awk '{ \
    if ( $4 == "\"<Master" && ($5 == "Reverve>\"" || $5 == "Volume>\"") ) { FLG=1; } \
    else { \
      if ( FLG == 1 ) { \
        if ( $2 == "SysEx" ) {FLG=1;} \
        else {FLG=0; print;} \
      } \
      else { \
        if ( $2 == "Par" && $4 == "c=64" && substr($5,1,2) == "v=" ) { \
          V=int(substr($5,3)); \
          if ( V < 64 ) { printf("%s %s %s %s v=0\n",$1,$2,$3,$4); } \
          else { printf("%s %s %s %s v=127\n",$1,$2,$3,$4); } \
        } \
        else { \
          if ( $2 == "Par" && substr($4,1,2) == "c=" ) { \
            if ( $4 == "c=67" ) { print; } \
          } \
          else { \
            if ( ($2 == "On" && $5 == "v=0") && 0 ) { printf("%s Off %s %s %s\n",$1,$3,$4,$5); } \
            else { print; } \
          } \
        } \
      } \
    } \
  }' > _tmp_output.txt

  $T2MF _tmp_output.txt > $OUTFILENAME

  #rm _tmp_input.txt _tmp_output.txt

  shift

done

