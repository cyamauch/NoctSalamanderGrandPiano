#!/bin/sh

if [ "$2" = "" ]; then
  echo "[USAGE]"
  echo "$0 directory note-id"
  echo "$0 V6_Accurate 69"
  exit
fi

DIRNAME=$1
NOTE_ID=$2


SEC=0.5

VEL_START=25
VEL_END=122


VEL_ALL=`echo $VEL_START $VEL_END | awk '{ for (i=$1 ; i<=$2 ; i++){ printf("%d ",i); } printf("\n"); }'`

echo "VEL_START : $VEL_START"
echo "VEL_END : $VEL_END"
echo "NOTE_ID : $NOTE_ID"

OUTPUT="${DIRNAME}/all-vel_note${NOTE_ID}.txt"

echo "Output to $OUTPUT"
rm -f $OUTPUT

POS=0

for i in $VEL_ALL ; do

  echo "Measuring velocity: ${i}"

  echo -n "$i " >> $OUTPUT
  sh ./measure_volume.sh $POS $SEC ${DIRNAME}/all-vel-measurement_note${NOTE_ID}.wav >> $OUTPUT

  POS=`expr $POS + 3`

done

