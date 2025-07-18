#!/bin/sh

###############################################################
#                                                             #
#     Main script for Noct-Salamander Grand Piano Project.    #
#                                                             #
#                          (C) 2023-2025 Chisato Yamauchi     #
#                                                             #
###############################################################

#### This script can be used under Cygwin Terminal. ####

if [ "$VERSION5" = "" ]; then
  # Version 5
  VERSION5=1
  # Version 6
  #VERSION5=0
fi

#### Set your ffmpeg.exe in Makefile.  Native Windows binary is OK. ####

if [ "$FFMPEG" = "" ]; then
  if [ -f ffmpeg_path.txt ]; then
    FFMPEG="`cat ffmpeg_path.txt`"
  else
    echo "ERROR: Not found ffmpeg_path.txt" 1>&2
    exit 127
  fi
fi

# "C:" -> "/cygdrive/c" for cygwin
if [ "$OSTYPE" = "cygwin" ]; then
  FFMPEG="`echo $FFMPEG | sed -e 's/C:/\/cygdrive\/c/'`"
fi

if [ "$FFMPEG_OPT" = "" ]; then
  FFMPEG_OPT="-c:a pcm_s24le"
fi

if [ "$3" = "" ]; then
  echo "[USAGE]"
  echo "**** to make ***"
  echo "$0 make SRC_DIR_ORIG DEST_DIR"
  echo "**** to copy ***"
  echo "$0 copy SRC_DIR_NOCT DEST_DIR"
  exit
fi

CMD_THIS="$1"
SRC_DIR="$2"
DEST_DIR="$3"

if [ "$4" = "" ]; then
  ENV_FACTOR=0
else
  ENV_FACTOR="$4"
fi

#if [ "$5" = "" ]; then
#  GAIN0_MAIN_FACTOR=0
#else
#  GAIN0_MAIN_FACTOR="$5"
#fi


####

if [ ! -x "$FFMPEG" ]; then
  echo "Not found: $FFMPEG" 1>&2
  exit 127
fi

####

FFMPEG_LOG_FILE="ffmpeg_log.txt"
FFMPEG_SP_LOG_FILE="ffmpeg-sp_log.txt"


#### SELECTION of wav creation ####

if [ "$SELECTED_LAYER" = "" ]; then

  # ALL   ... create all
  # 1-16  ... create velocity=n WAV files
  # undef ... create none
  SELECTED_LAYER=ALL
  #SELECTED_LAYER="10 16"
  #SELECTED_LAYER="1 2 3"

fi

