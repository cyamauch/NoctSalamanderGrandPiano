#!/bin/sh

#### Creating F#2, A2, etc. ####

if [ "$5" = "" ]; then
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
VEL=$3
IN_FILE=$4
OUT_FILE=$5

if [ "$KEY" = "F#1" ]; then

  # Note: $IN_FILE/$OUT_FILE of "A1" is transformed into "F#1" in the main script.

  GAIN55="+0"
  GAIN238="+0"
  GAIN1665="+7.5"

  rm -f _tmp_sub_0.wav _tmp_sub_1.wav $OUT_FILE
  "$FFMPEG" -i $IN_FILE -af equalizer=f=1439:t=h:w=8:g=-40:r=f32,equalizer=f=2176:t=h:w=8:g=-40:r=f32,equalizer=f=1665:t=h:w=1665:g=${GAIN1665}:r=f32,equalizer=f=55:t=h:w=55:g=${GAIN55}:r=f32,equalizer=f=238:t=h:w=238:g=${GAIN238},afade=t=out:st=0:d=0.5:silence=0.0:curve=tri -c:a pcm_f32le _tmp_sub_0.wav
  "$FFMPEG" -i $IN_FILE -af equalizer=f=1665:t=h:w=1665:g=${GAIN1665}:r=f32,equalizer=f=55:t=h:w=55:g=${GAIN55}:r=f32,equalizer=f=238:t=h:w=238:g=${GAIN238},afade=t=in:st=0:d=0.5:silence=0.0:curve=tri -c:a pcm_f32le _tmp_sub_1.wav

  "$FFMPEG" -i _tmp_sub_0.wav -i _tmp_sub_1.wav -filter_complex "amix=normalize=0,volume=-1.2dB" -c:a pcm_f32le $OUT_FILE

elif [ "$KEY" = "F#2" ]; then

  # F#2 ... 92.499 Hz

  #########      v1     v2     v3     v4     v5      v6     v7     v8     v9    v10    v11    v12    v13    v14    v15    v16
  HPASS_VOL="     0      0      0  -48dB  -24dB -12.0dB -6.0dB -6.0dB -6.0dB -3.0dB -3.0dB -3.0dB -3.0dB -3.0dB -3.0dB -3.0dB"
  OUTPT_VOL="+2.3dB +2.3dB +2.3dB +2.0dB +1.6dB  +1.2dB +0.6dB +0.6dB +0.6dB    1.0    1.0    1.0    1.0    1.0    1.0    1.0"
  H_VOL=`echo $VEL $HPASS_VOL | awk '{ split($0,ARR," "); print ARR[1 + ARR[1]]; }'`
  O_VOL=`echo $VEL $OUTPT_VOL | awk '{ split($0,ARR," "); print ARR[1 + ARR[1]]; }'`

  rm -f _tmp_sub_0.wav _tmp_sub_1.wav _tmp_sub_2.wav _tmp_sub_3.wav $OUT_FILE
  # Erase strange noise of attack
  "$FFMPEG" -i $IN_FILE -af afade=t=in:st=0:d=0.2:silence=0.0:curve=tri,volume=-2.3dB -c:a pcm_f32le _tmp_sub_0.wav
  "$FFMPEG" -i $IN_FILE -af afade=t=out:st=0:d=0.2:silence=0.0:curve=tri,equalizer=f=1035.0:t=h:w=1.0:g=-80:r=f32,volume=-0.3dB -c:a pcm_f32le _tmp_sub_1.wav
  "$FFMPEG" -i _tmp_sub_0.wav -i _tmp_sub_1.wav -filter_complex "amix=normalize=0" -c:a pcm_f32le _tmp_sub_2.wav
  # Enhance overtone
  "$FFMPEG" -i _tmp_sub_2.wav -af highpass=f=250.0:t=q:w=0.707:r=f32,volume=$H_VOL -c:a pcm_f32le _tmp_sub_3.wav
  "$FFMPEG" -i _tmp_sub_2.wav -i _tmp_sub_3.wav -filter_complex "amix=normalize=0,volume=${O_VOL}" -c:a pcm_f32le $OUT_FILE

