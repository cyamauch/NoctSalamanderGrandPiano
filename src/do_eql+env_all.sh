#!/bin/sh

########################################################
#                                                      #
#     Main script for Noct-Salamander Grand Piano.     #
#                                                      #
#                        (C) 2023 Chisato Yamauchi     #
#                                                      #
########################################################

#### This script can be used under Cygwin Terminal. ####


#### Set your ffmpeg.exe in Makefile.  Native Windows binary is OK. ####

if [ "$FFMPEG" = "" ]; then
  FFMPEG="/cygdrive/c/archives/Piano/VirtualMIDISynth/ffmpeg-master-latest-win64-gpl/bin/ffmpeg.exe"
fi

if [ "$2" == "" ]; then
  echo "[USAGE]"
  echo "$0 SRC_DIR DEST_DIR"
  exit
fi


SRC_DIR="$1"
DEST_DIR="$2"


#### FLAG for wav creation ####

# ALL   ... create all
# 1-16  ... create velocity=n WAV files
# undef ... create none
FLAG_CREATE_WAV=ALL

#### for LPF per frequency section ####
#### See lpf[01]_factor.txt        ####

# LPF No.1 begins at ...

FREQ_ZERO_1=1000.0

#### for basic LPF ####

FREQ_ZERO=440.0
FREQ_FULL=880.0

GAIN_MAX=40.0
GAIN_MIN=1.0

#### for envelope modification ###

ENV_VOL_MAX=1.50
ENV_VOL_MIN=1.00

FREQ_ENV_VOL_MAX=110
FREQ_ENV_VOL_MIN=1760

########


echo FFMPEG: $FFMPEG
echo SRC_DIR: $SRC_DIR
echo DEST_DIR: $DEST_DIR