if [ "$SELECTED_KEY" = "" ]; then

  SELECTED_KEY=""

  #SELECTED_KEY="F#2 A2 C3"
  #SELECTED_KEY="F#2 A2 C3 D#3 F#3 A3 C4"
  #SELECTED_KEY="A5 C6 A6"
  #SELECTED_KEY="C6 D#6 F#6 A6"
  #SELECTED_KEY="C4 D#4 F#4 A4 C5"
  #SELECTED_KEY="C1 D#1"
  #SELECTED_KEY="A2 C3 D#3"
  #SELECTED_KEY="A2 C3"

  #SELECTED_KEY="C7 D#7 F#7"
  #SELECTED_KEY="C6 D#6 F#6"
  #SELECTED_KEY="C5 D#5 F#5 A5"
  #SELECTED_KEY="C5 D#5 F#5 A5 C6 D#6 F#6 A6"

  #SELECTED_KEY="C4 D#4 F#4"
  #SELECTED_KEY="D#5 F#5 D#6 F#6"
  #SELECTED_KEY="A5 C6 D#6 F#6"
  #SELECTED_KEY="D#7 F#7 C8"
  #SELECTED_KEY="D#6 F#6 D#7 F#7"
  #SELECTED_KEY="C5 D#5 F#5 A5 C6 D#6 F#6 A6"
  #SELECTED_KEY="C5 D#5 F#5 A5 C6 D#6 F#6 A6 C7 D#7 F#7 A7 C8"
  #SELECTED_KEY="C6 D#6 F#6 A6"
  #SELECTED_KEY="A5 C6 D#6 F#6 A6 C7 D#7 F#7 A7 C8"
  #SELECTED_KEY="A0 C1 D#1 F#1 A1 C2 D#2 F#2 A2 C3 D#3 F#3 A3 C4 D#4 F#4 A4 C5"

  #SELECTED_KEY="A0 C1 F#1 C2 D#2"
  #SELECTED_KEY="F#5 F#6"
  #SELECTED_KEY="D#1 F#1 A1 C2"
  #SELECTED_KEY="C4 D#4 F#4 A4"

  #SELECTED_KEY="C4 D#4 F#4 A4 C5 D#5 F#5 A5 C6 D#6 F#6 A6 C7 D#7 F#7 A7 C8"

  #SELECTED_KEY="F#4 A4 D#5 F#5 A5 C6 D#6 F#6"
  #SELECTED_KEY="F#4 A4 C5 D#5 F#5 C6"
  #SELECTED_KEY="D#3 F#3 D#4 C4"
  #SELECTED_KEY="A2 C3 D#3 F#3"
  #SELECTED_KEY="C5 D#5 F#5 A5"
  #SELECTED_KEY="A0 C1 D#1 F#1 A1 C2 D#2 F#2 A2 C3 D#3 F#3"
  #SELECTED_KEY="A0 C1 D#1 F#1 A1"
  #SELECTED_KEY="C3 F#6 A6 C7 D#7 F#7 A7 C8"
  #SELECTED_KEY="A2 C3 D#3 F#3 C4 D#4"
  #SELECTED_KEY="F#3 A3 C4 D#4 C5 D#6"
  #SELECTED_KEY="F#3 C4 C5 D#5"
  #SELECTED_KEY="F#5 A5 C6 D#6 F#6 A6 C7"
  #SELECTED_KEY="C2 F#2 C3 F#3 A3"
  #SELECTED_KEY="C1 D#1 F#1 A1 C2 D#2 F#2"

  #SELECTED_KEY="C2 D#2 F#2 A2 C3 D#3 F#3 A3 C4 D#4 F#4 A4 C4 D#4 F#4 A4 C5 D#5 F#5 A5 C6 D#6 F#6 A6 C7 D#7 F#7 A7 C8"

  #SELECTED_KEY="C1 F#1 C2 F#2 C3 F#3 C4 F#4 C4 F#4 C5 F#5 C6 F#6 C7 F#7 C8"

  #SELECTED_KEY="A0 C1 D#1 F#1 A1 C2 D#2 F#2 A2 C3 D#3 F#3 A3 C4 D#4 F#4 A4"
  #SELECTED_KEY="C4 D#4 F#4 A4 C5 D#5 F#5 A5 C6 D#6 F#6 A6 C7 D#7 F#7 A7 C8"

  #SELECTED_KEY="A0 C1 D#1 F#1 A1 C2"
  #SELECTED_KEY="C1 D#1 F#1 A1 C2 D#2 F#2 A2 C3"
  #SELECTED_KEY="C2 D#2 F#2 A2 C3 D#3 F#3 A3 C4"
  #SELECTED_KEY="C3 D#3 F#3 A3 C4 D#4 F#4 A4 C5"
  #SELECTED_KEY="C4 D#4 F#4 A4 C5 D#5 F#5 A5 C6"

  #SELECTED_KEY="D#2 F#2 A2 C3 D#3 F#3 A3"
  #SELECTED_KEY="D#2 F#2 A2 C3 D#3 F#3 A3 C4 D#4 F#4 A4"
  #SELECTED_KEY="D#3 F#3 A3 C4 D#4 F#4 A4"

  #SELECTED_KEY="D#3 F#3 A3 A4 C5"

  #SELECTED_KEY="A4 C5 D#5 F#5 A5"

  #SELECTED_KEY="D#3 F#3 A3 C4 D#4 F#4 A4"

  #SELECTED_KEY="C4 D#4 F#4 A4 C5 D#5 F#5 A5 C6 D#6 F#6 A6 C7"
  #SELECTED_KEY="F#5 A5 C6 D#6 F#6"

  #SELECTED_KEY="D#6 F#6 A6 C7 D#7 F#7 A7 C8"
  #SELECTED_KEY="C7 D#7 F#7 A7 C8"

fi


