#!/bin/sh

if [ "$1" = "" ]; then
    echo "[USAGE]"
    echo "$0 sec"
    echo "$0 1.0"
    exit
fi

SEC=$1

DIR=../../AccurateSalamanderGrandPianoV5.0_48khz24bit/48khz24bit/

PLOT_CMD="plot "

LAYER_LIST="01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16"
#LAYER_LIST="02  06  08  10  14"

for i in $LAYER_LIST ; do

  echo "Measuring velocity: ${i}"

  LIST=`ls $DIR | grep '[0-1][0-9][0-9]_[^_v]*'"v${i}"'[.]wav' | awk '{printf("%s/%s\n","'${DIR}'",$1);}'`

  OUTPUT="meanvol-sec${SEC}_v${i}.txt"
  sh ../measure_volume.sh $SEC $LIST | awk '{printf("%d %s\n",int(substr($1,1,3)),$2);}' > $OUTPUT

  if [ "$i" = "16" ]; then
    PLOT_CMD="$PLOT_CMD '${OUTPUT}' with linesp"
  else
    PLOT_CMD="$PLOT_CMD '${OUTPUT}' with linesp,"
  fi

done

echo $PLOT_CMD > plot_meanvol-sec${SEC}.txt

