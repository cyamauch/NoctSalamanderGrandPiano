#!/bin/sh

########################################################
#                                                      #
#     Main script for Noct-Salamander Grand Piano.     #
#                                                      #
#                   (C) 2023-2024 Chisato Yamauchi     #
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


#### for basic LPF                ####
#### Unused.  See lpf0_factor.txt ####
#
#FREQ_ZERO=220.0
#FREQ_FULL=440.0
#
#GAIN_MAX=40.0
#GAIN_MIN=1.0


#### for LPF per frequency section ####
#### See lpf[12]_factor.txt        ####

# LPF No.2 begins at ...

FREQ_ZERO_2=500.0


#### for envelope modification ####

ENV_VOL_MAX=1.50
ENV_VOL_MIN=1.00

FREQ_ENV_VOL_MAX=55
FREQ_ENV_VOL_MIN=880

#### Volume offset (db) for all WAV files ####

VOL_OFFSET=-0.5


########


echo FFMPEG: $FFMPEG
echo SRC_DIR: $SRC_DIR
echo DEST_DIR: $DEST_DIR


# Read frequency for each key

LIST=`cat freq_piano_data.txt | tr -d '\r' | awk '{printf("%s,%s\n",$1,$2);}'`
#echo "LIST=[$LIST]"


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
  echo "KEY: $KEY    FREQ: $FREQ"
  #
  DURATION=`echo $FREQ | awk '{printf("%g\n",0.4*(800.0/log(800.0*2.0*$1)-48.0));}'`  #
  ENV_VOL=`echo $FREQ | awk '{ if($1 <= '$FREQ_ENV_VOL_MAX'){printf("%s\n","'$ENV_VOL_MAX'");} else { if('$FREQ_ENV_VOL_MIN' <= $1){printf("%s\n","'$ENV_VOL_MIN'");}else{printf("%g\n",'$ENV_VOL_MAX' - ('$ENV_VOL_MAX' - '$ENV_VOL_MIN')*(('$FREQ' - '$FREQ_ENV_VOL_MAX')/('$FREQ_ENV_VOL_MIN' - '$FREQ_ENV_VOL_MAX')));} } }'`
  echo " DURATION = $DURATION    ENV_VOL = $ENV_VOL"
  #
  FREQ_EQ_0=`echo $FREQ | awk '{printf("%g\n",$1*12.0);}'`
  FREQ_W_0=`echo $FREQ | awk '{printf("%g\n",$1*6.0);}'`
  FREQ_EQ_12=`echo $FREQ | awk '{ if ( $1 < '$FREQ_ZERO_2' ) { printf("%g\n",$1*26.0); } else { printf("%g\n",$1*4.0); } }'`
  FREQ_W_12=`echo $FREQ  | awk '{ if ( $1 < '$FREQ_ZERO_2' ) { printf("%g\n",$1*8.0);  } else { printf("%g\n",$1*1.4); } }'`
  #
  echo " FREQ_EQ_0 = $FREQ_EQ_0    FREQ_W_0 = $FREQ_W_0"
  echo " FREQ_EQ_12 = $FREQ_EQ_12    FREQ_W_12 = $FREQ_W_12"
  #
  #GAIN_THIS_0=`echo $FREQ | awk '{ if($1 <= '$FREQ_ZERO'){printf("%s\n","'$GAIN_MIN'");} else { if('$FREQ_FULL' <= $1){printf("%s\n","'$GAIN_MAX'");}else{printf("%g\n",'$GAIN_MIN' + ('$GAIN_MAX' - '$GAIN_MIN')*(('$FREQ' - '$FREQ_ZERO')/('$FREQ_FULL' - '$FREQ_ZERO')));} } }'`
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
  GAIN_THIS_2=`cat lpf2_factor.txt | tr -d '\r' | grep "^$KEY" | awk '{printf("%s\n",$2);}'`
  if [ "$GAIN_THIS_2" = "" ]; then
    GAIN_THIS_2=0
  fi
  #
  GAIN_THIS_12=`echo $FREQ $GAIN_THIS_1 $GAIN_THIS_2 | awk '{ if ( $1 < '$FREQ_ZERO_2' ) { printf("%s\n",$2); } else { printf("%s\n",$3); } }'`
  #
  #
  VOL_THIS_ALL=`cat vol_factor.txt | tr -d '\r' | grep "^$KEY" | sed -e 's/^[^ ][^ ]*[ ][ ]*//'`
  SUBST_THIS_ALL=`cat substitute.txt | tr -d '\r' | grep "^$KEY" | sed -e 's/^[^ ][^ ]*[ ][ ]*//'`
  #
  if [ "$VOL_THIS_ALL" = "" ]; then
    VOL_THIS_ALL="0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0"
  fi
  if [ "$SUBST_THIS_ALL" = "" ]; then
    SUBST_THIS_ALL="1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16"
  fi
  LIST_VOL=`echo $KEY $VOL_OFFSET $VOL_THIS_ALL | awk '{printf("%sv1.wav %g\n%sv2.wav %g\n%sv3.wav %g\n%sv4.wav %g\n%sv5.wav %g\n%sv6.wav %g\n%sv7.wav %g\n%sv8.wav %g\n%sv9.wav %g\n%sv10.wav %g\n%sv11.wav %g\n%sv12.wav %g\n%sv13.wav %g\n%sv14.wav %g\n%sv15.wav %g\n%sv16.wav %g\n",$1,$2+$3,$1,$2+$4,$1,$2+$5,$1,$2+$6,$1,$2+$7,$1,$2+$8,$1,$2+$9,$1,$2+$10,$1,$2+$11,$1,$2+$12,$1,$2+$13,$1,$2+$14,$1,$2+$15,$1,$2+$16,$1,$2+$17,$1,$2+$18);}'`
  LIST_SUBST=`echo $KEY $SUBST_THIS_ALL | awk '{printf("%sv1.wav %s\n%sv2.wav %s\n%sv3.wav %s\n%sv4.wav %s\n%sv5.wav %s\n%sv6.wav %s\n%sv7.wav %s\n%sv8.wav %s\n%sv9.wav %s\n%sv10.wav %s\n%sv11.wav %s\n%sv12.wav %s\n%sv13.wav %s\n%sv14.wav %s\n%sv15.wav %s\n%sv16.wav %s\n",$1,$2,$1,$3,$1,$4,$1,$5,$1,$6,$1,$7,$1,$8,$1,$9,$1,$10,$1,$11,$1,$12,$1,$13,$1,$14,$1,$15,$1,$16,$1,$17);}'`
  #
  # f_tuned = f_orig * 2.0^( cent / 1200.0 )
  # cent = 1200.0 * log_2 (f_tuned / f_orig)
  #
  TUNE_BY_CENT=""
  FILTER_ASETRATE=""
  if [ "$FS_SRC" != "" ]; then
    TUNE_BY_CENT=`cat tuned.txt | tr -d '\r' | grep "^$KEY" | sed -e 's/^[^ ][^ ]*[ ][ ]*//'`
    if [ "$TUNE_BY_CENT" != "" ] ; then
      FILTER_ASETRATE=`echo $FS_SRC $TUNE_BY_CENT | awk '{printf(",asetrate=%g\n",$1 * 2.0^($2/1200.0));}'`
    fi
  fi
  #
  echo "GAIN_0: -$GAIN_THIS_0    GAIN[12]: -$GAIN_THIS_12   TUNE_BY_CENT: $TUNE_BY_CENT"
  #
  for j in $LIST_WAV ; do
    SUBST_THIS=`echo "$LIST_SUBST" | grep "^$j" | sed -e 's/.*wav //'`
    J_IN=`echo $j | sed -e 's/[0-9][0-9]*.wav//'`"${SUBST_THIS}.wav"
    IN_FILE="${SRC_DIR}/$J_IN"
    if [ -f "$IN_FILE" ]; then
      OUT_FILE="${DEST_DIR}/$j"
      VOL_THIS=`echo "$LIST_VOL" | grep "^$j" | sed -e 's/.*wav //'`
      echo "  Found ${J_IN}, Vol=${VOL_THIS}, Output to $OUT_FILE"
      rm -f tmp1.wav tmp2.wav "$OUT_FILE"
      #
      "$FFMPEG" -i "$IN_FILE" -af equalizer=f=${FREQ_EQ_12}:t=h:w=${FREQ_W_12}:g=-${GAIN_THIS_12},equalizer=f=${FREQ_EQ_0}:t=h:w=${FREQ_W_0}:g=-${GAIN_THIS_0},volume=${VOL_THIS}dB${FILTER_ASETRATE} -c:a pcm_s32le tmp1.wav 2> /dev/null
      "$FFMPEG" -i tmp1.wav -af "afade=t=in:st=0:d=${DURATION},volume=${ENV_VOL}" -c:a pcm_s32le tmp2.wav 2> /dev/null
      "$FFMPEG" -i tmp1.wav -i tmp2.wav -filter_complex "amix=normalize=0" $FFMPEG_OPT "$OUT_FILE" 2> /dev/null
    fi
  done
done