#### for basic LPF                   ####
#### Not used.  See gain0_factor.txt ####
#
#FREQ_ZERO=220.0
#FREQ_FULL=440.0
#
#GAIN_MAX=40.0
#GAIN_MIN=1.0


#### for filtering per frequency section ####
#### See gain[0123]_factor.txt           ####

# Filter No.1 begins at ...

FREQ_ZERO_1=200.0

# Filter No.3 begins at ...

FREQ_ZERO_3=500.0


#### for envelope modification ####

ENV_VOL_MAX=1.50
ENV_VOL_MIN=1.00

FREQ_ENV_VOL_MAX=55
FREQ_ENV_VOL_MIN=880


########


echo FFMPEG: $FFMPEG
echo SRC_DIR: $SRC_DIR
echo DEST_DIR: $DEST_DIR


#### Read parameters ####

KEY_NID_TXT=`cat key_n-id.txt | tr -d '\r' | sed -e 's/^[ ]*//'`
VOL_FACTOR_TXT=`cat vol_factor.txt | tr -d '\r' | sed -e 's/^[ ]*//'`
PCM_SEEK_POS=`cat pcm_seek_pos.txt | tr -d '\r' | sed -e 's/^[ ]*//'`
ASSIGN_TXT=`cat assign.txt | tr -d '\r' | sed -e 's/^[ ]*//'`
GAIN1_ROOT_FACTOR_TXT=`cat gain1_root_factor.txt | tr -d '\r' | sed -e 's/^[ ]*//' -e 's/[ ]*$//' -e 's/^[#].*//' -e 's/[ ][ ]*/,/g' -e 's/[,]/ /'`
GAIN2_ROOT_FACTOR_TXT=`cat gain2_root_factor.txt | tr -d '\r' | sed -e 's/^[ ]*//' -e 's/[ ]*$//' -e 's/^[#].*//' -e 's/[ ][ ]*/,/g' -e 's/[,]/ /'`
GAIN0_FACTOR_TXT=`cat gain0_factor.txt | tr -d '\r' | sed -e 's/^[ ]*//' -e 's/[ ]*$//' -e 's/^[#].*//' -e 's/[ ][ ]*/,/g' -e 's/[,]/ /'`
GAIN1_FACTOR_TXT=`cat gain1_factor.txt | tr -d '\r' | sed -e 's/^[ ]*//' -e 's/[ ]*$//' -e 's/^[#].*//' -e 's/[ ][ ]*/,/g' -e 's/[,]/ /'`
GAIN2_FACTOR_TXT=`cat gain2_factor.txt | tr -d '\r' | sed -e 's/^[ ]*//' -e 's/[ ]*$//' -e 's/^[#].*//' -e 's/[ ][ ]*/,/g' -e 's/[,]/ /'`
GAIN3_FACTOR_TXT=`cat gain3_factor.txt | tr -d '\r' | sed -e 's/^[ ]*//' -e 's/[ ]*$//' -e 's/^[#].*//' -e 's/[ ][ ]*/,/g' -e 's/[,]/ /'`
FILTER_DIRECT_TXT=`cat filter_direct.txt | tr -d '\r' | sed -e 's/^[ ]*//'`

if [ "$VERSION5" = "1" ]; then
  TUNED_TXT=`cat tuned_v5.txt | tr -d '\r' | sed -e 's/^[ ]*//'`
else
  TUNED_TXT=`cat tuned.txt | tr -d '\r' | sed -e 's/^[ ]*//'`
fi

ARG_OUTFILE_SED_0=`echo "$KEY_NID_TXT" | awk '{printf("-e s/%sv/%s_%sv/ \n",$1,$2,$1);}'`
ARG_OUTFILE_SED_1=`echo "1_2_3_4_5_6_7_8_9_" | tr '_' '\n' | awk '{printf("-e s/v%s[.]wav/v0%s.wav/ \n",$1,$1);}'`
ARG_OUTFILE_SED=`echo "$ARG_OUTFILE_SED_0" "$ARG_OUTFILE_SED_1"`


########

rm -f $FFMPEG_LOG_FILE
rm -f $FFMPEG_SP_LOG_FILE


#### COPY MODE ####