elif [ "$KEY" = "A2" ]; then

  # A2 ... 110.0 Hz

  #########      v1     v2     v3     v4     v5      v6     v7     v8     v9    v10    v11    v12    v13    v14    v15    v16
  HPASS_VOL="     0      0      0  -24dB  -12dB  -6.0dB -3.0dB -3.0dB -3.0dB -3.0dB -3.0dB -3.0dB -3.0dB -3.0dB -3.0dB -3.0dB"
  OUTPT_VOL="+2.3dB +2.3dB +2.3dB +1.6dB +0.8dB  +0.4dB    1.0    1.0    1.0    1.0    1.0    1.0    1.0    1.0    1.0    1.0"
  H_VOL=`echo $VEL $HPASS_VOL | awk '{ split($0,ARR," "); print ARR[1 + ARR[1]]; }'`
  O_VOL=`echo $VEL $OUTPT_VOL | awk '{ split($0,ARR," "); print ARR[1 + ARR[1]]; }'`

  rm -f _tmp_sub_0.wav _tmp_sub_1.wav _tmp_sub_2.wav _tmp_sub_3.wav $OUT_FILE
  # Erase strange noise of attack
  "$FFMPEG" -i $IN_FILE -af afade=t=in:st=0:d=0.8:silence=0.0:curve=tri,volume=-2.3dB -c:a pcm_f32le _tmp_sub_0.wav
  "$FFMPEG" -i $IN_FILE -af afade=t=out:st=0:d=0.8:silence=0.0:curve=tri,equalizer=f=1116.0:t=h:w=1.0:g=-80:r=f32,volume=-0.3dB -c:a pcm_f32le _tmp_sub_1.wav
  "$FFMPEG" -i _tmp_sub_0.wav -i _tmp_sub_1.wav -filter_complex "amix=normalize=0" -c:a pcm_f32le _tmp_sub_2.wav
  # Enhance overtone
  "$FFMPEG" -i _tmp_sub_2.wav -af highpass=f=270.0:t=q:w=0.707:r=f32,volume=$H_VOL -c:a pcm_f32le _tmp_sub_3.wav
  "$FFMPEG" -i _tmp_sub_2.wav -i _tmp_sub_3.wav -filter_complex "amix=normalize=0,volume=${O_VOL}" -c:a pcm_f32le $OUT_FILE

