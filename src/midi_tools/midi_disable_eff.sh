#!/bin/sh

MF2T="mf2t"
T2MF="t2mf"

if [ "$1" = "" ]; then
  echo "[USAGE]"
  echo "$0 [-r] [-v] [-h] [-p] a.mid b.mid ..."
  echo " -r ... remove reverve controls"
  echo " -v ... remove volume controls"
  echo " -h ... remove half pedal"
  echo " -p ... remove CC exept CC64/CC67"
  exit
fi

REMOVE_REVERVE=0
REMOVE_VOLUME=0
REMOVE_HALF_PEDAL=0
REMOVE_CC_EXEPT_64_67=0

while [ "$1" != "" ]; do

  if [ "$1" = "-r" ]; then
    REMOVE_REVERVE=1
  elif [ "$1" = "-v" ]; then
    REMOVE_VOLUME=1
  elif [ "$1" = "-h" ]; then
    REMOVE_HALF_PEDAL=1
  elif [ "$1" = "-p" ]; then
    REMOVE_CC_EXEPT_64_67=1
  else
    break
  fi

  shift

done


while [ "$1" != "" ]; do

  OUTBASENAME=`echo $1 | sed -e 's/[.][^.][^.]*$//'`
  OUTSUFFIX=`echo $1 | sed -e 's/^.*[.]//'`
  OUTFILENAME=${OUTBASENAME}_no-eff.${OUTSUFFIX}

  $MF2T $1 | tr -d '\r' > _tmp_input.txt

  cat _tmp_input.txt | awk '{ \
    if ( ($2 == "Meta" && $4 == "\"<Master" && $5 == "Reverve>\"") && '$REMOVE_REVERVE' ) { FLG=1; } \
    else if ( ($2 == "Meta" && $4 == "\"<Master" && $5 == "Volume>\"") && '$REMOVE_VOLUME' ) { FLG=2; } \
    else if ( ($2 == "Meta" && $4 == "\"<part" && $5 == "reverve>\"") && '$REMOVE_REVERVE' ) { FLG=3; } \
    else if ( FLG == 1 ) { \
      if ( $2 == "SysEx" ) {FLG=1;} \
      else {FLG=0; print;} \
    } \
    else if ( FLG == 2 ) { \
      if ( $2 == "SysEx" ) {FLG=2;} \
      else {FLG=0; print;} \
    } \
    else if ( FLG == 3 ) { \
      if ( $2 == "Par" && ( int(substr($4,3)) == 6 || 91 <= int(substr($4,3)) ) ) {FLG=3;} \
      else {FLG=0; print;} \
    } \
    else if ( ($2 == "Par" && $4 == "c=64" && substr($5,1,2) == "v=") && '$REMOVE_HALF_PEDAL' ) { \
      V=int(substr($5,3)); \
      if ( V < 64 ) { printf("%s %s %s %s v=0\n",$1,$2,$3,$4); } \
      else { printf("%s %s %s %s v=127\n",$1,$2,$3,$4); } \
    } \
    else if ( ($2 == "Par" && substr($4,1,2) == "c=") && '$REMOVE_CC_EXEPT_64_67' ) { \
      if ( $4 == "c=64" || $4 == "c=67" ) { print; } \
    } \
    else if ( ($2 == "On" && $5 == "v=0") && 0 ) { \
      printf("%s Off %s %s %s\n",$1,$3,$4,$5); \
    } \
    else { \
      print; \
    } \
  }' > _tmp_output.txt

  echo "output to $OUTFILENAME"
  $T2MF _tmp_output.txt > $OUTFILENAME

  #rm _tmp_input.txt _tmp_output.txt

  shift

done

