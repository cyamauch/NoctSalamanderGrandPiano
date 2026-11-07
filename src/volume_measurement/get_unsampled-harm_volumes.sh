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

DIR=../../AccurateSalamanderGrandPianoV6.2c_48khz24bit/48khz24bit/


#cat typical.sfz | grep 'sample=[^ ]*[01][0-9][0-9]_[^ ][^ ]*[.]wav' | sed -e 's/^[^\\][^\\]*[\\]//'

FS_WORK=96000

SPAN=0.5

# Offset volume (db) to calcuate correction value
OFFSET_DB=0.5
#OFFSET_DB=1.0

WORK_DIR=wav_work

mkdir -p $WORK_DIR

echo "Using offset value ${OFFSET_DB}db to calcuate correction value."

LIST="A0 C1 D#1 F#1 A1 C2 D#2 F#2 A2 C3 D#3 F#3 A3 C4 D#4 F#4 A4 C5 D#5 F#5 A5 C6 D#6"

OUTPUT_FILE=unsampled-harm_volumes.txt

rm -f $OUTPUT_FILE

for i in harmL harmS harmV3 ; do

  RESULT_ALL=""

  for j in $LIST ; do

    IN_FILE_1_ORG=${i}${j}.wav
    IN_FILE_1=${WORK_DIR}/${i}${j}.wav
    rm -f $IN_FILE_1
    "$FFMPEG" -i $DIR/$IN_FILE_1_ORG -ar $FS_WORK -ss 0 -to 2 -c:a pcm_f32le $IN_FILE_1 2> /dev/null

    if [ "$j" != "A0" ]; then
      IN_FILE_0_ORG=${i}${PREV}.wav
      IN_FILE_0=${WORK_DIR}/${i}${PREV}.wav
      #
      echo "Processing ..." $IN_FILE_0_ORG "- -" $IN_FILE_1_ORG
      #
      sh measure_volume.sh 0 $SPAN $IN_FILE_0 $IN_FILE_1 | \
         awk '{ if ( NR == 1 ) { vol0=$1; } else { printf("%g %g\n", vol0 + ($1 - vol0) * (1.0/3.0), vol0 + ($1 - vol0) * (2.0/3.0) ); } }' > _tmp_vol_pairs.txt
      #
      VOL_GOAL=`cat _tmp_vol_pairs.txt | awk '{print $1;}'`
      TUNE_BY_SCALE=+1
      TUNE_BY_CENT=0
      FILTER_ASETRATE=`echo $FS_WORK $TUNE_BY_SCALE $TUNE_BY_CENT | awk '{printf("asetrate=%g\n",$1 * 2.0^((100.0 * ($2) + $3)/1200.0));}'`
      #
      rm -f _tmp_out_0.wav
      "$FFMPEG" -i $IN_FILE_0 -af ${FILTER_ASETRATE},volume=-${OFFSET_DB}dB -ss 0 -to $SPAN -c:a pcm_f32le _tmp_out_0.wav 2> /dev/null
      VOL_P0=`sh measure_volume.sh 0 $SPAN _tmp_out_0.wav`
      #
      rm -f _tmp_out_1.wav
      "$FFMPEG" -i $IN_FILE_0 -af ${FILTER_ASETRATE},volume=+${OFFSET_DB}dB -ss 0 -to $SPAN -c:a pcm_f32le _tmp_out_1.wav 2> /dev/null
      VOL_P1=`sh measure_volume.sh 0 $SPAN _tmp_out_1.wav`
      RESULT_0=`echo $VOL_P0 $VOL_P1 $VOL_GOAL $OFFSET_DB | awk '{range=$2-$1; printf("%g\n", -1 * $4 + (2 * $4)*((($3)-($1))/range));}'`
      #
      rm -f _tmp_out_2.wav
      "$FFMPEG" -i $IN_FILE_0 -af ${FILTER_ASETRATE},volume=${RESULT_0}dB -ss 0 -to $SPAN -c:a pcm_f32le _tmp_out_2.wav 2> /dev/null
      CHK="`sh measure_volume.sh 0 $SPAN _tmp_out_2.wav`"
      #
      ERR=`echo $CHK $VOL_GOAL | awk '{printf("%g\n",($1) - ($2));}'`
      echo "Err: $ERR  Goal: $VOL_GOAL  Result: $RESULT_0"
      #
      #
      VOL_GOAL=`cat _tmp_vol_pairs.txt | awk '{print $2;}'`
      TUNE_BY_SCALE=-1
      TUNE_BY_CENT=0
      FILTER_ASETRATE=`echo $FS_WORK $TUNE_BY_SCALE $TUNE_BY_CENT | awk '{printf("asetrate=%g\n",$1 * 2.0^((100.0 * ($2) + $3)/1200.0));}'`
      #
      rm -f _tmp_out_0.wav
      "$FFMPEG" -i $IN_FILE_1 -af ${FILTER_ASETRATE},volume=-${OFFSET_DB}dB -ss 0 -to $SPAN -c:a pcm_f32le _tmp_out_0.wav 2> /dev/null
      VOL_P0=`sh measure_volume.sh 0 $SPAN _tmp_out_0.wav`
      #
      rm -f _tmp_out_1.wav
      "$FFMPEG" -i $IN_FILE_1 -af ${FILTER_ASETRATE},volume=+${OFFSET_DB}dB -ss 0 -to $SPAN -c:a pcm_f32le _tmp_out_1.wav 2> /dev/null
      VOL_P1=`sh measure_volume.sh 0 $SPAN _tmp_out_1.wav`
      RESULT_1=`echo $VOL_P0 $VOL_P1 $VOL_GOAL $OFFSET_DB | awk '{range=$2-$1; printf("%g\n", -1 * $4 + (2 * $4)*((($3)-($1))/range));}'`
      #
      rm -f _tmp_out_2.wav
      "$FFMPEG" -i $IN_FILE_1 -af ${FILTER_ASETRATE},volume=${RESULT_1}dB -ss 0 -to $SPAN -c:a pcm_f32le _tmp_out_2.wav 2> /dev/null
      CHK="`sh measure_volume.sh 0 $SPAN _tmp_out_2.wav`"
      #
      ERR=`echo $CHK $VOL_GOAL | awk '{printf("%g\n",($1) - ($2));}'`
      echo "Err: $ERR  Goal: $VOL_GOAL  Result: $RESULT_1"

      RESULT_ALL="${RESULT_ALL} ${RESULT_0},${RESULT_1}"

    fi

    PREV=$j

  done

  echo "${i} ${RESULT_ALL} " >> $OUTPUT_FILE

done

cp -p $OUTPUT_FILE ..

