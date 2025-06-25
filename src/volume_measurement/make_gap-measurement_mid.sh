#!/bin/sh	

if [ "$1" = "" ]; then
  echo "[USAGE]"
  echo "$0 tempo"
  echo "$0 240000"
  echo "Note: 240000 must be set as arg #1"
  echo "Note: Use *-SalamanderGrandPiano_vol-eval-only.sfz for this test!"
  exit
fi

TEMPO=$1

KEY_ID=`cat ../key_n-id.txt | awk '{printf("%s,%s\n",$1,$2);}'`

#V3-V4.0
#LIST_VEL="26 34 36 43 46 50 56 64 72 80 88 96 104 112 120"

#V4.1-6
LIST_VEL="26 33 37 43 47 52 58 64 72 80 88 96 104 112 120"


V=1

for i in $LIST_VEL ; do

  V_VAL=$i

  # TEST of automatic volume
  #V_VAL=`expr $i + 1`

  echo "Generating V=$V"

  echo "MFile 1 2 240" > tmp.txt
  echo "MTrk" >> tmp.txt
  echo "0 Tempo ${TEMPO}" >> tmp.txt
  echo "TrkEnd" >> tmp.txt
  echo "MTrk" >> tmp.txt
  echo "0 SysEx f0 41 10 42 12 40 00 7f 00 41 f7" >> tmp.txt

echo $V_VAL $KEY_ID | awk '{ \
  split($0,ARR," "); \
  t=0; \
  for ( i=2 ; ARR[i] != "" ; i+=1 ){ \
    split(ARR[i],ARN,","); \
    printf("%d On ch=1 n=%d v=%s\n",t,ARN[2],ARR[1]); \
    t+=1000; \
    printf("%d On ch=1 n=%d v=0\n",t,ARN[2]); \
    t+=2000; \
    printf("%d On ch=1 n=%d v=%s\n",t,ARN[2],ARR[1]+1); \
    t+=1000; \
    printf("%d On ch=1 n=%d v=0\n",t,ARN[2]); \
    t+=2000; \
  } \
}' >> tmp.txt

  echo "TrkEnd" >> tmp.txt

  V0=`echo $V | awk '{printf("%02d\n",$1);}'`

  t2mf tmp.txt > scale_for_gap-measurement_v${V0}.mid

  #rm tmp.txt

  V=`expr $V + 1`

done