elif [ "$KEY" = "C3" ]; then

  # C3 ... 130.813 Hz

  #### for Version 4.0 ####

  #rm -f $OUT_FILE
  #"$FFMPEG" -i $IN_FILE -af afade=t=in:st=0:d=0.4:silence=0.65:curve=tri,volume=+3.0dB -c:a pcm_f32le $OUT_FILE

  #########      v1     v2     v3     v4     v5     v6     v7     v8     v9    v10    v11    v12    v13    v14    v15    v16
  ATACK_FRQ="  80.0   80.0  130.0  190.0  200.0  210.0  220.0  220.0  280.0  300.0  330.0  330.0  330.0  330.0  330.0  330.0"
  #ATACK_VOL="-7.0dB -5.5dB -4.0dB -3.5dB -3.4dB -3.3dB -3.2dB -3.2dB -2.5dB -2.3dB -2.0dB -2.0dB -2.0dB -2.0dB -2.0dB -2.0dB"
  ATACK_VOL="-7.0dB -5.5dB -4.0dB -3.5dB -3.4dB -3.3dB -3.2dB -3.2dB -2.5dB -2.5dB -2.5dB -2.5dB -2.5dB -2.5dB -2.5dB -2.5dB"
  #
  #HPASS_VOL="     0      0      0  -36dB  -18dB  -16dB  -15dB  -15dB  -12dB  -10dB -9.0dB -9.0dB -9.0dB -9.0dB -9.0dB -9.0dB"
  HPASS_VOL="     0      0      0  -36dB  -28dB  -24dB  -24dB  -24dB  -24dB -22dB -20.0dB -18.0dB -16.0dB -14.0dB -14.0dB -14.0dB"
  OUTPT_VOL="    1.0    1.0   1.0    1.0    1.0    1.0    1.0    1.0    1.0    1.0    1.0    1.0    1.0    1.0    1.0    1.0"
  #
  A_FRQ=`echo $VEL $ATACK_FRQ | awk '{ split($0,ARR," "); print ARR[1 + ARR[1]]; }'`
  A_VOL=`echo $VEL $ATACK_VOL | awk '{ split($0,ARR," "); print ARR[1 + ARR[1]]; }'`
  H_VOL=`echo $VEL $HPASS_VOL | awk '{ split($0,ARR," "); print ARR[1 + ARR[1]]; }'`
  O_VOL=`echo $VEL $OUTPT_VOL | awk '{ split($0,ARR," "); print ARR[1 + ARR[1]]; }'`

  rm -f _tmp_sub_0.wav _tmp_sub_1.wav _tmp_sub_2.wav _tmp_sub_3.wav _tmp_sub_4.wav _tmp_sub_5.wav $OUT_FILE

  # Fix overtone and envelope of attack
  "$FFMPEG" -i $IN_FILE -af afade=t=in:st=0:d=0.4:silence=0.45:curve=tri,volume=+3.0dB -c:a pcm_f32le _tmp_sub_0.wav
  "$FFMPEG" -i $IN_FILE -af afade=t=out:st=0:d=0.4:silence=0.0:curve=tri,highpass=f=${A_FRQ}:t=q:w=0.707:r=f32,volume=${A_VOL} -c:a pcm_f32le _tmp_sub_1.wav
  "$FFMPEG" -i _tmp_sub_0.wav -i _tmp_sub_1.wav -filter_complex "amix=normalize=0" -c:a pcm_f32le _tmp_sub_2.wav

  # Fix attack #2
  "$FFMPEG" -i $IN_FILE -af afade=t=out:st=0:d=0.15:silence=0.0:curve=tri,volume=-20.0dB -c:a pcm_f32le _tmp_sub_3.wav
  "$FFMPEG" -i _tmp_sub_2.wav -i _tmp_sub_3.wav -filter_complex "amix=normalize=0" -c:a pcm_f32le _tmp_sub_4.wav

  # Enhance overtone
  "$FFMPEG" -i _tmp_sub_4.wav -af afade=t=out:st=0:d=1.5:silence=0.25:curve=tri,highpass=f=330.0:t=q:w=0.707:r=f32,volume=$H_VOL -c:a pcm_f32le _tmp_sub_5.wav
  "$FFMPEG" -i _tmp_sub_4.wav -i _tmp_sub_5.wav -filter_complex "amix=normalize=0,volume=${O_VOL}" -c:a pcm_f32le $OUT_FILE

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

  # D#3 ... 155.563

  #########      v1     v2     v3     v4     v5     v6     v7     v8     v9    v10    v11    v12    v13    v14    v15    v16
  ##HPASS_VOL="     0      0      0  -30dB  -23dB  -15dB -7.5dB -7.5dB -7.5dB -7.5dB -7.5dB -7.5dB -7.5dB -7.5dB -7.5dB -7.5dB"
  ##OUTPT_VOL="+1.5dB +1.5dB +1.5dB +1.2dB +1.0dB +0.7dB   1.0    1.0    1.0    1.0    1.0    1.0    1.0    1.0    1.0    1.0"

  HPASS_VOL="     0      0      0     0     0   -15dB -7.5dB -7.5dB -7.5dB -7.5dB -7.5dB -7.5dB -7.5dB -7.5dB -7.5dB -7.5dB"
  OUTPT_VOL="+1.5dB +1.5dB +1.5dB +1.5dB +1.5dB +0.7dB   1.0    1.0    1.0    1.0    1.0    1.0    1.0    1.0    1.0    1.0"
  H_VOL=`echo $VEL $HPASS_VOL | awk '{ split($0,ARR," "); print ARR[1 + ARR[1]]; }'`
  O_VOL=`echo $VEL $OUTPT_VOL | awk '{ split($0,ARR," "); print ARR[1 + ARR[1]]; }'`

  rm -f _tmp_sub_0.wav _tmp_sub_1.wav $OUT_FILE
  "$FFMPEG" -i $IN_FILE -af volume=-1.5dB -c:a pcm_f32le _tmp_sub_0.wav
  # Enhance overtone
  "$FFMPEG" -i $IN_FILE -af highpass=f=270.0:t=q:w=0.707:r=f32,volume=$H_VOL -c:a pcm_f32le _tmp_sub_1.wav
  "$FFMPEG" -i _tmp_sub_0.wav -i _tmp_sub_1.wav -filter_complex "amix=normalize=0,volume=${O_VOL}" -c:a pcm_f32le $OUT_FILE

  # Same ...
  #"$FFMPEG" -i _tmp_sub_0.wav -i _tmp_sub_1.wav -filter_complex "[0:a]volume=${O_VOL}[0a];[1:a]volume=${O_VOL}[1a];[0a][1a]amix=normalize=0" -c:a pcm_f32le $OUT_FILE

fi

