#!/bin/sh

MF2T="mf2t"
T2MF="t2mf"

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
    if ( $2 == "Meta" && ($4 == "\"<Master" || $4 == "\"<part") && ($5 == "Reverve>\"" || $5 == "Volume>\"" || $5 == "reverve>\"") ) { FLG=1; } \
    else { \
      if ( FLG == 1 ) { \
        if ( $2 == "SysEx" ) {FLG=1;} \
        else {FLG=0; print;} \
      } \
      else { \
        if ( ($2 == "Par" && $4 == "c=64" && substr($5,1,2) == "v=") && 0 ) { \
          V=int(substr($5,3)); \
          if ( V < 64 ) { printf("%s %s %s %s v=0\n",$1,$2,$3,$4); } \
          else { printf("%s %s %s %s v=127\n",$1,$2,$3,$4); } \
        } \
        else { \
          if ( $2 == "Par" && substr($4,1,2) == "c=" ) { \
            if ( $4 == "c=64" || $4 == "c=67" ) { print; } \
          } \
          else { \
            if ( ($2 == "On" && $5 == "v=0") && 0 ) { printf("%s Off %s %s %s\n",$1,$3,$4,$5); } \
            else { print; } \
          } \
        } \
      } \
    } \
  }' > _tmp_output.txt

  echo "output to $OUTFILENAME"
  $T2MF _tmp_output.txt > $OUTFILENAME

  #rm _tmp_input.txt _tmp_output.txt

  shift

done