LIST=`cat freq_data.csv | tr -d '\r' | grep -e '^C[^#]' -e '^D#' -e '^F#' -e '^A[^#]' | awk -F, '{printf("%s%s,%s\n",substr($1,1,2),$2,$4);}'`
for i in $LIST ; do
  KEY=`echo $i | awk -F, '{printf("%s\n",$1);}'`
  FREQ=`echo $i | awk -F, '{printf("%s\n",$2);}'`
  if [ "$FLAG_CREATE_WAV" = "" ]; then
    LIST_WAV=""
  else
    if [ "$FLAG_CREATE_WAV" = "ALL" ]; then
      LIST_WAV=`echo $KEY | awk '{printf("%sv1.wav %sv2.wav %sv3.wav %sv4.wav %sv5.wav %sv6.wav %sv7.wav %sv8.wav %sv9.wav %sv10.wav %sv11.wav %sv12.wav %sv13.wav %sv14.wav %sv15.wav %sv16.wav\n",$1,$1,$1,$1,$1,$1,$1,$1,$1,$1,$1,$1,$1,$1,$1,$1);}'`
    else
      LIST_WAV=`echo $KEY | awk '{printf("%sv'$FLAG_CREATE_WAV'.wav\n",$1);}'`
    fi
  fi
  #echo "KEY: "`echo "$i"|awk -F, '{printf("%s\n",$1);}'`"    FREQ: ${FREQ}"
  echo "KEY: $KEY    FREQ: $FREQ"
  #
  DURATION=`echo $FREQ | awk '{printf("%g\n",0.4*(800.0/log(800.0*$1)-48.0));}'`  #
  ENV_VOL=`echo $FREQ | awk '{ if($1 <= '$FREQ_ENV_VOL_MAX'){printf("%s\n","'$ENV_VOL_MAX'");} else { if('$FREQ_ENV_VOL_MIN' <= $1){printf("%s\n","'$ENV_VOL_MIN'");}else{printf("%g\n",'$ENV_VOL_MAX' - ('$ENV_VOL_MAX' - '$ENV_VOL_MIN')*(('$FREQ' - '$FREQ_ENV_VOL_MAX')/('$FREQ_ENV_VOL_MIN' - '$FREQ_ENV_VOL_MAX')));} } }'`
  echo " DURATION = $DURATION    ENV_VOL = $ENV_VOL"
  #
  FREQ_EQ_01=`echo $FREQ | awk '{ if ( $1 < '$FREQ_ZERO_1' ) { printf("%g\n",$1*13.0); } else { printf("%g\n",$1*3.0); } }'`
  FREQ_W_01=`echo $FREQ  | awk '{ if ( $1 < '$FREQ_ZERO_1' ) { printf("%g\n",$1*4.0);  } else { printf("%g\n",$1*1.0); } }'`
  #
  FREQ_EQ=`echo $FREQ | awk '{printf("%g\n",$1*6.0);}'`
  FREQ_W=`echo $FREQ | awk '{printf("%g\n",$1*3.0);}'`
  echo " FREQ_EQ = $FREQ_EQ    FREQ_W = $FREQ_W"
  echo " FREQ_EQ_01 = $FREQ_EQ_01    FREQ_W_01 = $FREQ_W_01"
  #
  GAIN_THIS_0=`cat lpf0_factor.txt | tr -d '\r' | grep "^$KEY" | awk '{printf("%s\n",$2);}'`
  if [ "$GAIN_THIS_0" = "" ]; then
    GAIN_THIS_0=0
  fi
  #
  GAIN_THIS_1=`cat lpf1_factor.txt | tr -d '\r' | grep "^$KEY" | awk '{printf("%s\n",$2);}'`
  if [ "$GAIN_THIS_1" = "" ]; then
    GAIN_THIS_1=0
  fi
  #
  GAIN_THIS_01=`echo $FREQ $GAIN_THIS_0 $GAIN_THIS_1 | awk '{ if ( $1 < '$FREQ_ZERO_1' ) { printf("%s\n",$2); } else { printf("%s\n",$3); } }'`
  #
  #
  VOL_THIS=`cat vol_factor.txt | tr -d '\r' | grep "^$KEY" | awk '{printf("%s\n",$2);}'`
  if [ "$VOL_THIS" = "" ]; then
    VOL_THIS=0
  fi
  #
  GAIN_THIS=`echo $FREQ | awk '{ if($1 <= '$FREQ_ZERO'){printf("%s\n","'$GAIN_MIN'");} else { if('$FREQ_FULL' <= $1){printf("%s\n","'$GAIN_MAX'");}else{printf("%g\n",'$GAIN_MIN' + ('$GAIN_MAX' - '$GAIN_MIN')*(('$FREQ' - '$FREQ_ZERO')/('$FREQ_FULL' - '$FREQ_ZERO')));} } }'`
  #
  echo " VOL: -$VOL_THIS    GAIN: -$GAIN_THIS    GAIN[01]: -$GAIN_THIS_01"
  #
  for j in $LIST_WAV ; do
    #echo :: $j
    if [ -f "${SRC_DIR}/$j" ]; then
      OUT_FILE="${DEST_DIR}/$j"
      echo "  Found "$j",  Output to $OUT_FILE"
      rm -f tmp1.wav tmp2.wav "$OUT_FILE"
      #
      "$FFMPEG" -i "${SRC_DIR}/$j" -af equalizer=f=${FREQ_EQ_01}:t=h:w=${FREQ_W_01}:g=-${GAIN_THIS_01},equalizer=f=${FREQ_EQ}:t=h:w=${FREQ_W}:g=-${GAIN_THIS},volume=-${VOL_THIS}dB -c:a pcm_s32le tmp1.wav 2> /dev/null
      "$FFMPEG" -i tmp1.wav -af "afade=t=in:st=0:d=${DURATION},volume=${ENV_VOL}" -c:a pcm_s32le tmp2.wav 2> /dev/null
      "$FFMPEG" -i tmp1.wav -i tmp2.wav -filter_complex "amix=normalize=0" $FFMPEG_OPT "$OUT_FILE" 2> /dev/null
    fi
  done
done


