#!/bin/sh

if [ "$1" = "" ]; then
  echo "Specify directory"
  exit
fi

DIRNAME=$1

SEC=0.5

PLOT_CMD="plot "

LAYER_LIST="01 02 03 04 05 06 07 08 09 10 11 12 13 14 15"
#LAYER_LIST="02  06  08  10  14"

for i in $LAYER_LIST ; do

  ii=`echo $i | awk '{printf("%02d\n",$1+1);}'`

  echo "Measuring velocity: ${i}-${ii}"

  OUTPUT="${DIRNAME}/gapvol-sec${SEC}_v${ii}-${i}.txt"

  echo "Output to $OUTPUT"

  rm -f $OUTPUT

  KEY=21
  POS=0
  while [ 1 ]; do
    echo KEY = $KEY
    echo -n "$KEY " >> $OUTPUT

    sh ./measure_volume.sh $POS $SEC ${DIRNAME}/scale_for_gap-measurement_v${i}.wav > _tmp_v_.txt

    POS=`expr $POS + 3`

    sh ./measure_volume.sh $POS $SEC ${DIRNAME}/scale_for_gap-measurement_v${i}.wav >> _tmp_v_.txt

    cat _tmp_v_.txt | awk '{ if (NR==1) {V=$1;} else { printf("%g\n",$1-V); } }' >> $OUTPUT

    if [ "$KEY" = "108" ]; then
      break
    fi

    KEY=`expr $KEY + 3`
    POS=`expr $POS + 3`
  done

  if [ "$i" = "01" ]; then
    PLOT_CMD="${PLOT_CMD} '${OUTPUT}' with linesp title '$i'"
  else
    PLOT_CMD="${PLOT_CMD}, '${OUTPUT}' with linesp title '$i'"
  fi

done

OUTPUT_PLOT="${DIRNAME}/plot_gapvol-sec${SEC}.txt"

echo "set xlabel 'note-id'" > $OUTPUT_PLOT
echo "set ylabel 'gap-volumne (${SEC} sec.)'" >> $OUTPUT_PLOT
echo "set grid" >> $OUTPUT_PLOT
echo "set xtics 10" >> $OUTPUT_PLOT
#echo "set xrange [19:120]" >> $OUTPUT_PLOT

echo $PLOT_CMD >> $OUTPUT_PLOT

