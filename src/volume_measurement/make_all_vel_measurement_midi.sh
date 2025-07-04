#!/bin/sh	

if [ "$2" = "" ]; then
  echo "[USAGE]"
  echo "$0 tempo note-id"
  echo "$0 240000 69"
  echo "Note: 240000 must be set as arg #1"
  echo "Note: Use *-SalamanderGrandPiano_vol-eval-only.sfz for this test!"
  exit
fi


TEMPO=$1
NOTE_ID=$2

VEL_START=25
VEL_END=122


echo "MFile 1 2 240" > tmp.txt
echo "MTrk" >> tmp.txt
echo "0 Tempo ${TEMPO}" >> tmp.txt
echo "TrkEnd" >> tmp.txt
echo "MTrk" >> tmp.txt
echo "0 SysEx f0 41 10 42 12 40 00 7f 00 41 f7" >> tmp.txt

echo $NOTE_ID $VEL_START $VEL_END | awk '{ \
  t=0; \
  for ( i=$2 ; i <= $3 ; i+=1 ){ \
    printf("%d On ch=1 n=%d v=%s\n",t,$1,i); \
    t+=1000; \
    printf("%d On ch=1 n=%d v=0\n",t,$1); \
    t+=2000; \
  } \
}' >> tmp.txt

echo "TrkEnd" >> tmp.txt

t2mf tmp.txt > all-vel-measurement_note${NOTE_ID}.mid

#rm tmp.txt

