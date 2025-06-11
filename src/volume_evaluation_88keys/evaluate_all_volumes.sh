#!/bin/sh

if [ "$1" = "" ]; then
  echo "Specify directory"
  exit
fi

DIRNAME=$1

SEC=0.5

PLOT_CMD="plot "

LAYER_LIST="01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16"
#LAYER_LIST="02  06  08  10  14"

for i in $LAYER_LIST ; do

  echo "Measuring velocity: ${i}"

  OUTPUT="${DIRNAME}/meanvol-sec${SEC}_v${i}.txt"

  echo "Output to $OUTPUT"

  rm -f $OUTPUT

  KEY=21
  POS=0
  while [ 1 ]; do
    echo KEY = $KEY
    echo -n "$KEY " >> $OUTPUT
    sh ../volume_measurement/measure_volume.sh $POS $SEC ${DIRNAME}/scale_for_eval_v${i}.wav >> $OUTPUT

    if [ "$KEY" = "108" ]; then
      break
    fi

    KEY=`expr $KEY + 1`
    POS=`expr $POS + 3`
  done

  if [ "$i" = "16" ]; then
    PLOT_CMD="$PLOT_CMD '${OUTPUT}' with linesp title '$i'"
  else
    PLOT_CMD="$PLOT_CMD '${OUTPUT}' with linesp title '$i',"
  fi

done

OUTPUT_PLOT="${DIRNAME}/plot_meanvol-sec${SEC}.txt"

echo "set xlabel 'note-id'" > $OUTPUT_PLOT
echo "set ylabel 'mean-volumne (${SEC} sec.)'" >> $OUTPUT_PLOT
echo "set grid" >> $OUTPUT_PLOT
echo "set xtics 10" >> $OUTPUT_PLOT
#echo "set xrange [19:120]" >> $OUTPUT_PLOT

echo $PLOT_CMD >> $OUTPUT_PLOT