if [ "$CMD_THIS" = "copy" ]; then

  LIST=`/bin/ls $SRC_DIR | grep '[0-1][0-9][0-9]_.*[.]wav'`
  for i in $LIST ; do
    OUT_FILE=${DEST_DIR}/${i}
    echo "Output to $OUT_FILE"
    rm -f "$OUT_FILE"
    "$FFMPEG" -i ${SRC_DIR}/${i} $FFMPEG_OPT $OUT_FILE 2> /dev/null
  done

  exit 0

fi



#### Support of two SRC_DIR ####

SRC_DIR_0="`echo $SRC_DIR | awk -F: '{print $1;}'`"
if [ "$SRC_DIR_0" != "" ]; then
  SRC_DIR_INFO_0='[DIR_0]'
fi

SRC_DIR_1="`echo $SRC_DIR | awk -F: '{print $2;}'`"
if [ "$SRC_DIR_1" != "" ]; then
  SRC_DIR_INFO_1='[DIR_1]'
fi


#### Read frequency for each key ####

if [ "$SELECTED_KEY" = "" ]; then
  LIST=`cat freq_piano_data.txt | tr -d '\r' | awk '{printf("%s,%s\n",$1,$2);}'`
else
  ARG_GREP=`echo "$SELECTED_KEY" | tr -s " " | tr " " "\n" | awk '{printf("-e %s\n",$1);}'`
  LIST=`cat freq_piano_data.txt | tr -d '\r' | grep $ARG_GREP | awk '{printf("%s,%s\n",$1,$2);}'`
fi
#echo "LIST=[$LIST]"


#### Volume offset (db) for all WAV files ####

VOL_OFFSET=`echo "$VOL_FACTOR_TXT" | grep "^OFFSET" | awk '{printf("%s\n",$2);}'`
echo "VOL_OFFSET=[$VOL_OFFSET]"


#### Effective ratio of filters ####

##  EFF_RATIO_0_SRC=`echo "$GAIN0_FACTOR_TXT" | awk '{ if ( $1 == "EFF_RATIO" ){ printf("%s\n",$2); } }'`
##  if [ "$EFF_RATIO_0_SRC" = "" ]; then
##    EFF_RATIO_0_SRC="1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0"
##  fi
##  EFF_RATIO_0=`echo "$EFF_RATIO_0_SRC" | awk '{ \
##    split($0,ARR,","); \
##    for ( i=1 ; i<=length(ARR) ; i++ ) { \
##      if ( i != 1 ) { \
##        printf(","); \
##      } \
##      printf("%.2f",ARR[i] * '$GAIN0_MAIN_FACTOR'); \
##    } \
##    printf("\n"); \
##  }'`


#### Main loop ####

