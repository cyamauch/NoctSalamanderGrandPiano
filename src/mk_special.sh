#!/bin/sh

#### Creating F#2, A2, etc. ####

if [ "$4" = "" ]; then
  echo "[USAGE]"
  echo "$0 FFMPEG KEY IN.wav OUT.wav"
  exit
fi

if [ -f "$1" ]; then
  FFMPEG="$1"
else
  FFMPEG="/cygdrive/c/archives/Piano/VirtualMIDISynth/ffmpeg-master-latest-win64-gpl/bin/ffmpeg.exe"
fi

KEY=$2
IN_FILE=$3
OUT_FILE=$4

if [ "$KEY" = "F#2" ]; then

  # F#2 ... 92.499 Hz

  rm -f _tmp_sub_0.wav _tmp_sub_1.wav _tmp_sub_2.wav _tmp_sub_3.wav $OUT_FILE
  "$FFMPEG" -i $IN_FILE -af afade=t=in:st=0:d=0.2:silence=0.0:curve=tri,volume=-2.3dB -c:a pcm_f32le _tmp_sub_0.wav
  ## Erase strange noise 2> /dev/null
  "$FFMPEG" -i $IN_FILE -af afade=t=out:st=0:d=0.2:silence=0.0:curve=tri,equalizer=f=1035.0:t=h:w=1.0:g=-80:r=f32,volume=-0.3dB -c:a pcm_f32le _tmp_sub_1.wav
  "$FFMPEG" -i _tmp_sub_0.wav -i _tmp_sub_1.wav -filter_complex "amix=normalize=0" -c:a pcm_f32le _tmp_sub_2.wav
  "$FFMPEG" -i _tmp_sub_2.wav -af highpass=f=250.0:t=q:w=0.707:r=f32,volume=-3.0dB -c:a pcm_f32le _tmp_sub_3.wav
  "$FFMPEG" -i _tmp_sub_2.wav -i _tmp_sub_3.wav -filter_complex "amix=normalize=0" -c:a pcm_f32le $OUT_FILE

elif [ "$KEY" = "A2" ]; then

  # A2 ... 110.0 Hz

  rm -f _tmp_sub_0.wav _tmp_sub_1.wav _tmp_sub_2.wav _tmp_sub_3.wav $OUT_FILE
  "$FFMPEG" -i $IN_FILE -af afade=t=in:st=0:d=0.8:silence=0.0:curve=tri,volume=-2.3dB -c:a pcm_f32le _tmp_sub_0.wav
  ## Erase strange noise
  "$FFMPEG" -i $IN_FILE -af afade=t=out:st=0:d=0.8:silence=0.0:curve=tri,equalizer=f=1116.0:t=h:w=1.0:g=-80:r=f32,volume=-0.3dB -c:a pcm_f32le _tmp_sub_1.wav
  "$FFMPEG" -i _tmp_sub_0.wav -i _tmp_sub_1.wav -filter_complex "amix=normalize=0" -c:a pcm_f32le _tmp_sub_2.wav
  "$FFMPEG" -i _tmp_sub_2.wav -af highpass=f=270.0:t=q:w=0.707:r=f32,volume=-6.0dB -c:a pcm_f32le _tmp_sub_3.wav
  "$FFMPEG" -i _tmp_sub_2.wav -i _tmp_sub_3.wav -filter_complex "amix=normalize=0" -c:a pcm_f32le $OUT_FILE

elif [ "$KEY" = "C3" ]; then

  # C3 ... 130.813 Hz

  #### for Version 4.0 ####

  #rm -f $OUT_FILE
  #"$FFMPEG" -i $IN_FILE -af afade=t=in:st=0:d=0.4:silence=0.65:curve=tri,volume=+3.0dB -c:a pcm_f32le $OUT_FILE

  rm -f _tmp_sub_0.wav _tmp_sub_1.wav _tmp_sub_2.wav _tmp_sub_3.wav $OUT_FILE
  "$FFMPEG" -i $IN_FILE -af afade=t=in:st=0:d=0.4:silence=0.45:curve=tri,volume=+3.0dB -c:a pcm_f32le _tmp_sub_0.wav
  "$FFMPEG" -i $IN_FILE -af afade=t=out:st=0:d=0.4:silence=0.0:curve=tri,highpass=f=330.0:t=q:w=0.707:r=f32,volume=-2.0dB -c:a pcm_f32le _tmp_sub_1.wav
  "$FFMPEG" -i _tmp_sub_0.wav -i _tmp_sub_1.wav -filter_complex "amix=normalize=0" -c:a pcm_f32le _tmp_sub_2.wav
  "$FFMPEG" -i _tmp_sub_2.wav -af highpass=f=330.0:t=q:w=0.707:r=f32,volume=-9.0dB -c:a pcm_f32le _tmp_sub_3.wav
  "$FFMPEG" -i _tmp_sub_2.wav -i _tmp_sub_3.wav -filter_complex "amix=normalize=0" -c:a pcm_f32le $OUT_FILE

  #### for new version ? (testing...) ####

  # FFmpeg afade/acrossfade filter curves illustration
  # https://trac.ffmpeg.org/wiki/AfadeCurves

  ##  rm -f _tmp_sub_0.wav _tmp_sub_1.wav $OUT_FILE
  # volume factor = 3   : 2
  #                 1.2 : 0.8
  #                 1.1 : 0.73
  #                 1.0 : 0.67
  ##  "$FFMPEG" -i $IN_FILE -af afade=t=in:st=0:d=1.0:silence=0.5:curve=qsin,equalizer=f=850:t=h:w=300.0:g=-15:r=f32,volume=1.1 -c:a pcm_f32le _tmp_sub_0.wav
  ##  "$FFMPEG" -i $IN_FILE -af afade=t=out:st=0:d=3.0:silence=0.0:curve=desi,equalizer=f=130.813:t=h:w=100.0:g=-10.0:r=f32,volume=0.73 -c:a pcm_f32le _tmp_sub_1.wav
  ##  "$FFMPEG" -i _tmp_sub_0.wav -i _tmp_sub_1.wav -filter_complex "amix=normalize=0" -c:a pcm_f32le $OUT_FILE

elif [ "$KEY" = "D#3" ]; then

  rm -f _tmp_sub_0.wav _tmp_sub_1.wav $OUT_FILE
  "$FFMPEG" -i $IN_FILE -af volume=-1.5dB -c:a pcm_f32le _tmp_sub_0.wav
  "$FFMPEG" -i $IN_FILE -af highpass=f=270.0:t=q:w=0.707:r=f32,volume=-7.5dB -c:a pcm_f32le _tmp_sub_1.wav
  "$FFMPEG" -i _tmp_sub_0.wav -i _tmp_sub_1.wav -filter_complex "amix=normalize=0" -c:a pcm_f32le $OUT_FILE

fi

