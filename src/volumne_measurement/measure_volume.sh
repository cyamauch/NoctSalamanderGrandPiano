#!/bin/sh

FFMPEG="C:/archives/Piano/VirtualMIDISynth/ffmpeg-master-latest-win64-gpl/bin/ffmpeg.exe"

# "C:" -> "/cygdrive/c" for cygwin
if [ "$OSTYPE" = "cygwin" ]; then
  FFMPEG="`echo $FFMPEG | sed -e 's/C:/\/cygdrive\/c/'`"
fi


if [ "$2" = "" ]; then

  echo "[USAGE]"
  echo "$0 sec foo1.wav foo2.wav"

  exit

fi

SPAN=$1

while [ "$2" != "" ]; do

  IN_FILE=$2

  if [ -f $IN_FILE ]; then

    OUT_FILE=_tmp_.wav

    rm -f $OUT_FILE

    "$FFMPEG" -i $IN_FILE -ss 0 -to $SPAN -c:a pcm_f32le $OUT_FILE 2> /dev/null
    "$FFMPEG" -i $OUT_FILE -af volumedetect -f null - 2> _result_.txt

    NAME="`basename $IN_FILE | sed -e 's/v[0-9][0-9]*[.]wav//'`"
    TST1=`echo $NAME | awk -F_ '{print $1;}'`
    TST2=`echo $NAME | awk -F_ '{print $2;}'`
    if [ "$TST2" = "" ]; then
	echo -n `cat ../key_n-id.txt | grep $TST1 | sed -e 's/^[^ ][^ ]*[ ]//'`" "
    else
	echo -n "${TST1} "
    fi
    cat _result_.txt | grep mean_volume | sed -e 's/.*mean_volume[:][ ]//' -e 's/ dB//'

  fi

  shift

done


