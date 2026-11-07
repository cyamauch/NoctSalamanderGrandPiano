#!/bin/sh

if [ "$1" = "" ]; then
    echo "[USAGE]"
    echo "$0 sec"
    echo "$0 0.5"
    exit
fi

SEC=$1

#DIR=../../SalamanderGrandPianoV3_48khz24bit/48khz24bit/
#DIR=../harm_corr/
#DIR=../../AccurateSalamanderGrandPianoV6.2a_48khz24bit/48khz24bit
DIR=../../AccurateSalamanderGrandPianoV6.2c_48khz24bit/48khz24bit

echo "Note: Directory is $DIR"

LAYER_LIST="harmL harmS harmV3"

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

  OUTPUT="tmp_harm_meanvol.txt"
  OUTPUT_MEDIAN="tmp_harm_meanvol_median.txt"
  sh measure_volume.sh 0 $SEC $LIST > $OUTPUT

  # Get median
  cat $OUTPUT | sort -n | awk '{if(NR==12){print;}}' > $OUTPUT_MEDIAN

  # Output results
  paste list_${i}.txt $OUTPUT | tr '\t' ' ' | awk '{ \
    S=$1 ; \
    gsub(/^.*[\/]/, "", S); \
    printf("%s %g\n", S, $2); \
  }'

  echo Median = `cat $OUTPUT_MEDIAN`

done

