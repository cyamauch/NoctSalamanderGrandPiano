#!/bin/sh

FFMPEG="/cygdrive/c/archives/Piano/VirtualMIDISynth/ffmpeg-master-latest-win64-gpl/bin/ffmpeg.exe"


LIST="v16,+0dB v15,+1dB v14,+2.5dB v13,+4dB v12,+6dB v11,+7.5dB v10,+9.5dB v09,+11.5dB v08,+13dB v07,+14dB v06,+15.5dB v05,+17dB v04,+18dB v03,+20dB v02,+23dB v01,+27dB"

for i in $LIST; do
  NAME=`echo $i | sed -e 's/[,][^,]*//'`
  VOL=`echo $i | sed -e 's/[^,]*[,]//'`
  echo $NAME $VOL

  rm -f scale_test_${NAME}_boost.wav
  "$FFMPEG" -i scale_test_${NAME}.wav -af volume=${VOL} -ac 1 scale_test_${NAME}_boost.wav
done



