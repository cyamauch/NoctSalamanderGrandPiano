#!/bin/sh	

if [ "$1" = "" ]; then
  echo "[USAGE]"
  echo "$0 tempo"
  echo "$0 240000"
  echo "Note: 240000 must be set as arg #1"
  echo "Note: Use Accurate-SalamanderGrandPiano_vol-eval-only.sfz for this test!"
  exit
fi

TEMPO=$1

KEY_ID=`cat ../key_n-id_all.txt | awk '{printf("%s,%s\n",$1,$2);}'`

#V3-V4.0
#LIST_VEL="22 30 35 40 45 48 53 60 68 76 84 92 100 108 116 124"

#V4.1-6
LIST_VEL="22 30 35 40 45 50 55 61 68 76 84 92 100 108 116 124"


V=1

for i in $LIST_VEL ; do

  echo "Generating V=$V"

  echo "MFile 1 2 240" > tmp.txt
  echo "MTrk" >> tmp.txt
  echo "0 Tempo ${TEMPO}" >> tmp.txt
  echo "TrkEnd" >> tmp.txt
  echo "MTrk" >> tmp.txt
  echo "0 SysEx f0 41 10 42 12 40 00 7f 00 41 f7" >> tmp.txt

echo $i $KEY_ID | awk '{ \
  split($0,ARR," "); \
  t=0; \
  for ( i=2 ; ARR[i] != "" ; i+=1 ){ \
    split(ARR[i],ARN,","); \
    printf("%d On ch=1 n=%d v=%s\n",t,ARN[2],ARR[1]); \
    t+=1000; \
    printf("%d On ch=1 n=%d v=0\n",t,ARN[2]); \
    t+=2000; \
  } \
}' >> tmp.txt

  echo "TrkEnd" >> tmp.txt

  V0=`echo $V | awk '{printf("%02d\n",$1);}'`

  t2mf tmp.txt > scale_for_eval_v${V0}.mid

  #rm tmp.txt

  V=`expr $V + 1`

done