for i in $LIST ; do
  KEY=`echo $i | awk -F, '{printf("%s\n",$1);}'`
  FREQ=`echo $i | awk -F, '{printf("%s\n",$2);}'`
  N_ID=`echo "$KEY_NID_TXT" | grep "^$KEY" | awk '{print $2;}'`
  if [ "$SELECTED_LAYER" = "" ]; then
    LIST_VEL=""
  else
    if [ "$SELECTED_LAYER" = "ALL" ]; then
      LIST_VEL="1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16"
    else
      LIST_VEL="$SELECTED_LAYER"
    fi
  fi
  echo "N_ID: $N_ID   KEY: $KEY    FREQ: $FREQ"
  #
  DURATION=`echo $FREQ | awk '{printf("%g\n",0.4*(800.0/log(1600.0*$1)-48.0));}'`
  ENV_VOL=`echo $FREQ | awk '{ \
    if ($1 <= '$FREQ_ENV_VOL_MAX') { \
      val = '$ENV_VOL_MAX'; \
    } \
    else { \
      if('$FREQ_ENV_VOL_MIN' <= $1) { \
        val = '$ENV_VOL_MIN'; \
      } \
      else { \
        val = '$ENV_VOL_MAX' - ('$ENV_VOL_MAX' - '$ENV_VOL_MIN')*(('$FREQ' - '$FREQ_ENV_VOL_MAX')/('$FREQ_ENV_VOL_MIN' - '$FREQ_ENV_VOL_MAX')); \
      } \
    } \
    printf("%g\n",val * '$ENV_FACTOR'); \
  }'`
  echo " DURATION = $DURATION    ENV_VOL = $ENV_VOL"
  #
  FREQ_EQ_ROOT_1=`echo $FREQ | awk '{ printf("%g\n",$1*12.0); }'`
  FREQ_W_ROOT_1=`echo $FREQ  | awk '{ printf("%g\n",$1*6.0); }'`
  FREQ_EQ_ROOT_2=`echo $FREQ | awk '{ printf("%g\n",$1*26.0); }'`
  FREQ_W_ROOT_2=`echo $FREQ  | awk '{ printf("%g\n",$1*8.0); }'`
  #
  FREQ_EQ_01=`echo $FREQ | awk '{ if ( $1 < '$FREQ_ZERO_1' ) { printf("%g\n",$1*0.5); } else { printf("%g\n",$1*12.0); } }'`
  FREQ_W_01=`echo $FREQ  | awk '{ if ( $1 < '$FREQ_ZERO_1' ) { printf("%g\n",$1*0.3);  } else { printf("%g\n",$1*6.0); } }'`
  FREQ_EQ_23=`echo $FREQ | awk '{ if ( $1 < '$FREQ_ZERO_3' ) { printf("%g\n",$1*26.0); } else { printf("%g\n",$1*4.0); } }'`
  FREQ_W_23=`echo $FREQ  | awk '{ if ( $1 < '$FREQ_ZERO_3' ) { printf("%g\n",$1*8.0);  } else { printf("%g\n",$1*1.4); } }'`
  #
  echo " FREQ_EQ_01 = $FREQ_EQ_01    FREQ_W_01 = $FREQ_W_01"
  echo " FREQ_EQ_23 = $FREQ_EQ_23    FREQ_W_23 = $FREQ_W_23"
  #
  GAIN1_ROOT_THIS=`echo "$GAIN1_ROOT_FACTOR_TXT" | awk '{ if (substr($1,1,3) == "'$N_ID'") {printf("%s\n",$2);} }'`
  if [ "$GAIN1_ROOT_THIS" = "" ]; then
    GAIN1_ROOT_THIS=0
  fi
  #
  GAIN2_ROOT_THIS=`echo "$GAIN2_ROOT_FACTOR_TXT" | awk '{ if (substr($1,1,3) == "'$N_ID'") {printf("%s\n",$2);} }'`
  if [ "$GAIN2_ROOT_THIS" = "" ]; then
    GAIN2_ROOT_THIS=0
  fi
  #
  #GAIN0_THIS=`echo $FREQ | awk '{ if($1 <= '$FREQ_ZERO'){printf("%s\n","'$GAIN_MIN'");} else { if('$FREQ_FULL' <= $1){printf("%s\n","'$GAIN_MAX'");}else{printf("%g\n",'$GAIN_MIN' + ('$GAIN_MAX' - '$GAIN_MIN')*(('$FREQ' - '$FREQ_ZERO')/('$FREQ_FULL' - '$FREQ_ZERO')));} } }'`
  #
  GAIN0_THIS=`echo "$GAIN0_FACTOR_TXT" | awk '{ if (substr($1,1,3) == "'$N_ID'") {printf("%s\n",$2);} }'`
  if [ "$GAIN0_THIS" = "" ]; then
    GAIN0_THIS=0
  fi
  #
  GAIN1_THIS=`echo "$GAIN1_FACTOR_TXT" | awk '{ if (substr($1,1,3) == "'$N_ID'") {printf("%s\n",$2);} }'`
  if [ "$GAIN1_THIS" = "" ]; then
    GAIN1_THIS=0
  fi
  #
  GAIN2_THIS=`echo "$GAIN2_FACTOR_TXT" | awk '{ if (substr($1,1,3) == "'$N_ID'") {printf("%s\n",$2);} }'`
  if [ "$GAIN2_THIS" = "" ]; then
    GAIN2_THIS=0
  fi
  #
  GAIN3_THIS=`echo "$GAIN3_FACTOR_TXT" | awk '{ if (substr($1,1,3) == "'$N_ID'") {printf("%s\n",$2);} }'`
  if [ "$GAIN3_THIS" = "" ]; then
    GAIN3_THIS=0
  fi
  #
  GAIN01_THIS=`echo $FREQ $GAIN0_THIS $GAIN1_THIS | awk '{ if ( $1 < '$FREQ_ZERO_1' ) { printf("%s\n",$2); } else { printf("%s\n",$3); } }'`
  GAIN23_THIS=`echo $FREQ $GAIN2_THIS $GAIN3_THIS | awk '{ if ( $1 < '$FREQ_ZERO_3' ) { printf("%s\n",$2); } else { printf("%s\n",$3); } }'`
  #
  EFF_RATIO_01=`echo $FREQ NONE NONE | awk '{ if ( $1 < '$FREQ_ZERO_1' ) { printf("%s\n",$2); } else { printf("%s\n",$3); } }' | tr ',' ' '`
  EFF_RATIO_23=`echo $FREQ NONE NONE | awk '{ if ( $1 < '$FREQ_ZERO_3' ) { printf("%s\n",$2); } else { printf("%s\n",$3); } }' | tr ',' ' '`
  #
  #
  VOL_THIS_ALL=`echo "$VOL_FACTOR_TXT" | grep "^$N_ID" | sed -e 's/^[^ ][^ ]*[ ][ ]*//'`
  SEEK_THIS_ALL=`echo "$PCM_SEEK_POS" | grep "^$N_ID" | sed -e 's/^[^ ][^ ]*[ ][ ]*//'`
  ASSIGN_THIS_ALL=`echo "$ASSIGN_TXT" | grep "^$N_ID" | sed -e 's/^[^ ][^ ]*[ ][ ]*//'`
  #
  if [ "$VOL_THIS_ALL" = "" ]; then
    VOL_THIS_ALL="0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0"
  fi
  if [ "$SEEK_THIS_ALL" = "" ]; then
    SEEK_THIS_ALL="0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000"
  fi
  USED_KEY="$KEY"
  TUNE_BY_SCALE=""
  if [ "$ASSIGN_THIS_ALL" = "" ]; then
    ASSIGN_THIS_ALL="1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16"
  else
    USED_KEY=`echo $ASSIGN_THIS_ALL | awk '{print $17}'`
    if [ "$USED_KEY" = "" ]; then
      USED_KEY="$KEY"
    else
      TUNE_BY_SCALE=`echo $ASSIGN_THIS_ALL | awk '{print $18}'`
    fi
  fi
  if [ "$TUNE_BY_SCALE" = "" ] ; then
    TUNE_BY_SCALE=0
  fi
  #
  # f_tuned = f_orig * 2.0^( cent / 1200.0 )
  # cent = 1200.0 * log_2 (f_tuned / f_orig)
  #
  TUNE_BY_CENT=""
  TUNE_BY_CENT_ALL=""
  FILTER_ASETRATE=""
  if [ "$FS_SRC" != "" ]; then
    TUNE_BY_CENT_ALL=`echo "$TUNED_TXT" | grep "^ALL" | sed -e 's/^[^ ][^ ]*[ ][ ]*//'`
    if [ "$TUNE_BY_CENT_ALL" = "" ] ; then
      TUNE_BY_CENT_ALL=0
    fi
    TUNE_BY_CENT=`echo "$TUNED_TXT" | grep "^$KEY" | sed -e 's/^[^ ][^ ]*[ ][ ]*//'`
    if [ "$TUNE_BY_CENT" = "" ] ; then
      TUNE_BY_CENT=0
    fi
    if [ "$TUNE_BY_SCALE" != "0" -o "$TUNE_BY_CENT" != "0" -o "$TUNE_BY_CENT_ALL" != "0" ] ; then
      FILTER_ASETRATE=`echo $FS_SRC $TUNE_BY_SCALE $TUNE_BY_CENT_ALL $TUNE_BY_CENT | awk '{printf("asetrate=%g,\n",($1) * 2.0^((100.0 * ($2) + (($3)+($4)))/1200.0));}'`
    fi
  fi
  # Direct filtering args for ffmpeg
  FILTER_DIRECT_LINE=`echo "$FILTER_DIRECT_TXT" | grep "^${KEY}[ ]"`
  FILTER_DIRECT_KEY=""
  if [ "$FILTER_DIRECT_LINE" != "" ]; then
    FILTER_DIRECT_KEY=`echo "${FILTER_DIRECT_LINE}" | awk '{if ( $2 != "" ) { printf("%s,",$2); } } END{ printf("\n"); }'`
    echo "FILTER_DIRECT_KEY: $FILTER_DIRECT_KEY"
  fi
  # for one by one ...
  FILTER_DIRECT_LINE=`echo "$FILTER_DIRECT_TXT" | grep "^${KEY}v[0-9]"`
  #
  echo "GAIN_ROOT_1: $GAIN1_ROOT_THIS    GAIN_ROOT_2: $GAIN2_ROOT_THIS"
  echo "GAIN_01: $GAIN01_THIS    GAIN_23: $GAIN23_THIS   TUNE: ${TUNE_BY_SCALE} + ((${TUNE_BY_CENT_ALL}) + (${TUNE_BY_CENT}))/100"
  echo "EFF_RATIO_01: $EFF_RATIO_01"
  #
  for j in $LIST_VEL ; do
    ORIG_NAME=${KEY}v${j}
    ASSIGN_THIS=`echo $j $ASSIGN_THIS_ALL | awk '{ split($0,ARR," "); print ARR[1 + ARR[1]]; }'`
    J_IN="${USED_KEY}v${ASSIGN_THIS}.wav"
    IN_FILE="${SRC_DIR_0}/$J_IN"
    IN_DIR_INFO="$SRC_DIR_INFO_0"
    if [ ! -f "$IN_FILE" ]; then
      IN_FILE="${SRC_DIR_1}/$J_IN"
      IN_DIR_INFO="$SRC_DIR_INFO_1"
    fi
    if [ -f "$IN_FILE" ]; then
      OUT_FILENAME=`echo ${ORIG_NAME}.wav | sed $ARG_OUTFILE_SED`
      OUT_FILE=${DEST_DIR}/${OUT_FILENAME}
      VOL_THIS=`echo $j $VOL_OFFSET $VOL_THIS_ALL | awk '{ split($0,ARR," "); printf("%g\n",ARR[2]+ARR[2 + ARR[1]]); }'`
      SEEK_THIS=`echo $j $SEEK_THIS_ALL | awk '{ split($0,ARR," "); printf("%s\n",ARR[1 + ARR[1]]); }'`
      echo "  Found ${IN_DIR_INFO}/${J_IN}, Vol=${VOL_THIS}, Seek=${SEEK_THIS} Output to $OUT_FILE"
      #
      GAIN1_ROOT_THIS_VEL=`echo $j $GAIN1_ROOT_THIS | tr ',' ' ' | awk '{ split($0,ARR," "); printf("%g\n",ARR[1 + ARR[1]]); }'`
      GAIN2_ROOT_THIS_VEL=`echo $j $GAIN2_ROOT_THIS | tr ',' ' ' | awk '{ split($0,ARR," "); printf("%g\n",ARR[1 + ARR[1]]); }'`
      #
      if [ "$EFF_RATIO_01" = "NONE" ]; then
        GAIN01_THIS_VEL=`echo $j $GAIN01_THIS | tr ',' ' ' | awk '{ split($0,ARR," "); printf("%g\n",ARR[1 + ARR[1]]); }'`
      else
        GAIN01_THIS_VEL=`echo $j $GAIN01_THIS $EFF_RATIO_01 | awk '{ split($0,ARR," "); printf("%g\n",ARR[2] * ARR[2 + ARR[1]]); }'`
      fi
      if [ "$EFF_RATIO_23" = "NONE" ]; then
        GAIN23_THIS_VEL=`echo $j $GAIN23_THIS | tr ',' ' ' | awk '{ split($0,ARR," "); printf("%g\n",ARR[1 + ARR[1]]); }'`
      else
        GAIN23_THIS_VEL=`echo $j $GAIN23_THIS $EFF_RATIO_23 | awk '{ split($0,ARR," "); printf("%g\n",ARR[2] * ARR[2 + ARR[1]]); }'`
      fi
      #echo "########## $j GAIN01_THIS:[$GAIN01_THIS] ... SET:[$GAIN01_THIS_VEL] ###########"
      #echo "########## $j GAIN23_THIS:[$GAIN23_THIS] ... SET:[$GAIN23_THIS_VEL] ###########"
      #
      if [ "$GAIN1_ROOT_THIS_VEL" = "0" ]; then
        ARG_EQ_ROOT_1=""
      else
        ARG_EQ_ROOT_1="equalizer=f=${FREQ_EQ_ROOT_1}:t=h:w=${FREQ_W_ROOT_1}:g=${GAIN1_ROOT_THIS_VEL}:r=f32,"
      fi
      if [ "$GAIN2_ROOT_THIS_VEL" = "0" ]; then
        ARG_EQ_ROOT_2=""
      else
        ARG_EQ_ROOT_2="equalizer=f=${FREQ_EQ_ROOT_2}:t=h:w=${FREQ_W_ROOT_2}:g=${GAIN2_ROOT_THIS_VEL}:r=f32,"
      fi
      #
      if [ "$GAIN01_THIS_VEL" = "0" ]; then
        ARG_EQ_01=""
      else
        ARG_EQ_01="equalizer=f=${FREQ_EQ_01}:t=h:w=${FREQ_W_01}:g=${GAIN01_THIS_VEL}:r=f32,"
      fi
      if [ "$GAIN23_THIS_VEL" = "0" ]; then
        ARG_EQ_23=""
      else
        ARG_EQ_23="equalizer=f=${FREQ_EQ_23}:t=h:w=${FREQ_W_23}:g=${GAIN23_THIS_VEL}:r=f32,"
      fi
      #
      FILTER_DIRECT_ARG=""
      if [ "$FILTER_DIRECT_LINE" != "" ]; then
        FD_TEST=`echo "$FILTER_DIRECT_LINE" | grep "^${ORIG_NAME}[ ]"`
        if [ "$FD_TEST" != "" ]; then
          FILTER_DIRECT_ARG=`echo "${FD_TEST}" | awk '{if ( $2 != "" ) { printf("%s,",$2); } } END{ printf("\n"); }'`
          echo "FILTER_DIRECT_ARG: $FILTER_DIRECT_ARG"
        fi
      fi
      # Special code: Fix strange envelope, noise, etc.
      if [ "$KEY" = "F#1" -o "$KEY" = "F#2" -o "$KEY" = "A2" -o "$KEY" = "C3" -o "$KEY" = "D#3" -o "$KEY" = "F#3" -o "$KEY" = "A3" -o "$KEY" = "C4" -o "$KEY" = "F#5" -o "$KEY" = "C6" ]; then
        rm -f tmp_pcm.wav
        sh mk_special.sh "$FFMPEG" $KEY $j "$IN_FILE" tmp_pcm.wav "$FFMPEG_SP_LOG_FILE" 2> /dev/null
        IN_FILE=tmp_pcm.wav
      fi
      #
      rm -f tmp1.wav tmp2.wav "$OUT_FILE"
      ARGS="-ss ${SEEK_THIS} -af ${FILTER_ASETRATE}${FILTER_DIRECT_KEY}${FILTER_DIRECT_ARG}${ARG_EQ_ROOT_1}${ARG_EQ_ROOT_2}${ARG_EQ_01}${ARG_EQ_23}volume=${VOL_THIS}dB -c:a pcm_f32le"
      ###LOG###
      echo FFMPEG -i "$IN_FILE" $ARGS tmp1.wav >> $FFMPEG_LOG_FILE
      #########
      "$FFMPEG" -i "$IN_FILE" $ARGS tmp1.wav 2> /dev/null
      # Adjust envelope
      ###LOG###
      echo FFMPEG -i tmp1.wav -af "afade=t=in:st=0:d=${DURATION},volume=${ENV_VOL}" -c:a pcm_f32le tmp2.wav >> $FFMPEG_LOG_FILE
      echo FFMPEG -i tmp1.wav -i tmp2.wav -filter_complex "amix=normalize=0" $FFMPEG_OPT "$OUT_FILENAME" >> $FFMPEG_LOG_FILE
      #########
      "$FFMPEG" -i tmp1.wav -af "afade=t=in:st=0:d=${DURATION},volume=${ENV_VOL}" -c:a pcm_f32le tmp2.wav 2> /dev/null
      "$FFMPEG" -i tmp1.wav -i tmp2.wav -filter_complex "amix=normalize=0" $FFMPEG_OPT "$OUT_FILE" 2> /dev/null
    fi
  done
done


