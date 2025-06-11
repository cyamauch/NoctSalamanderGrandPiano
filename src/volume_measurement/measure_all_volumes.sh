#!/bin/sh

if [ "$1" = "" ]; then
    echo "[USAGE]"
    echo "$0 sec"
    echo "$0 1.0"
    exit
fi

SEC=$1

DIR=../../AccurateSalamanderGrandPianoV6.0_48khz24bit/48khz24bit/

echo "Note: Directory is $DIR"

PLOT_CMD="plot "

LAYER_LIST="01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16"
#LAYER_LIST="02  06  08  10  14"

for i in $LAYER_LIST ; do

  echo "Measuring velocity: ${i}"

  LIST=`ls $DIR | grep '[0-1][0-9][0-9]_[^_v]*'"v${i}"'[.]wav' | awk '{printf("%s/%s\n","'${DIR}'",$1);}'`
  #LIST=`ls $DIR | grep '[0][23][0-9]_[^_v]*'"v${i}"'[.]wav' | awk '{printf("%s/%s\n","'${DIR}'",$1);}'`
  #LIST=`ls $DIR | grep '[0][3456][0-9]_[^_v]*'"v${i}"'[.]wav' | awk '{printf("%s/%s\n","'${DIR}'",$1);}'`
  #LIST=`ls $DIR | grep '[01][06789][0-9]_[^_v]*'"v${i}"'[.]wav' | awk '{printf("%s/%s\n","'${DIR}'",$1);}'`
  #LIST=`ls $DIR | grep '[01][0789][0-9]_[^_v]*'"v${i}"'[.]wav' | awk '{printf("%s/%s\n","'${DIR}'",$1);}'`
  #LIST=`ls $DIR | grep '[0][789][0-9]_[^_v]*'"v${i}"'[.]wav' | awk '{printf("%s/%s\n","'${DIR}'",$1);}'`

  OUTPUT="meanvol-sec${SEC}_v${i}.txt"
  sh measure_volume.sh 0 $SEC $LIST > $OUTPUT

  if [ "$i" = "16" ]; then
    PLOT_CMD="$PLOT_CMD '${OUTPUT}' with linesp title '$i'"
  else
    PLOT_CMD="$PLOT_CMD '${OUTPUT}' with linesp title '$i',"
  fi

done

OUTPUT_PLOT=plot_meanvol-sec${SEC}.txt

echo "set xlabel 'note-id'" > $OUTPUT_PLOT
echo "set ylabel 'mean-volumne (${SEC} sec.)'" >> $OUTPUT_PLOT
echo "set grid" >> $OUTPUT_PLOT
echo "set xtics 10" >> $OUTPUT_PLOT
#echo "set xrange [19:120]" >> $OUTPUT_PLOT

echo $PLOT_CMD >> $OUTPUT_PLOT

