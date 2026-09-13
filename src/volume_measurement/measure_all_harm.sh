#!/bin/sh

if [ "$1" = "" ]; then
    echo "[USAGE]"
    echo "$0 sec"
    echo "$0 0.5"
    exit
fi

SEC=$1

DIR=../../SalamanderGrandPianoV3_48khz24bit/48khz24bit/
RESULT=harm_vol.txt

echo "Note: Directory is $DIR"
echo "      Output is $RESULT"

PLOT_CMD="plot "

LAYER_LIST="harmL harmS harmV3"

# y = - A * x - (B + B_SPAN * n)
COEFF_A=0.55
COEFF_B=40.0
COEFF_B_SPAN=8.5

VOL_GAIN=12.0

rm -f $RESULT

COUNT=0
for i in $LAYER_LIST ; do

  echo "Measuring layer: ${i}"

  NOTES="A0 C1 D#1 F#1 A1 C2 D#2 F#2 A2 C3 D#3 F#3 A3 C4 D#4 F#4 A4 C5 D#5 F#5 A5 C6 D#6"

  echo $DIR $i $NOTES | awk '{ \
    split($0,ARR," "); \
    for ( i=3 ; i <= length(ARR) ; i++ ) { \
      printf("%s/%s%s.wav\n",$1,$2,ARR[i]); \
    } \
  }' > list_${i}.txt
  LIST=`cat list_${i}.txt`

  #echo $LIST

  OUTPUT="harm_meanvol-sec${SEC}_${i}.txt"
  OUTPUT_MEDIAN="harm_meanvol-sec${SEC}_median.txt"
  sh measure_volume.sh 0 $SEC $LIST > $OUTPUT

  # Get median
  cat $OUTPUT | sort -n | awk '{if(NR==12){print;}}' > $OUTPUT_MEDIAN

  # Get corr. values
  paste list_${i}.txt $OUTPUT | tr '\t' ' ' | awk '{ \
    S=$1 ; \
    gsub(/^.*[\/]/, "", S); \
    printf("%s %g\n", S, ( -'$COEFF_A' * (NR-1) - ('$COEFF_B' + '$COEFF_B_SPAN' * '$COUNT') ) - ($2) + '$VOL_GAIN'); \
  }' >> $RESULT

  if [ "$i" = "harmV3" ]; then
    PLOT_CMD="$PLOT_CMD '${OUTPUT}' with linesp title '$i', -$COEFF_A*x - $COEFF_B, -$COEFF_A*x - ($COEFF_B + 1*$COEFF_B_SPAN), -$COEFF_A*x - ($COEFF_B + 2*$COEFF_B_SPAN)"
  else
    PLOT_CMD="$PLOT_CMD '${OUTPUT}' with linesp title '$i',"
  fi

  echo Median = `cat $OUTPUT_MEDIAN`

  COUNT=`expr $COUNT + 1`

done

OUTPUT_PLOT=plot_orig_harmvol-sec${SEC}.txt

echo "set xlabel 'note-id'" > $OUTPUT_PLOT
echo "set ylabel 'harm-volumne (${SEC} sec.)'" >> $OUTPUT_PLOT
echo "set grid" >> $OUTPUT_PLOT
echo "set xtics 10" >> $OUTPUT_PLOT
#echo "set xrange [19:120]" >> $OUTPUT_PLOT

echo $PLOT_CMD >> $OUTPUT_PLOT

