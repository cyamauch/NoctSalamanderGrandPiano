#!/bin/sh

FFMPEG="/cygdrive/c/archives/Piano/VirtualMIDISynth/ffmpeg-master-latest-win64-gpl/bin/ffmpeg.exe"


LIST="v16,+0dB v15,+1.5dB v14,+3dB v13,+4.5dB v12,+6dB v11,+7.5dB v10,+9dB v09,+10.5dB v08,+12dB v07,+13.5dB v06,+15dB v05,+16.5dB v04,+18dB v03,+20dB v02,+23dB v01,+27dB"

for i in $LIST; do
  NAME=`echo $i | sed -e 's/[,][^,]*//'`
  VOL=`echo $i | sed -e 's/[^,]*[,]//'`
  echo $NAME $VOL

  rm -f scale_test_${NAME}_boost.wav
  "$FFMPEG" -i scale_test_${NAME}.wav -af volume=${VOL} -ac 1 scale_test_${NAME}_boost.wav
done



