#!/bin/sh

#if [ "$1" = "" ]; then
#  echo "[USAGE]"
#  echo "$0 FFMPEG"
#  exit
#fi

SRC_DIR=../SalamanderGrandPianoV3_48khz24bit/48khz24bit
DEST_DIR=./rel_corr

if [ -f "$1" ]; then
  FFMPEG="$1"
else
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

if [ ! -x "$FFMPEG" ]; then
  echo "Not found: $FFMPEG" 1>&2
  exit 127
fi

if [ -d "$2" ]; then
  SRC_DIR="$2"
fi

if [ -d "$3" ]; then
  DEST_DIR="$3"
fi

if [ "$FFMPEG_OPT" = "" ]; then
  FFMPEG_OPT="-c:a pcm_f32le"
fi

#
#

echo FFMPEG_OPT: ${FFMPEG_OPT}

if [ ! -d $DEST_DIR ]; then
  mkdir -p $DEST_DIR
fi

LIST=`cat rel_seek_pos.txt | awk '{printf("%s,%s\n",$1,$2);}'`

for i in $LIST ; do

  FILE=`echo $i | awk -F, '{print $1}'`
  SEEK_POS=`echo $i | awk -F, '{print $2}'`
  SEEK_OPT=`echo ${SEEK_POS} | awk '{ if (0 <= $1) { printf("atrim=start_sample=%.0f\n",$1*48000.0); } else { printf("adelay=%.0fS:all=1\n",(-1.0)*$1*48000.0); } }'`

  #echo $FILE : $SEEK_POS : $SEEK_OPT

  IN_FILE="$SRC_DIR/$FILE"
  OUT_FILE="$DEST_DIR/$FILE"

  echo "Adjust seek pos: $IN_FILE -> $OUT_FILE"

  rm -f $OUT_FILE
  "$FFMPEG" -i $IN_FILE -af ${SEEK_OPT} $FFMPEG_OPT $OUT_FILE 2> /dev/null

done

