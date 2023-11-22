#!/bin/sh

########################################################
#                                                      #
#     Main script for Noct-Salamander Grand Piano.     #
#                                                      #
#                        (C) 2023 Chisato Yamauchi     #
#                                                      #
########################################################

#### This script can be used under Cygwin Terminal. ####


#### Set your ffmpeg.exe.  Native Windows binary is OK. ####

FFMPEG="/cygdrive/c/archives/Piano/VirtualMIDISynth/ffmpeg-master-latest-win64-gpl/bin/ffmpeg.exe"


if [ "$2" == "" ]; then
  echo "[USAGE]"
  echo "$0 SRC_DIR DEST_DIR"
  exit
fi


SRC_DIR=$1
DEST_DIR=$2


#### FLAG for wav creation ####

FLAG_CREATE_WAV=1

#### for LPF to cut very high freq. ####

FREQ_ZERO_0=220.0
FREQ_FULL_0=440.0

GAIN_MAX_0=40.0
GAIN_MIN_0=5.0

#### for LPF ####

FREQ_ZERO=440.0
FREQ_FULL=880.0

GAIN_MAX=40.0
GAIN_MIN=1.0

# minus gain for lower keys

VOL_ADJ=2

#### for envelope modification ###

ENV_VOL_MAX=1.50
ENV_VOL_MIN=1.00

FREQ_ENV_VOL_MAX=110
FREQ_ENV_VOL_MIN=1760

########


echo SRC_DIR: $SRC_DIR
echo DEST_DIR: $DEST_DIR


LIST=`cat freq_data.csv | tr -d '\r' | awk -F, '{printf("%s%s,%s\n",substr($1,1,2),$2,$4);}'`
for i in $LIST ; do
  if [ "$FLAG_CREATE_WAV" = "1" ]; then
    LIST_WAV=`echo $i | awk -F, '{printf("%sv1.wav %sv2.wav %sv3.wav %sv4.wav %sv5.wav %sv6.wav %sv7.wav %sv8.wav %sv9.wav %sv10.wav %sv11.wav %sv12.wav %sv13.wav %sv14.wav %sv15.wav %sv16.wav\n",$1,$1,$1,$1,$1,$1,$1,$1,$1,$1,$1,$1,$1,$1,$1,$1);}'`
  else
    LIST_WAV=""
  fi
  FREQ=`echo $i | awk -F, '{printf("%s\n",$2);}'`
  echo "KEY: "`echo "$i"|awk -F, '{printf("%s\n",$1);}'`"    FREQ: ${FREQ}"
  #
  DURATION=`echo $FREQ | awk '{printf("%g\n",0.4*(800.0/log(800.0*$1)-48.0));}'`  #
  ENV_VOL=`echo $FREQ | awk '{ if($1 <= '$FREQ_ENV_VOL_MAX'){printf("%s\n","'$ENV_VOL_MAX'");} else { if('$FREQ_ENV_VOL_MIN' <= $1){printf("%s\n","'$ENV_VOL_MIN'");}else{printf("%g\n",'$ENV_VOL_MAX' - ('$ENV_VOL_MAX' - '$ENV_VOL_MIN')*(('$FREQ' - '$FREQ_ENV_VOL_MAX')/('$FREQ_ENV_VOL_MIN' - '$FREQ_ENV_VOL_MAX')));} } }'`
  echo " DURATION = $DURATION    ENV_VOL = $ENV_VOL"
  #
  FREQ_EQ_0=`echo $FREQ | awk '{printf("%g\n",$1*13);}'`
  FREQ_W_0=`echo $FREQ | awk '{printf("%g\n",$1*4);}'`
  #
  FREQ_EQ=`echo $FREQ | awk '{printf("%g\n",$1*6.0);}'`
  FREQ_W=`echo $FREQ | awk '{printf("%g\n",$1*3.0);}'`
  echo " FREQ_EQ = $FREQ_EQ    FREQ_W = $FREQ_W"
  #
  GAIN_THIS_0=`echo $FREQ | awk '{ if($1 <= '$FREQ_ZERO_0'){printf("%s\n","'$GAIN_MIN_0'");} else { if('$FREQ_FULL_0' <= $1){printf("%s\n","'$GAIN_MAX_0'");}else{printf("%g\n",'$GAIN_MIN_0' + ('$GAIN_MAX_0' - '$GAIN_MIN_0')*(('$FREQ' - '$FREQ_ZERO_0')/('$FREQ_FULL_0' - '$FREQ_ZERO_0')));} } }'`
  #
  #
  VOL_THIS=`echo $FREQ | awk '{ if($1 <= '$FREQ_ZERO'){printf("%s\n","'$VOL_ADJ'");} else { if('$FREQ_FULL' <= $1){printf("%s\n","0");}else{printf("%g\n",'$VOL_ADJ' - ('$VOL_ADJ')*(('$FREQ' - '$FREQ_ZERO')/('$FREQ_FULL' - '$FREQ_ZERO')));} } }'`
  #
  GAIN_THIS=`echo $FREQ | awk '{ if($1 <= '$FREQ_ZERO'){printf("%s\n","'$GAIN_MIN'");} else { if('$FREQ_FULL' <= $1){printf("%s\n","'$GAIN_MAX'");}else{printf("%g\n",'$GAIN_MIN' + ('$GAIN_MAX' - '$GAIN_MIN')*(('$FREQ' - '$FREQ_ZERO')/('$FREQ_FULL' - '$FREQ_ZERO')));} } }'`
  #
  echo " VOL for this: -$VOL_THIS    GAIN for this: -$GAIN_THIS"
  #
  for j in $LIST_WAV ; do
    #echo :: $j
    if [ -f "${SRC_DIR}/$j" ]; then
      OUT_FILE=${DEST_DIR}/$j
      echo "  Found "$j",  Output to $OUT_FILE"
      rm -f tmp1.wav tmp2.wav $OUT_FILE
      #
      #$FFMPEG -i "${SRC_DIR}/$j" -hide_banner -af volumedetect -vn -f null - 2> tmp_info.txt
      #N=`cat tmp_info.txt | grep "Hz," | awk -F, '{print $2;}' | awk '{print $1;}'`
      #N_SAMPLES=`echo $N | sed -e 's/.*[ ]//'`
      #N=`cat tmp_info.txt | tr -d ' ' | grep "n_samples:" | awk -F: '{printf("%d\n",$2/4);}'`
      #N_SUMMIT=`echo $N | sed -e 's/.*[ ]//'`
      #echo N_SAMPLES = $N_SAMPLES
      #echo N_SUMMIT = $N_SUMMIT
      #DURATION=`echo $N_SUMMIT $N_SAMPLES | awk '{printf("%g\n",1.0*$1/$2);}'`
      #echo DURATION = $DURATION
      #
      $FFMPEG -i "${SRC_DIR}/$j" -af equalizer=f=${FREQ_EQ_0}:t=h:w=${FREQ_W_0}:g=-${GAIN_THIS_0},equalizer=f=${FREQ_EQ}:t=h:w=${FREQ_W}:g=-${GAIN_THIS},volume=-${VOL_THIS}dB tmp1.wav 2> /dev/null
      $FFMPEG -i tmp1.wav -af "afade=t=in:st=0:d=${DURATION},volume=${ENV_VOL}" tmp2.wav 2> /dev/null
      $FFMPEG -i tmp1.wav -i tmp2.wav -filter_complex "amix=normalize=0" $OUT_FILE 2> /dev/null
    fi
  done
done


