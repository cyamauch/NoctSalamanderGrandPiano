#!/bin/sh

if [ -f ../ffmpeg_path.txt ]; then
  FFMPEG="`cat ../ffmpeg_path.txt`"
else
  echo "ERROR: Not found ffmpeg_path.txt" 1>&2
  exit 127
fi

# "C:" -> "/cygdrive/c" for cygwin
if [ "$OSTYPE" = "cygwin" ]; then
  FFMPEG="`echo $FFMPEG | sed -e 's/C:/\/cygdrive\/c/'`"
fi

if [ ! -x "$FFMPEG" ]; then
  echo "Not found: $FFMPEG" 1>&2
  exit 127
fi

DIR=../../AccurateSalamanderGrandPianoV6.0_48khz24bit/48khz24bit/


#cat typical.sfz | grep 'sample=[^ ]*[01][0-9][0-9]_[^ ][^ ]*[.]wav' | sed -e 's/^[^\\][^\\]*[\\]//'

FS_SRC=48000

SPAN=0.5


LIST=`cat ../key_n-id.txt | awk '{printf("%s_%s\n",$2,$1);}'`

rm unsampled_volumes.txt

for i in 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 ; do

  RESULT_ALL=""

  for j in $LIST ; do

    if [ "$j" != "021_A0" ]; then
      IN_FILE_0=${PREV}v${i}.wav
      IN_FILE_1=${j}v${i}.wav
      #
      echo "Processing ..." $IN_FILE_0 "- -" $IN_FILE_1
      #
      sh measure_volume.sh $SPAN $DIR/$IN_FILE_0 $DIR/$IN_FILE_1 | \
         awk '{ if ( NR == 1 ) { vol0=$2; } else { printf("%g %g\n", vol0 + ($2 - vol0) * (1.0/3.0), vol0 + ($2 - vol0) * (2.0/3.0) ); } }' > _tmp_vol_pairs.txt
      #
      VOL_GOAL=`cat _tmp_vol_pairs.txt | awk '{print $1;}'`
      TUNE_BY_SCALE=+1
      TUNE_BY_CENT=0
      FILTER_ASETRATE=`echo $FS_SRC $TUNE_BY_SCALE $TUNE_BY_CENT | awk '{printf("asetrate=%g\n",$1 * 2.0^((100.0 * $2 + $3)/1200.0));}'`
      #
      rm -f _tmp_out_0.wav
      "$FFMPEG" -i $DIR/$IN_FILE_0 -af ${FILTER_ASETRATE},volume=-0.5dB -ss 0 -to $SPAN -c:a pcm_f32le _tmp_out_0.wav 2> /dev/null
      VOL_P0=`sh measure_volume.sh $SPAN _tmp_out_0.wav`
      #
      rm -f _tmp_out_1.wav
      "$FFMPEG" -i $DIR/$IN_FILE_0 -af ${FILTER_ASETRATE},volume=+0.5dB -ss 0 -to $SPAN -c:a pcm_f32le _tmp_out_1.wav 2> /dev/null
      VOL_P1=`sh measure_volume.sh $SPAN _tmp_out_1.wav`
      echo "Goal: "$VOL_GOAL
      RESULT_0=`echo $VOL_P0 $VOL_P1 $VOL_GOAL | awk '{range=$2-$1; printf("%g\n", -0.5 + 1.0*(($3-$1)/range));}'`
      echo "Result: "$RESULT_0
      #
      rm -f _tmp_out_2.wav
      "$FFMPEG" -i $DIR/$IN_FILE_0 -af ${FILTER_ASETRATE},volume=${RESULT_0}dB -ss 0 -to $SPAN -c:a pcm_f32le _tmp_out_2.wav 2> /dev/null
      echo "Check[0]: "`sh measure_volume.sh $SPAN _tmp_out_2.wav`
      #
      #
      VOL_GOAL=`cat _tmp_vol_pairs.txt | awk '{print $2;}'`
      TUNE_BY_SCALE=-1
      TUNE_BY_CENT=0
      FILTER_ASETRATE=`echo $FS_SRC $TUNE_BY_SCALE $TUNE_BY_CENT | awk '{printf("asetrate=%g\n",$1 * 2.0^((100.0 * $2 + $3)/1200.0));}'`
      #
      rm -f _tmp_out_0.wav
      "$FFMPEG" -i $DIR/$IN_FILE_1 -af ${FILTER_ASETRATE},volume=-0.5dB -ss 0 -to $SPAN -c:a pcm_f32le _tmp_out_0.wav 2> /dev/null
      VOL_P0=`sh measure_volume.sh $SPAN _tmp_out_0.wav`
      #
      rm -f _tmp_out_1.wav
      "$FFMPEG" -i $DIR/$IN_FILE_1 -af ${FILTER_ASETRATE},volume=+0.5dB -ss 0 -to $SPAN -c:a pcm_f32le _tmp_out_1.wav 2> /dev/null
      VOL_P1=`sh measure_volume.sh $SPAN _tmp_out_1.wav`
      echo "Goal: "$VOL_GOAL
      RESULT_1=`echo $VOL_P0 $VOL_P1 $VOL_GOAL | awk '{range=$2-$1; printf("%g\n", -0.5 + 1.0*(($3-$1)/range));}'`
      echo "Result: "$RESULT_1
      #
      rm -f _tmp_out_2.wav
      "$FFMPEG" -i $DIR/$IN_FILE_1 -af ${FILTER_ASETRATE},volume=${RESULT_1}dB -ss 0 -to $SPAN -c:a pcm_f32le _tmp_out_2.wav 2> /dev/null
      echo "Check[1]: "`sh measure_volume.sh $SPAN _tmp_out_2.wav`

      RESULT_ALL="${RESULT_ALL} ${RESULT_0},${RESULT_1}"

    fi

    PREV=$j

  done

  echo "${i} ${RESULT_ALL} " >> unsampled_volumes.txt

done



