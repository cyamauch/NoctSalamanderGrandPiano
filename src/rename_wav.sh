#!/bin/sh

KEY_NID_TXT=`cat key_n-id.txt | tr -d '\r' | sed -e 's/^[ ]*//'`

ARG_OUTFILE_SED_0=`echo "$KEY_NID_TXT" | awk '{printf("-e s/%sv/%s_%sv/ \n",$1,$2,$1);}'`
ARG_OUTFILE_SED_1=`echo "1_2_3_4_5_6_7_8_9_" | tr '_' '\n' | awk '{printf("-e s/v%s[.]wav/v0%s.wav/ \n",$1,$1);}'`
ARG_OUTFILE_SED=`echo "$ARG_OUTFILE_SED_0" "$ARG_OUTFILE_SED_1"`

while [ "$1" != "" ]; do

  F=`echo $1 | grep '[ACFD][#]*[0-8]v[1-9][0-6]*[.]wav'`
  if [ "$F" != "" ]; then
    TO_NAME=`echo $1 | sed $ARG_OUTFILE_SED`
    echo $1 '->' $TO_NAME
    mv $1 $TO_NAME
  fi

  shift

done

