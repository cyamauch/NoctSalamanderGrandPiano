#!/bin/sh

#
# $1...filename  $2...track No.
#
func_output_main ()
{
  cat $1 | awk '{ \
    if ( $0 == "MTrk" ) { TRK++; } \
    else { \
      if ( $0 == "TrkEnd" ) { TEND++; } \
      else { \
        if (TRK == '$2') { print; } \
      } \
    } \
  }'
}

MF2T="mf2t"
T2MF="t2mf"

if [ "$3" == "" ]; then
  echo "[USAGE]"
  echo "$0 2 1 filename.mid"
  echo "$0 track_number ch_number filename.mid"
  exit
fi

TRK_ID=$1
CH_ID=$2
INNAME=$3


$MF2T $INNAME | tr -d "\r" > _tmp_input.txt

TRK=0
CNT_TRK=0
while [ 1 ]; do

  TRK=`expr $TRK + 1`

  func_output_main _tmp_input.txt ${TRK} > _tmp_${TRK}.txt

  if [ "${TRK_ID}" = "${TRK}" ]; then
    cat _tmp_${TRK}.txt | awk '{ if ( $2 == "On" && $3 == "ch='$CH_ID'" && substr($4,1,2) == "n=" && $5 != "v=0" ) { printf("%s %s\n",$1,substr($5,3)); } }'
  fi

  N=`cat _tmp_${TRK}.txt | wc -l`
  if [ $N = 0 ]; then
    break
  else
    CNT_TRK=$TRK
  fi

  #echo "PHASE1 -- TRK: $TRK"

done

