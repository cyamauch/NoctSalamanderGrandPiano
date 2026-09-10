#!/bin/sh

if [ "$2" = "" ]; then
  echo "[USAGE]"
  echo "$0 directory note-id"
  echo "$0 V6.2_Accurate_sforzando 69"
  echo ""
  echo "[NOTE]"
  echo "Before using this tool:"
  echo "- To create MIDI file:"
  echo "  sh make_all_vel_measurement_midi.sh 240000 69"
  echo "- Convert all-vel-measurement_note69.mid to all-vel-measurement_note69.wav"
  echo "  using sforzando."
  exit
fi

DIRNAME=$1
NOTE_ID=$2


SEC=0.5

VEL_START=1
VEL_END=126


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

