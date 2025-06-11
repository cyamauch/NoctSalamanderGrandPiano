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


if [ "$3" = "" ]; then

  echo "[USAGE]"
  echo "$0 start(sec) span(sec) foo1.wav foo2.wav"
  echo
  echo "Notice:"
  echo "FFMPEG is '${FFMPEG}'"

  exit

fi

START=$1
SPAN=$2

while [ "$3" != "" ]; do

  IN_FILE=$3

  if [ -f $IN_FILE ]; then

    OUT_FILE=_tmp_.wav

    rm -f $OUT_FILE

    TO_PRM=`echo $START $SPAN | awk '{printf("%g\n",($1)+($2));}'`

    #echo $START ... $TO_PRM
    "$FFMPEG" -i $IN_FILE -ss $START -to $TO_PRM -c:a pcm_f32le $OUT_FILE 2> /dev/null
    "$FFMPEG" -i $OUT_FILE -af volumedetect -f null - 2> _result_.txt

    NAME="`basename $IN_FILE | sed -e 's/v[0-9][0-9]*[.]wav//'`"

    CHK="`echo $NAME | sed -e 's/^[A-Z][#]*[0-9]$//' -e 's/^[0-9][0-9]*[_][A-Z][#]*[0-9]$//'`"
    if [ "$CHK" = "" ]; then

      TST1=`echo $NAME | awk -F_ '{print $1;}'`
      TST2=`echo $NAME | awk -F_ '{print $2;}'`

      if [ "$TST1" != "" ]; then
        if [ "$TST2" = "" ]; then
          echo -n `cat ../key_n-id.txt | grep $TST1 | sed -e 's/^[^ ][^ ]*[ ]//'`" "
        else
          echo -n "${TST1} "
        fi
      fi

    fi

    cat _result_.txt | grep mean_volume | sed -e 's/.*mean_volume[:][ ]//' -e 's/ dB//' | tr -d '\r'

  fi

  shift

done


