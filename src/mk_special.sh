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
  FFMPEG="C:/archives/Piano/VirtualMIDISynth/ffmpeg-master-latest-win64-gpl/bin/ffmpeg.exe"
fi

# "C:" -> "/cygdrive/c" for cygwin
if [ "$OSTYPE" = "cygwin" ]; then
  FFMPEG="`echo $FFMPEG | sed -e 's/C:/\/cygdrive\/c/'`"
fi

KEY=$2
VEL=$3
IN_FILE=$4
OUT_FILE=$5
if [ "$6" = "" ]; then
  FFMPEG_SP_LOG_FILE=/dev/null
else
  FFMPEG_SP_LOG_FILE=$6
fi

  ############################################################################

if [ "$KEY" = "F#1" ]; then

  ############################################################################

  # Note: $IN_FILE/$OUT_FILE of "A1" is transformed into "F#1" in the main script.

  # Seek (start@0.012)
  #            v1    v2    v3    v4    v5    v6    v7    v8    v9   v10   v11   v12   v13   v14   v15   v16
  SEEK_ALL="0.000 0.008 0.000 0.000 0.001 0.001 0.007 0.004 0.000 0.007 0.006 0.006 0.005 0.003 0.007 0.006"

  SEEK=`echo $VEL $SEEK_ALL | awk '{ split($0,ARR," "); print ARR[1+$1]; }'`

  # NOTE: All freq. must be written in "A1"-based.

  # A1(55Hz), A3(220Hz)
  # E3(164.814Hz), E4(329.628Hz), G4(391.995Hz), G#5(830.609Hz)

  # Essence!
  GAIN1665="+7.5"

  # Reproduce the waveform between D#1 and A1
  GAIN220="+8"
  GAIN330="+2"
  GAIN392="-16"

  EQ_BASE="equalizer=f=1665:t=h:w=1665:g=${GAIN1665}:r=f32,equalizer=f=220.0:t=h:w=10:g=${GAIN220}:r=f32,equalizer=f=329.6:t=h:w=10:g=${GAIN330}:r=f32,equalizer=f=392.0:t=h:w=10:g=${GAIN392}:r=f32"

  rm -f _tmp_sub_seek.wav _tmp_sub_0.wav _tmp_sub_1.wav $OUT_FILE

  ###LOG###
  echo FFMPEG -i $IN_FILE -ss $SEEK -c:a pcm_f32le _tmp_sub_seek.wav >> $FFMPEG_SP_LOG_FILE

  echo FFMPEG -i _tmp_sub_seek.wav -af equalizer=f=1439:t=h:w=8:g=-40:r=f32,equalizer=f=2176:t=h:w=8:g=-40:r=f32,${EQ_BASE},afade=t=out:st=0:d=0.5:silence=0.0:curve=tri -c:a pcm_f32le _tmp_sub_0.wav >> $FFMPEG_SP_LOG_FILE
  echo FFMPEG -i _tmp_sub_seek.wav -af ${EQ_BASE},afade=t=in:st=0:d=0.5:silence=0.0:curve=tri -c:a pcm_f32le _tmp_sub_1.wav >> $FFMPEG_SP_LOG_FILE

  echo FFMPEG -i _tmp_sub_0.wav -i _tmp_sub_1.wav -filter_complex "amix=normalize=0,volume=-1.2dB" -c:a pcm_f32le $OUT_FILE >> $FFMPEG_SP_LOG_FILE
  #########

  "$FFMPEG" -i $IN_FILE -ss $SEEK -c:a pcm_f32le _tmp_sub_seek.wav

  "$FFMPEG" -i _tmp_sub_seek.wav -af equalizer=f=1439:t=h:w=8:g=-40:r=f32,equalizer=f=2176:t=h:w=8:g=-40:r=f32,${EQ_BASE},afade=t=out:st=0:d=0.5:silence=0.0:curve=tri -c:a pcm_f32le _tmp_sub_0.wav
  "$FFMPEG" -i _tmp_sub_seek.wav -af ${EQ_BASE},afade=t=in:st=0:d=0.5:silence=0.0:curve=tri -c:a pcm_f32le _tmp_sub_1.wav

  "$FFMPEG" -i _tmp_sub_0.wav -i _tmp_sub_1.wav -filter_complex "amix=normalize=0,volume=-1.2dB" -c:a pcm_f32le $OUT_FILE

  ############################################################################

elif [ "$KEY" = "F#2" ]; then

  ############################################################################

  # F#2 ... 92.499 Hz

  # Seek (start@0.010)
  #            v1    v2    v3    v4    v5    v6    v7    v8    v9   v10   v11   v12   v13   v14   v15   v16
  SEEK_ALL="0.009 0.009 0.006 0.007 0.007 0.003 0.001 0.006 0.006 0.006 0.004 0.008 0.011 0.011 0.012 0.010"

  SEEK=`echo $VEL $SEEK_ALL | awk '{ split($0,ARR," "); print ARR[1+$1]; }'`

  # V5.1
  #########      v1     v2     v3     v4     v5     v6     v7     v8     v9    v10    v11    v12    v13    v14    v15    v16
  ##HPASS_VOL="   0      0      0  -24dB  -12dB -6.0dB -4.0dB -6.0dB -6.0dB -3.0dB -3.0dB -3.0dB -3.0dB -3.0dB -3.0dB -3.0dB"
  ##OUTPT_VOL=" 1.0 +2.3dB +2.3dB +2.0dB +1.6dB +1.2dB +0.6dB +0.6dB +0.6dB    1.0    1.0    1.0    1.0    1.0    1.0    1.0"

  # V5.2
  #########      v1     v2     v3     v4     v5     v6     v7     v8     v9    v10    v11    v12    v13    v14    v15    v16
  HPASS_VOL="     0      0  -27dB -9.0dB -5.0dB -4.0dB -3.0dB -3.0dB -5.0dB -4.0dB -5.0dB -5.5dB -5.0dB -5.0dB -5.0dB -5.0dB"
  OUTPT_VOL="   1.0 +2.3dB +2.3dB +2.0dB +1.5dB +1.0dB +0.5dB +0.4dB +0.5dB +0.1dB +0.2dB +0.2dB +0.2dB +0.2dB +0.2dB +0.2dB"

  H_VOL=`echo $VEL $HPASS_VOL | awk '{ split($0,ARR," "); print ARR[1 + ARR[1]]; }'`
  O_VOL=`echo $VEL $OUTPT_VOL | awk '{ split($0,ARR," "); print ARR[1 + ARR[1]]; }'`

  rm -f _tmp_sub_seek.wav _tmp_sub_0.wav _tmp_sub_1.wav _tmp_sub_2.wav _tmp_sub_3.wav $OUT_FILE
  ###LOG###
  echo FFMPEG -i $IN_FILE -ss $SEEK -c:a pcm_f32le _tmp_sub_seek.wav >> $FFMPEG_SP_LOG_FILE
  #########
  "$FFMPEG" -i $IN_FILE -ss $SEEK -c:a pcm_f32le _tmp_sub_seek.wav

  # Erase strange noise of attack
  ###LOG###
  echo FFMPEG -i _tmp_sub_seek.wav -af afade=t=in:st=0:d=0.2:silence=0.0:curve=tri,volume=-2.3dB -c:a pcm_f32le _tmp_sub_0.wav >> $FFMPEG_SP_LOG_FILE
  echo FFMPEG -i _tmp_sub_seek.wav -af afade=t=out:st=0:d=0.2:silence=0.0:curve=tri,equalizer=f=1035.0:t=h:w=1.0:g=-80:r=f32,volume=-0.3dB -c:a pcm_f32le _tmp_sub_1.wav >> $FFMPEG_SP_LOG_FILE
  echo FFMPEG -i _tmp_sub_0.wav -i _tmp_sub_1.wav -filter_complex "amix=normalize=0" -c:a pcm_f32le _tmp_sub_2.wav >> $FFMPEG_SP_LOG_FILE
  #########
  "$FFMPEG" -i _tmp_sub_seek.wav -af afade=t=in:st=0:d=0.2:silence=0.0:curve=tri,volume=-2.3dB -c:a pcm_f32le _tmp_sub_0.wav
  "$FFMPEG" -i _tmp_sub_seek.wav -af afade=t=out:st=0:d=0.2:silence=0.0:curve=tri,equalizer=f=1035.0:t=h:w=1.0:g=-80:r=f32,volume=-0.3dB -c:a pcm_f32le _tmp_sub_1.wav
  "$FFMPEG" -i _tmp_sub_0.wav -i _tmp_sub_1.wav -filter_complex "amix=normalize=0" -c:a pcm_f32le _tmp_sub_2.wav

  # Enhance overtone
  ###LOG###
  echo FFMPEG -i _tmp_sub_2.wav -af highpass=f=250.0:t=q:w=0.707:r=f32,volume=$H_VOL -c:a pcm_f32le _tmp_sub_3.wav >> $FFMPEG_SP_LOG_FILE
  echo FFMPEG -i _tmp_sub_2.wav -i _tmp_sub_3.wav -filter_complex "amix=normalize=0,volume=${O_VOL}" -c:a pcm_f32le $OUT_FILE  >> $FFMPEG_SP_LOG_FILE
  #########
  "$FFMPEG" -i _tmp_sub_2.wav -af highpass=f=250.0:t=q:w=0.707:r=f32,volume=$H_VOL -c:a pcm_f32le _tmp_sub_3.wav
  "$FFMPEG" -i _tmp_sub_2.wav -i _tmp_sub_3.wav -filter_complex "amix=normalize=0,volume=${O_VOL}" -c:a pcm_f32le $OUT_FILE

  ############################################################################

elif [ "$KEY" = "A2" ]; then

  ############################################################################

  # A2 ... 110.0 Hz

  # Seek (start@0.010)
  #            v1    v2    v3    v4    v5    v6    v7    v8    v9   v10   v11   v12   v13   v14   v15   v16
  SEEK_ALL="0.008 0.002 0.005 0.003 0.005 0.007 0.006 0.006 0.007 0.007 0.007 0.006 0.006 0.008 0.006 0.010"

  SEEK=`echo $VEL $SEEK_ALL | awk '{ split($0,ARR," "); print ARR[1+$1]; }'`

  # V5.1
  #########      v1     v2     v3     v4     v5     v6     v7     v8     v9    v10    v11    v12    v13    v14    v15    v16
  ##HPASS_VOL=" -24dB      0  -24dB  -24dB  -12dB -6.0dB -5.0dB -4.0dB -3.5dB -3.0dB -3.0dB -3.0dB -3.0dB -3.0dB -3.0dB -3.0dB"
  ##OUTPT_VOL="+2.3dB +2.3dB +2.3dB +1.6dB +0.8dB +0.4dB   1.0    1.0    1.0    1.0    1.0    1.0    1.0    1.0    1.0    1.0"

  # V5.2
  #########      v1     v2     v3     v4     v5     v6     v7     v8     v9    v10    v11    v12    v13    v14    v15    v16
  HPASS_VOL=" -24dB      0  -37dB  -37dB  -25dB  -19dB  -18dB  -17dB -16.5dB -16dB  -16dB  -16dB  -16dB  -16dB  -16dB  -16dB"
  OUTPT_VOL="+2.3dB +2.3dB +2.3dB +1.6dB +0.9dB  +0.7dB +0.5dB +0.6dB +0.7dB +0.9dB +0.9dB +0.9dB +1.1dB +1.1dB +1.1dB +1.2dB"

  H_VOL=`echo $VEL $HPASS_VOL | awk '{ split($0,ARR," "); print ARR[1 + ARR[1]]; }'`
  O_VOL=`echo $VEL $OUTPT_VOL | awk '{ split($0,ARR," "); print ARR[1 + ARR[1]]; }'`

  #########      v1     v2     v3     v4     v5      v6     v7     v8     v9    v10    v11    v12    v13    v14    v15    v16
  EQUAL_GIN="     0      0      0      0      0       0      0      0      0      0      0   +3.0   -1.5      0      0      0"
  E_GIN=`echo $VEL $EQUAL_GIN | awk '{ split($0,ARR," "); print ARR[1 + ARR[1]]; }'`

  # Adjust high-freq.
  GAIN6000="-10"

  rm -f _tmp_sub_seek.wav _tmp_sub_0.wav _tmp_sub_1.wav _tmp_sub_2.wav _tmp_sub_3.wav _tmp_sub_4.wav $OUT_FILE
  ###LOG###
  echo FFMPEG -i $IN_FILE -ss $SEEK -c:a pcm_f32le _tmp_sub_seek.wav >> $FFMPEG_SP_LOG_FILE
  #########
  "$FFMPEG" -i $IN_FILE -ss $SEEK -c:a pcm_f32le _tmp_sub_seek.wav

  # Erase strange noise of attack
  ###LOG###
  echo FFMPEG -i _tmp_sub_seek.wav -af afade=t=in:st=0:d=0.8:silence=0.0:curve=tri,volume=-2.3dB -c:a pcm_f32le _tmp_sub_0.wav >> $FFMPEG_SP_LOG_FILE

  echo FFMPEG -i _tmp_sub_seek.wav -af afade=t=out:st=0:d=0.8:silence=0.0:curve=tri,equalizer=f=3848.0:t=h:w=3.0:g=-80:r=f32,volume=-0.3dB -c:a pcm_f32le _tmp_sub_1.wav >> $FFMPEG_SP_LOG_FILE
  echo FFMPEG -i _tmp_sub_0.wav -i _tmp_sub_1.wav -filter_complex "amix=normalize=0" -c:a pcm_f32le _tmp_sub_2.wav >> $FFMPEG_SP_LOG_FILE
  #########
  "$FFMPEG" -i _tmp_sub_seek.wav -af afade=t=in:st=0:d=0.8:silence=0.0:curve=tri,volume=-2.3dB -c:a pcm_f32le _tmp_sub_0.wav

  "$FFMPEG" -i _tmp_sub_seek.wav -af afade=t=out:st=0:d=0.8:silence=0.0:curve=tri,equalizer=f=3848.0:t=h:w=3.0:g=-80:r=f32,volume=-0.3dB -c:a pcm_f32le _tmp_sub_1.wav
  "$FFMPEG" -i _tmp_sub_0.wav -i _tmp_sub_1.wav -filter_complex "amix=normalize=0" -c:a pcm_f32le _tmp_sub_2.wav

  # Adjust overtone
  EQ_ARG="equalizer=f=3000.0:t=h:w=3000.0:g=${E_GIN}:r=f32,equalizer=f=6000.0:t=h:w=6000:g=${GAIN6000}:r=f32"
  if [ "$VEL" = "1" ]; then
    # Eliminate strange noises after t=?[s]
    EQ_ARG="${EQ_ARG},afade=t=out:st=14.2:d=1.5"
  fi
  ###LOG###
  echo FFMPEG -i _tmp_sub_2.wav -af $EQ_ARG -c:a pcm_f32le _tmp_sub_3.wav >> $FFMPEG_SP_LOG_FILE
  #########
  "$FFMPEG" -i _tmp_sub_2.wav -af $EQ_ARG -c:a pcm_f32le _tmp_sub_3.wav

  # Enhance overtone
  ###LOG####
  echo FFMPEG -i _tmp_sub_3.wav -af highpass=f=270.0:t=q:w=0.707:r=f32,volume=$H_VOL -c:a pcm_f32le _tmp_sub_4.wav >> $FFMPEG_SP_LOG_FILE
  echo FFMPEG -i _tmp_sub_3.wav -i _tmp_sub_4.wav -filter_complex "amix=normalize=0,volume=${O_VOL}" -c:a pcm_f32le $OUT_FILE >> $FFMPEG_SP_LOG_FILE
  #########
  "$FFMPEG" -i _tmp_sub_3.wav -af highpass=f=270.0:t=q:w=0.707:r=f32,volume=$H_VOL -c:a pcm_f32le _tmp_sub_4.wav
  "$FFMPEG" -i _tmp_sub_3.wav -i _tmp_sub_4.wav -filter_complex "amix=normalize=0,volume=${O_VOL}" -c:a pcm_f32le $OUT_FILE

  ############################################################################

elif [ "$KEY" = "C3" ]; then

  ############################################################################

  # A2 ... 110.0 -> C3 ... 130.813 Hz (factor: 1.1892)

  # Note: $IN_FILE/$OUT_FILE of "A2" is transformed into "C3" in the main script.

  # Seek (start@0.010 for A2)
  #            v1    v2    v3    v4    v5    v6    v7    v8    v9   v10   v11   v12   v13   v14   v15   v16
  SEEK_ALL="0.008 0.002 0.005 0.003 0.005 0.007 0.006 0.006 0.007 0.007 0.007 0.006 0.006 0.008 0.006 0.010"

  SEEK=`echo $VEL $SEEK_ALL | awk '{ split($0,ARR," "); printf("%g\n",(110.0/130.813) * ARR[1+$1] - 0.001); }'`

  # V5.1
  #########       v1     v2     v3     v4     v5     v6     v7     v8     v9    v10    v11    v12    v13    v14    v15    v16
  ##HPASS_VOL="    0      0      0      0      0      0      0  -35dB  -18dB  -12dB -8.0dB -6.0dB -6.0dB -6.0dB -6.0dB -6.0dB"
  ##INPUT_VOL=" +1.6   +3.1   +2.1   +0.2   -0.1   +0.4   +1.0   +1.9   +1.1   -0.4   -0.7   -0.4   -1.7   -0.9   -2.5   -2.4"

  # V5.2
  #########      v1     v2     v3     v4     v5     v6     v7     v8     v9    v10    v11    v12    v13    v14    v15    v16
  HPASS_VOL="     0      0      0      0      0      0      0      0      0      0      0     0      0      0      0      0"
  INPUT_VOL="  +1.6   +3.1   +2.1   +0.2   -0.1   +0.4   +1.0    +1.9   +1.1   -0.3   -0.5   -0.2   -1.4   -0.6   -2.1   -2.0"

  #########      v1     v2     v3     v4     v5     v6     v7     v8     v9    v10    v11    v12    v13    v14    v15    v16
  EQUAL_GIN="  -3.0   -3.0   -5.0   -5.0   -4.0   -2.0   -2.0      0      0      0      0   +3.0   -1.5      0      0      0"
  E_GIN=`echo $VEL $EQUAL_GIN | awk '{ split($0,ARR," "); print ARR[1 + ARR[1]]; }'`

  H_VOL=`echo $VEL $HPASS_VOL | awk '{ split($0,ARR," "); print ARR[1 + ARR[1]]; }'`

  # NOTE: Unit is dB
  INPUT_VOL_BASE="-0.1"
  I_VOL=`echo $VEL $INPUT_VOL | awk '{ split($0,ARR," "); printf("%gdB\n",ARR[1 + ARR[1]] + ('${INPUT_VOL_BASE}') ); }'`

  # NOTE: All freq. must be written in "A2"-based.

  # Reduce strike
  GAIN110="+3"
  GAIN220="+2"
  GAIN330="+1"
  GAIN440="+4"
  GAIN550="+0"
  GAIN660="-6"
  GAIN770="+0"
  GAIN990="+0"
  GAIN1100="+0"

  # Adjust high-freq.
  GAIN6000="-10"

  EQ_BASE="equalizer=f=110.0:t=h:w=11:g=${GAIN110}:r=f32,equalizer=f=220:t=h:w=22:g=${GAIN220}:r=f32,equalizer=f=330.0:t=h:w=33:g=${GAIN330}:r=f32,equalizer=f=440.0:t=h:w=44:g=${GAIN440}:r=f32,equalizer=f=550.0:t=h:w=55:g=${GAIN550}:r=f32,equalizer=f=660.0:t=h:w=66:g=${GAIN660}:r=f32,equalizer=f=770.0:t=h:w=77:g=${GAIN770}:r=f32,equalizer=f=990.0:t=h:w=99:g=${GAIN990}:r=f32,equalizer=f=1100.0:t=h:w=110:g=${GAIN1100}:r=f32,equalizer=f=6000.0:t=h:w=6000:g=${GAIN6000}:r=f32,equalizer=f=2431:t=h:w=20:g=-20:r=f32,equalizer=f=2655:t=h:w=20:g=-20:r=f32"

  rm -f _tmp_sub_seek.wav _tmp_sub_0.wav _tmp_sub_1.wav _tmp_sub_2.wav _tmp_sub_3.wav _tmp_sub_4.wav $OUT_FILE

  ###LOG###
  echo FFMPEG -i $IN_FILE -ss $SEEK -af volume=$I_VOL -c:a pcm_f32le _tmp_sub_seek.wav >> $FFMPEG_SP_LOG_FILE
  #########
  "$FFMPEG" -i $IN_FILE -ss $SEEK -af volume=$I_VOL -c:a pcm_f32le _tmp_sub_seek.wav

  # Erase strange noise of attack
  ###LOG###
  echo FFMPEG -i _tmp_sub_seek.wav -af afade=t=in:st=0:d=0.8:silence=0.0:curve=tri,volume=-2.3dB -c:a pcm_f32le _tmp_sub_0.wav >> $FFMPEG_SP_LOG_FILE
  echo FFMPEG -i _tmp_sub_seek.wav -af afade=t=out:st=0:d=0.8:silence=0.0:curve=tri,equalizer=f=3848.0:t=h:w=3.0:g=-80:r=f32,volume=-0.3dB -c:a pcm_f32le _tmp_sub_1.wav >> $FFMPEG_SP_LOG_FILE
  echo FFMPEG -i _tmp_sub_0.wav -i _tmp_sub_1.wav -filter_complex "amix=normalize=0" -c:a pcm_f32le _tmp_sub_2.wav >> $FFMPEG_SP_LOG_FILE
  #########
  "$FFMPEG" -i _tmp_sub_seek.wav -af afade=t=in:st=0:d=0.8:silence=0.0:curve=tri,volume=-2.3dB -c:a pcm_f32le _tmp_sub_0.wav
  "$FFMPEG" -i _tmp_sub_seek.wav -af afade=t=out:st=0:d=0.8:silence=0.0:curve=tri,equalizer=f=3848.0:t=h:w=3.0:g=-80:r=f32,volume=-0.3dB -c:a pcm_f32le _tmp_sub_1.wav
  "$FFMPEG" -i _tmp_sub_0.wav -i _tmp_sub_1.wav -filter_complex "amix=normalize=0" -c:a pcm_f32le _tmp_sub_2.wav

  # Adjust overtone and strike
  EQ_ARG="equalizer=f=3000.0:t=h:w=3000.0:g=${E_GIN}:r=f32,${EQ_BASE}"
  if [ "$VEL" = "1" ]; then
    # Eliminate strange noises after t=?[s]
    EQ_ARG="${EQ_ARG},afade=t=out:st=14.2:d=1.5"
  fi
  ###LOG###
  echo FFMPEG -i _tmp_sub_2.wav -af $EQ_ARG -c:a pcm_f32le _tmp_sub_3.wav >> $FFMPEG_SP_LOG_FILE
  #########
  "$FFMPEG" -i _tmp_sub_2.wav -af $EQ_ARG -c:a pcm_f32le _tmp_sub_3.wav

  # Enhance overtone
  ###LOG###
  echo FFMPEG -i _tmp_sub_3.wav -af highpass=f=270.0:t=q:w=0.707:r=f32,volume=$H_VOL -c:a pcm_f32le _tmp_sub_4.wav >> $FFMPEG_SP_LOG_FILE
  echo FFMPEG -i _tmp_sub_3.wav -i _tmp_sub_4.wav -filter_complex "amix=normalize=0" -c:a pcm_f32le $OUT_FILE >> $FFMPEG_SP_LOG_FILE
  #########
  "$FFMPEG" -i _tmp_sub_3.wav -af highpass=f=270.0:t=q:w=0.707:r=f32,volume=$H_VOL -c:a pcm_f32le _tmp_sub_4.wav
  "$FFMPEG" -i _tmp_sub_3.wav -i _tmp_sub_4.wav -filter_complex "amix=normalize=0" -c:a pcm_f32le $OUT_FILE


  ############################################################################

elif [ "$KEY" = "D#3" ]; then

  ############################################################################

  # D#3 ... 155.563

  # V5.1
  #########       v1     v2     v3     v4     v5     v6     v7    v8     v9    v10    v11    v12    v13    v14    v15    v16
  ##HPASS_VOL="   0      0      0      0      0      0      0   -15dB -7.5dB -7.5dB -7.5dB -7.5dB -7.5dB -7.5dB -7.5dB -7.5dB"
  ##OUTPT_VOL="+1.5dB +1.5dB +1.5dB +1.5dB +1.5dB +1.0dB +1.0dB +0.5dB   1.0   1.0    1.0    1.0    1.0    1.0    1.0   1.0"

  # V5.2
  #########     v1     v2     v3     v4     v5   v6   v7     v8     v9     v10    v11    v12    v13    v14    v15    v16
  HPASS_VOL="   0      0      0      0      0    0    0      0      0      0      0      0      0      0      0      0"
  OUTPT_VOL="+1.5dB +1.5dB +1.5dB +1.4dB +1.5dB +1dB +1dB +0.7dB +0.8dB +0.8dB +0.8dB +0.8dB +0.9dB +1.0dB +1.0dB +1.0dB"

  H_VOL=`echo $VEL $HPASS_VOL | awk '{ split($0,ARR," "); print ARR[1 + ARR[1]]; }'`
  O_VOL=`echo $VEL $OUTPT_VOL | awk '{ split($0,ARR," "); print ARR[1 + ARR[1]]; }'`

  rm -f _tmp_sub_0.wav _tmp_sub_1.wav _tmp_sub_2.wav $OUT_FILE

  ###LOG###
  echo FFMPEG -i $IN_FILE -af volume=-1.5dB -c:a pcm_f32le _tmp_sub_0.wav >> $FFMPEG_SP_LOG_FILE
  #########
  "$FFMPEG" -i $IN_FILE -af volume=-1.5dB -c:a pcm_f32le _tmp_sub_0.wav

  # Enhance overtone
  ###LOG###
  echo FFMPEG -i $IN_FILE -af highpass=f=270.0:t=q:w=0.707:r=f32,volume=$H_VOL -c:a pcm_f32le _tmp_sub_1.wav >> $FFMPEG_SP_LOG_FILE
  echo FFMPEG -i _tmp_sub_0.wav -i _tmp_sub_1.wav -filter_complex "amix=normalize=0,volume=${O_VOL}" -c:a pcm_f32le _tmp_sub_2.wav >> $FFMPEG_SP_LOG_FILE
  #########
  "$FFMPEG" -i $IN_FILE -af highpass=f=270.0:t=q:w=0.707:r=f32,volume=$H_VOL -c:a pcm_f32le _tmp_sub_1.wav
  "$FFMPEG" -i _tmp_sub_0.wav -i _tmp_sub_1.wav -filter_complex "amix=normalize=0,volume=${O_VOL}" -c:a pcm_f32le _tmp_sub_2.wav
  # Supress unnecessary sympathetic vibration to keep continuity

  #########      v1     v2     v3     v4     v5     v6     v7     v8     v9    v10    v11    v12    v13    v14    v15    v16
  F_FACTOR="    1.0    1.0    1.0    1.0    1.0    1.0    1.0    1.0    1.0    1.0    0.9    0.8    0.7    0.5    0.3    0.1"

  # V5.1
  ##F_FACTOR_EFF=1.0
  # V5.2
  F_FACTOR_EFF=0.15

  F_F=`echo $VEL $F_FACTOR_EFF $F_FACTOR | awk '{ split($0,ARR," "); print ARR[2] * ARR[2 + ARR[1]]; }'`

  rm -f $OUT_FILE

  EQ_STR=`echo $F_F | awk '{ printf("equalizer=f=3017:t=h:w=60:g=%g:r=f32,equalizer=f=3186:t=h:w=60:g=%g:r=f32,equalizer=f=3522:t=h:w=70:g=%g:r=f32\n",-9.0*$1,-18.0*$1,-15.0*$1); }'`

  # Adjust amount of high frequency components (around 6000Hz)
  EQ_STR2=`echo $F_F | awk '{ printf("equalizer=f=6000:t=h:w=1000:g=%g:r=f32\n",-12.0*$1); }'`

  ###LOG###
  echo FFMPEG -i _tmp_sub_2.wav -af ${EQ_STR},${EQ_STR2} -c:a pcm_f32le $OUT_FILE >> $FFMPEG_SP_LOG_FILE
  #########
  "$FFMPEG" -i _tmp_sub_2.wav -af ${EQ_STR},${EQ_STR2} -c:a pcm_f32le $OUT_FILE

  ############################################################################

elif [ "$KEY" = "F#3" ]; then

  ############################################################################

  # Supress unnecessary sympathetic vibration to keep continuity

  #########      v1     v2     v3     v4     v5     v6     v7     v8     v9    v10    v11    v12    v13    v14    v15    v16
  F_FACTOR="    1.0    1.0    1.0    1.0    1.0    1.0    1.0    1.0    1.0    1.0    0.9    0.8    0.7    0.5    0.3    0.1"

  # V5.1
  ##F_FACTOR_EFF=1.0
  # V5.2
  F_FACTOR_EFF=0.5

  F_F=`echo $VEL $F_FACTOR_EFF $F_FACTOR | awk '{ split($0,ARR," "); print ARR[2] * ARR[2 + ARR[1]]; }'`

  rm -f $OUT_FILE

  EQ_STR=`echo $F_F | awk '{ printf("equalizer=f=3215:t=h:w=70:g=%g:r=f32,equalizer=f=3614:t=h:w=70:g=%g:r=f32,equalizer=f=3813:t=h:w=70:g=%g:r=f32\n",-12.0*$1,-15.0*$1,-18.0*$1); }'`

  # Adjust amount of high frequency components (around 6000Hz)
  EQ_STR2=`echo $F_F | awk '{ printf("equalizer=f=6000:t=h:w=1000:g=%g:r=f32\n",-12.0*$1); }'`

  ###LOG###
  echo FFMPEG -i $IN_FILE -af ${EQ_STR},${EQ_STR2} -c:a pcm_f32le $OUT_FILE >> $FFMPEG_SP_LOG_FILE
  #########
  "$FFMPEG" -i $IN_FILE -af ${EQ_STR},${EQ_STR2} -c:a pcm_f32le $OUT_FILE

  ############################################################################

elif [ "$KEY" = "A3" ]; then

  ############################################################################

  # Supress unnecessary sympathetic vibration to keep continuity

  #########      v1     v2     v3     v4     v5     v6     v7     v8     v9    v10    v11    v12    v13    v14    v15    v16
  F_FACTOR="    1.0    1.0    1.0    1.0    1.0    1.0    1.0    1.0    1.0    1.0    0.9    0.8    0.7    0.5    0.3    0.1"

  # V5.1
  ##F_FACTOR_EFF=1.0
  # V5.2
  F_FACTOR_EFF=0.7

  F_F=`echo $VEL $F_FACTOR_EFF $F_FACTOR | awk '{ split($0,ARR," "); print ARR[2] * ARR[2 + ARR[1]]; }'`

  rm -f $OUT_FILE

  EQ_STR=`echo $F_F | awk '{ printf("equalizer=f=2680:t=h:w=70:g=%g:r=f32,equalizer=f=3144:t=h:w=70:g=%g:r=f32,equalizer=f=3379:t=h:w=70:g=%g:r=f32,equalizer=f=3617:t=h:w=70:g=%g:r=f32\n",-8.0*$1,-15.0*$1,-14.0*$1,-20.0*$1); }'`

  # Adjust amount of high frequency components (around 6000Hz)
  EQ_STR2=`echo $F_F | awk '{ printf("equalizer=f=4900:t=h:w=1000:g=%g:r=f32,equalizer=f=6200:t=h:w=1000:g=%g:r=f32\n",-8.0*$1,-15.0*$1); }'`

  ###LOG###
  echo FFMPEG -i $IN_FILE -af ${EQ_STR},${EQ_STR2} -c:a pcm_f32le $OUT_FILE >> $FFMPEG_SP_LOG_FILE
  #########
  "$FFMPEG" -i $IN_FILE -af ${EQ_STR},${EQ_STR2} -c:a pcm_f32le $OUT_FILE

  ############################################################################

elif [ "$KEY" = "C4" ]; then

  ############################################################################

  # Supress unnecessary sympathetic vibration to keep continuity

  #########      v1     v2     v3     v4     v5     v6     v7     v8     v9    v10    v11    v12    v13    v14    v15    v16
  F_FACTOR="    1.0    1.0    1.0    1.0    1.0    1.0    1.0    1.0    1.0    1.0    0.9    0.8    0.7    0.5    0.3    0.1"

  # V5.1
  ##F_FACTOR_EFF=1.0
  # V5.2
  F_FACTOR_EFF=0.9

  F_F=`echo $VEL $F_FACTOR_EFF $F_FACTOR | awk '{ split($0,ARR," "); print ARR[2] * ARR[2 + ARR[1]]; }'`

  rm -f $OUT_FILE

  EQ_STR=`echo $F_F | awk '{ printf("equalizer=f=2630:t=h:w=70:g=%g:r=f32,equalizer=f=3200:t=h:w=70:g=%g:r=f32,equalizer=f=3482:t=h:w=70:g=%g:r=f32,equalizer=f=3767:t=h:w=70:g=%g:r=f32,equalizer=f=4044:t=h:w=80:g=%g:r=f32,equalizer=f=4338:t=h:w=80:g=%g:r=f32\n",-5.0*$1,-7.0*$1,-13.0*$1,-6.0*$1,-18.0*$1,-10.0*$1); }'`

  # Adjust amount of high frequency components (around 6000Hz)
  EQ_STR2=`echo $F_F | awk '{ printf("equalizer=f=6200:t=h:w=1000:g=%g:r=f32\n",-15.0*$1); }'`

  ###LOG###
  echo FFMPEG -i $IN_FILE -af ${EQ_STR},${EQ_STR2} -c:a pcm_f32le $OUT_FILE >> $FFMPEG_SP_LOG_FILE
  #########
  "$FFMPEG" -i $IN_FILE -af ${EQ_STR},${EQ_STR2} -c:a pcm_f32le $OUT_FILE

  ############################################################################

elif [ "$KEY" = "F#5" ]; then

  ############################################################################

  # Remove very high frequency noise

  ##EQ_STR_0="equalizer=f=4453:t=h:w=10.0:g=-40.0:r=f32,equalizer=f=4653:t=h:w=10.0:g=-40.0:r=f32,equalizer=f=4659:t=h:w=10.0:g=-40.0:r=f32,equalizer=f=5207:t=h:w=10.0:g=-40.0:r=f32"

  EQ_STR_1="equalizer=f=5457:t=h:w=10.0:g=-40.0:r=f32,equalizer=f=5545:t=h:w=10.0:g=-40.0:r=f32,equalizer=f=8325:t=h:w=20.0:g=-20.0:r=f32"

  # Adjust overtone to keep continuity

  #########      v1     v2     v3     v4     v5     v6     v7     v8     v9    v10    v11    v12    v13    v14    v15    v16
  #F_FACTOR="    1.0    1.0    1.0    1.0    1.0    1.0    1.0    1.0    1.0    1.0    1.0    0.9    0.8    0.6    0.3    0.0"
  F_FACTOR="    1.0    1.0    1.0    1.0    1.0    1.0    1.0    1.0    1.0    1.0    0.9    0.8    0.7    0.5    0.3    0.1"
  F_F=`echo $VEL $F_FACTOR | awk '{ split($0,ARR," "); print ARR[1 + ARR[1]]; }'`

  EQ_STR2=`echo $F_F | awk '{ printf("equalizer=f=5332:t=h:w=60:g=%g:r=f32,equalizer=f=6197:t=h:w=60:g=%g:r=f32,equalizer=f=7044:t=h:w=70:g=%g:r=f32\n",-6.0*$1,-10.0*$1,-12.0*$1-2); }'`

  rm -f $OUT_FILE

  ##"$FFMPEG" -i $IN_FILE -af ${EQ_STR_0},${EQ_STR_1},${EQ_STR2} -c:a pcm_f32le $OUT_FILE

  ###LOG###
  echo FFMPEG -i $IN_FILE -af ${EQ_STR_1},${EQ_STR2} -c:a pcm_f32le $OUT_FILE >> $FFMPEG_SP_LOG_FILE
  #########
  "$FFMPEG" -i $IN_FILE -af ${EQ_STR_1},${EQ_STR2} -c:a pcm_f32le $OUT_FILE

  ############################################################################

elif [ "$KEY" = "C6" ]; then

  ############################################################################

  # C6 ... 1046.502

  # Reduce strike and adjust the balance between the fundamental/overtone

  #########          v1            v2            v3            v4            v5            v6            v7
  EQ_GIN="11,-3,6,3,7,5 10,-4,5,2,6,4 10,-4,5,2,6,4 10,-4,5,2,6,4  9,-5,4,1,5,3  9,-5,4,1,5,3  9,-5,4,1,5,3"
  E_GIN=`echo $VEL $EQ_GIN | awk '{ split($0,ARR," "); print ARR[1 + ARR[1]]; }'`
  if [ "$E_GIN" = "" ]; then
    # DEFAULT
    E_GIN="8,-6,3,0,4,2"
  fi

  # Boost weakening component (high-freq.)
  GIN4277=1.0
  GIN5403=7.0
  GIN6590=1.0

  E_ARG=`echo $E_GIN | awk -F, '{printf("equalizer=f=1046.502:t=h:w=78:g=%s:r=f32,equalizer=f=2111:t=h:w=78:g=%s:r=f32,equalizer=f=3179:t=h:w=78:g=%s:r=f32,equalizer=f=4277:t=h:w=78:g=%s:r=f32,equalizer=f=5403:t=h:w=78:g=%s:r=f32,equalizer=f=6590:t=h:w=78:g=%s:r=f32\n",$1,$2,$3,'${GIN4277}'+$4,'${GIN5403}'+$5,'${GIN6590}'+$6);}'`

  rm -f _tmp_sub_0.wav _tmp_sub_1.wav _tmp_sub_2.wav $OUT_FILE

  # 4438Hz, 5583Hz, 6200Hz : Remove non-overtone frequency components
  ##"$FFMPEG" -i $IN_FILE -af volume=-3.6dB,${E_ARG},equalizer=f=4438:t=h:w=20:g=-40:r=f32,equalizer=f=5583:t=h:w=10:g=-30:r=f32,equalizer=f=6200:t=h:w=100:g=-20:r=f32 -c:a pcm_f32le _tmp_sub_0.wav

  # 6200Hz : Remove non-overtone frequency components
  ###LOG###
  echo FFMPEG -i $IN_FILE -af volume=-3.6dB,${E_ARG},equalizer=f=6200:t=h:w=100:g=-20:r=f32 -c:a pcm_f32le _tmp_sub_0.wav >> $FFMPEG_SP_LOG_FILE
  #########
  "$FFMPEG" -i $IN_FILE -af volume=-3.6dB,${E_ARG},equalizer=f=6200:t=h:w=100:g=-20:r=f32 -c:a pcm_f32le _tmp_sub_0.wav

  # Adjust envelope (The purpose of the high-pass filter is to remove noise)

  ###LOG###
  echo FFMPEG -i _tmp_sub_0.wav -af "afade=t=out:st=0:d=3.0,volume=1.0" -c:a pcm_f32le _tmp_sub_1.wav >> $FFMPEG_SP_LOG_FILE
  echo FFMPEG -i _tmp_sub_0.wav -af "highpass=f=700.0:t=q:w=0.707:r=f32,afade=t=in:st=0:d=3.0,volume=5.0" -c:a pcm_f32le _tmp_sub_2.wav >> $FFMPEG_SP_LOG_FILE
  echo FFMPEG -i _tmp_sub_1.wav -i _tmp_sub_2.wav -filter_complex "amix=normalize=0" -c:a pcm_f32le $OUT_FILE >> $FFMPEG_SP_LOG_FILE
  #########
  "$FFMPEG" -i _tmp_sub_0.wav -af "afade=t=out:st=0:d=3.0,volume=1.0" -c:a pcm_f32le _tmp_sub_1.wav
  "$FFMPEG" -i _tmp_sub_0.wav -af "highpass=f=700.0:t=q:w=0.707:r=f32,afade=t=in:st=0:d=3.0,volume=5.0" -c:a pcm_f32le _tmp_sub_2.wav

  "$FFMPEG" -i _tmp_sub_1.wav -i _tmp_sub_2.wav -filter_complex "amix=normalize=0" -c:a pcm_f32le $OUT_FILE

  ############################################################################

elif [ "$KEY" = "C3_NOT_USED" ]; then

  ############################################################################
  ############################################################################

  # FFmpeg afade/acrossfade filter curves illustration
  # https://trac.ffmpeg.org/wiki/AfadeCurves

  # C3 ... 130.813 Hz

  rm -f _tmp_sub_seek.wav _tmp_sub_0.wav _tmp_sub_1.wav _tmp_sub_2.wav _tmp_sub_3.wav _tmp_sub_4.wav _tmp_sub_5.wav _tmp_sub_6.wav  _tmp_sub_7.wav _tmp_sub_8.wav _tmp_sub_9.wav
  rm -f _tmp_sub_a.wav _tmp_sub_b.wav _tmp_sub_c.wav _tmp_sub_d.wav _tmp_sub_e.wav
  rm -f _tmp_sub_p0.wav _tmp_sub_p1.wav _tmp_sub_p2.wav _tmp_sub_p3.wav _tmp_sub_p4.wav _tmp_sub_p5.wav _tmp_sub_p6.wav $OUT_FILE

  ####
  #### Seek (start@0.010)
  ####

  #            v1    v2    v3    v4    v5    v6    v7    v8    v9   v10   v11   v12   v13   v14   v15   v16
  SEEK_ALL="0.008 0.010 0.004 0.008 0.011 0.008 0.006 0.009 0.007 0.008 0.007 0.008 0.012 0.012 0.009 0.010"

  SEEK=`echo $VEL $SEEK_ALL | awk '{ split($0,ARR," "); print ARR[1+$1]; }'`

  # To prevent overflow at layer=15,16 ...

  #            v1    v2    v3    v4    v5    v6    v7    v8    v9   v10   v11   v12   v13   v14   v15   v16
  # NOTE: unit is dB
  # V5.0RC3
  #INPUT_VOL_BASE=0.0
  #INPUT_VOL="-0.8  -2.2  -1.1  -3.0  -2.9  -3.3  -3.2  -2.8  -3.6  -4.1  -5.1  -4.9  -5.2  -4.2  -5.5  -5.0"
  # TEST1,TEST2
  #INPUT_VOL_BASE=-3.5
  #INPUT_VOL="-0.3  -1.7  -0.8  -2.7  -2.8  -3.2  -3.2  -2.8  -3.6  -4.1  -5.1  -4.9  -5.2  -4.5  -5.5  -5.0"
  # V5.0
  INPUT_VOL_BASE=+2.2
  # V5.0TEST
  INPUT_VOL_BASE=+1.7
  #INPUT_VOL="-0.5  -2.0  -0.9  -2.8  -2.9  -3.3  -3.2  -2.8  -3.6  -4.1  -5.1  -5.1  -5.5  -4.8  -5.8  -5.3"
  # to be flat
  INPUT_VOL="-0.7  -2.1  -1.2  -3.0  -3.0  -3.2  -3.0  -2.6  -3.5  -4.1  -4.9  -4.8  -5.2  -4.5  -5.7  -5.2"
  I_VOL=`echo $VEL $INPUT_VOL | awk '{ split($0,ARR," "); printf("%gdB\n",ARR[1 + ARR[1]] + ('${INPUT_VOL_BASE}') ); }'`

  "$FFMPEG" -i $IN_FILE -ss $SEEK -af volume=$I_VOL -c:a pcm_f32le _tmp_sub_seek.wav


  ####
  #### Adjustment envelope
  ####
  PCM_IN=_tmp_sub_seek.wav
  PCM_OUT=_tmp_sub_p0.wav

  "$FFMPEG" -i $PCM_IN -af "afade=t=in:st=0:d=8.0,volume=0.5" -c:a pcm_f32le _tmp_sub_0.wav
  "$FFMPEG" -i $PCM_IN -i _tmp_sub_0.wav -filter_complex "amix=normalize=0" -c:a pcm_f32le $PCM_OUT


  ####
  #### Basic overtone adjustment
  ####
  #### Adjustment of Fundamental tone (130.8Hz) and
  #### overtone C4(261.626), G4 (391.995), C5(523.251), E5(659.255),
  #### overtone G5 (783.991Hz), A#5(932.328Hz)
  #### overtone D6(1174.659Hz), E6 (1318.51Hz), F#6(1479.978Hz), G6(1567.982Hz), A6(1760Hz)
  ####          A#6(1864.655Hz), B6(1975.533Hz), D7(2349.318Hz), E7(2637.02Hz),
  ####          F#7(2959.955Hz), G7(3135.963Hz), A#7(3729.31)

  ####
  PCM_IN=_tmp_sub_p0.wav
  PCM_OUT=_tmp_sub_p1.wav

  T_ST_0=1.5
  T_D_0=2.0

  # Gain of C3 (130.813Hz) fundamental
  # TEST
  #FUND_GAIN_FIRST="+1"
  #FUND_GAIN_LAST="+2"
  # V5.0RC3
  #FUND_GAIN_FIRST="+12"
  #FUND_GAIN_LAST="+21"
  # V5.0
  FUND_GAIN_FIRST="+0"
  FUND_GAIN_LAST="+9"
  # V5.0TEST
  FUND_GAIN_FIRST="+0"
  FUND_GAIN_LAST="+9"
  TONE_BALANCE_C5="+3.0"
  TONE_BALANCE_920HZ="+0"
  TONE_BALANCE_2200HZ="+0"

  #########       v1     v2     v3     v4     v5     v6     v7     v8     v9    v10    v11    v12    v13    v14    v15    v16
  # V5.0RC3
  #OVTONE_VOL_BASE=1.0
  #OVTONE_VOL="  +2.5   +4.6   +1.6   +2.3   +2.7   +3.3   +3.2   +3.1   +3.3   +4.0   +3.6   +3.4   +3.3   +3.4   +3.7   +3.3"
  # V5.0
  OVTONE_VOL_BASE=-0.1
  # V5.0TEST
  OVTONE_VOL_BASE=-0.1
  OVTONE_VOL="  +2.5   +4.6   +1.6   +2.3   +2.7   +3.3   +3.2   +3.1   +3.3   +4.0   +3.6   +3.4   +3.3   +3.4   +3.7   +3.3"
  #OVTONE_VOL="  -0.5   +2.0   +0.5   +1.0   +2.0   +3.0   +3.0   +3.1   +3.3   +4.0   +3.6   +3.4   +3.3   +3.4   +3.7   +3.3"
  #
  OV_VOL=`echo $VEL $OVTONE_VOL | awk '{ split($0,ARR," "); printf("%g\n",ARR[1 + ARR[1]] + ('${OVTONE_VOL_BASE}') ); }'`

  # Reproduce the waveform between A2 and D#3
  # V5.0RC3
  #ARG_EQ_MID_HIGH="equalizer=f=920.0:t=h:w=200.0:g=-4:r=f32"
  # TEST1
  #ARG_EQ_MID_HIGH="equalizer=f=520.0:t=h:w=20.0:g=+11:r=f32,equalizer=f=651.0:t=h:w=20.0:g=+5:r=f32,equalizer=f=795.0:t=h:w=20.0:g=-1:r=f32,equalizer=f=910.0:t=h:w=20.0:g=-4:r=f32"
  # TEST2
  #ARG_EQ_MID_HIGH="equalizer=f=262:t=h:w=20.0:g=+3:r=f32,equalizer=f=392:t=h:w=20.0:g=+3:r=f32,equalizer=f=523:t=h:w=20.0:g=+10:r=f32,equalizer=f=659:t=h:w=20.0:g=-2:r=f32,equalizer=f=784:t=h:w=20.0:g=-8:r=f32,equalizer=f=932:t=h:w=20.0:g=+4:r=f32"
  #ARG_EQ_MID_HIGH="equalizer=f=523:t=h:w=20.0:g=+9:r=f32,equalizer=f=659:t=h:w=20.0:g=+1:r=f32,equalizer=f=784:t=h:w=20.0:g=-5:r=f32,equalizer=f=932:t=h:w=20.0:g=-6:r=f32"
  # V5.0
  ARG_EQ_MID_HIGH="equalizer=f=920.0:t=h:w=200.0:g=-4:r=f32"
  # V5.0TEST
  ARG_EQ_MID_HIGH="equalizer=f=652:t=h:w=60.0:g=+1:r=f32,equalizer=f=784:t=h:w=60.0:g=-9:r=f32,equalizer=f=915:t=h:w=90.0:g=-12:r=f32,equalizer=f=920.0:t=h:w=200.0:g=${TONE_BALANCE_920HZ}:r=f32"

  # param [500,1200] of ARG_EQ_MID is very critical !!!
  ##ARG_EQ_MID="equalizer=f=525.0:t=h:w=1100.0:g=${OV_VOL}:r=f32,$ARG_EQ_MID_HIGH"
  ARG_EQ_MID="equalizer=f=500.0:t=h:w=1200.0:g=${OV_VOL}:r=f32,$ARG_EQ_MID_HIGH"
  #ARG_EQ_MID="equalizer=f=475.0:t=h:w=1300.0:g=${OV_VOL}:r=f32,$ARG_EQ_MID_HIGH"
  #ARG_EQ_MID="equalizer=f=450.0:t=h:w=1400.0:g=${OV_VOL}:r=f32,$ARG_EQ_MID_HIGH"
  #ARG_EQ_MID="equalizer=f=425.0:t=h:w=1500.0:g=${OV_VOL}:r=f32,$ARG_EQ_MID_HIGH"

  # f=1200.0,2200.0: This value greatly changes the sound quality
  ##ARG_EQ_HIGH="equalizer=f=1200.0:t=h:w=100.0:g=+10:r=f32"
  ##ARG_EQ_HIGH="equalizer=f=1200.0:t=h:w=100.0:g=+10:r=f32,equalizer=f=1174.7:t=h:w=10.0:g=-12:r=f32,equalizer=f=1760.0:t=h:w=50.0:g=-12:r=f32,equalizer=f=1864.7:t=h:w=50.0:g=-20:r=f32"
  # V5.0RC3
  #ARG_EQ_HIGH="equalizer=f=1200.0:t=h:w=100.0:g=+10:r=f32,equalizer=f=1760.0:t=h:w=50.0:g=-12:r=f32,equalizer=f=1864.7:t=h:w=50.0:g=-20:r=f32,equalizer=f=2200.0:t=h:w=700.0:g=-3:r=f32"
  # TEST1
  #ARG_EQ_HIGH="equalizer=f=1174.659:t=h:w=50.0:g=+3:r=f32,equalizer=f=1318.51:t=h:w=50.0:g=+9:r=f32,equalizer=f=1479.978:t=h:w=50.0:g=+5:r=f32,equalizer=f=1567.982:t=h:w=50.0:g=+5:r=f32,equalizer=f=1760.0:t=h:w=50.0:g=-12:r=f32,equalizer=f=1864.7:t=h:w=50.0:g=-20:r=f32,equalizer=f=2200.0:t=h:w=700.0:g=-3:r=f32"
  # TEST2
  #ARG_EQ_HIGH="equalizer=f=1174.659:t=h:w=50.0:g=+5:r=f32,equalizer=f=1318.51:t=h:w=50.0:g=+0:r=f32,equalizer=f=1479.978:t=h:w=50.0:g=+2:r=f32,equalizer=f=1567.982:t=h:w=50.0:g=-6:r=f32,equalizer=f=1760.0:t=h:w=50.0:g=-18:r=f32,equalizer=f=1864.7:t=h:w=50.0:g=-20:r=f32,equalizer=f=2200.0:t=h:w=700.0:g=-0:r=f32"
  # V5.0
  ARG_EQ_HIGH="equalizer=f=1200.0:t=h:w=100.0:g=+8:r=f32,equalizer=f=1760.0:t=h:w=50.0:g=-12:r=f32,equalizer=f=1864.7:t=h:w=50.0:g=-20:r=f32,equalizer=f=2200.0:t=h:w=700.0:g=-3:r=f32"
  # V5.0TEST
  ARG_EQ_HIGH="equalizer=f=1179:t=h:w=100.0:g=+9:r=f32,equalizer=f=1312:t=h:w=100.0:g=+5:r=f32,equalizer=f=1444:t=h:w=100.0:g=+2:r=f32,equalizer=f=1760.0:t=h:w=50.0:g=-12:r=f32,equalizer=f=1864.7:t=h:w=50.0:g=-20:r=f32,equalizer=f=2200.0:t=h:w=700.0:g=${TONE_BALANCE_2200HZ}:r=f32"

  "$FFMPEG" -i $PCM_IN -af afade=t=out:st=${T_ST_0}:d=${T_D_0}:silence=0.0:curve=tri,equalizer=f=130.8:t=h:w=1.0:g=${FUND_GAIN_FIRST}:r=f32,${ARG_EQ_MID},${ARG_EQ_HIGH} -c:a pcm_f32le _tmp_sub_1.wav

  "$FFMPEG" -i $PCM_IN -af afade=t=in:st=${T_ST_0}:d=${T_D_0}:silence=0.0:curve=tri,equalizer=f=130.8:t=h:w=1.0:g=${FUND_GAIN_LAST}:r=f32,${ARG_EQ_MID},${ARG_EQ_HIGH} -c:a pcm_f32le _tmp_sub_2.wav

  "$FFMPEG" -i _tmp_sub_1.wav -i _tmp_sub_2.wav -filter_complex "amix=inputs=2:normalize=0,volume=1.0" -c:a pcm_f32le $PCM_OUT


  ####
  #### Adjustment of overtone C5(523.3Hz), E5(659.255Hz) and G5(783.991Hz) on latter part
  ####
  PCM_IN=_tmp_sub_p1.wav
  PCM_OUT=_tmp_sub_p2.wav

  T_ST_0=0.5
  T_D_0=8.0

  "$FFMPEG" -i $PCM_IN -af afade=t=out:st=${T_ST_0}:d=${T_D_0}:silence=0.0:curve=tri -c:a pcm_f32le _tmp_sub_3.wav

  "$FFMPEG" -i $PCM_IN -af afade=t=in:st=${T_ST_0}:d=${T_D_0}:silence=0.0:curve=tri,equalizer=f=659:t=h:w=150.0:g=-10:r=f32,equalizer=f=523.3:t=h:w=50.0:g=-10:r=f32 -c:a pcm_f32le _tmp_sub_4.wav

  "$FFMPEG" -i _tmp_sub_3.wav -i _tmp_sub_4.wav -filter_complex "amix=inputs=2:normalize=0,volume=1.0" -c:a pcm_f32le $PCM_OUT


  ####
  #### Adjustment of overtone around 1500Hz Part 1
  #### --- reduce overtone at high freq.
  ####
  PCM_IN=_tmp_sub_p2.wav
  PCM_OUT=_tmp_sub_p3.wav

  EQ_F=1500
  EQ_W=500

  ATACK_SILENCE=0.175

  T_ST_0=0.0
  T_D_0=`echo 2.25 $ATACK_SILENCE | awk '{printf("%g\n",$1 * (1.0-$2));}'`

  # This value greatly changes the sound quality
  FACTOR_REDUCE=0.15
  INV_FACTOR_REDUCE=`echo $FACTOR_REDUCE | awk '{printf("%g\n",1.0-$1);}'`

  # TEST RESULT: volume=+0.5dB
  "$FFMPEG" -i $PCM_IN -af afade=t=in:st=${T_ST_0}:d=${T_D_0}:silence=${FACTOR_REDUCE}:curve=tri,equalizer=f=${EQ_F}:t=h:w=${EQ_W}:g=-33.0:r=f32,equalizer=f=932.3:t=h:w=50.0:g=-10:r=f32,volume=+0.5dB -c:a pcm_f32le _tmp_sub_6.wav

  "$FFMPEG" -i $PCM_IN -af afade=t=out:st=${T_ST_0}:d=${T_D_0}:silence=${ATACK_SILENCE}:curve=tri,volume=${INV_FACTOR_REDUCE} -c:a pcm_f32le _tmp_sub_7.wav

  "$FFMPEG" -i _tmp_sub_6.wav -i _tmp_sub_7.wav -filter_complex "amix=inputs=2:normalize=0,volume=1.0" -c:a pcm_f32le $PCM_OUT


  ####
  #### Adjustment of overtone around 1500Hz Part 2
  ####
  PCM_IN=_tmp_sub_p3.wav
  PCM_OUT=_tmp_sub_p4.wav

  # Fix attack #1

  # This value (1800,750) is very critical !
  EQ_F=1800
  EQ_W=750

  T_ST_0=0.0
  #T_D_0=2.0
  T_D_0=10.0

  #########      v1     v2     v3     v4     v5     v6     v7     v8     v9    v10    v11    v12    v13    v14    v15    v16
  # V5.0RC3
  #ATACK_VOL_BASE=-0.7
  #ATACK_VOL="  +4.5   +1.0   +1.2   +4.7   +4.8   +4.9   +5.1   +5.1   +5.1   +5.6   +5.2   +5.2   +5.1   +7.1   +6.2   +6.2"
  # V5.0
  ATACK_VOL_BASE=-1.8
  ATACK_VOL="  +0.0   +1.0   +1.2   +4.7   +4.8   +4.9   +5.1   +5.1   +5.1   +5.6   +5.2   +5.2   +5.1   +7.1   +6.2   +6.2"
  #
  A_VOL=`echo $VEL $ATACK_VOL | awk '{ split($0,ARR," "); printf("%g\n",ARR[1 + ARR[1]] + ('${ATACK_VOL_BASE}')); }'`

  #"$FFMPEG" -i $PCM_IN -af afade=t=out:st=${T_ST_0}:d=${T_D_0}:silence=0.0:curve=tri,equalizer=f=${EQ_F}:t=h:w=${EQ_W}:g=${A_VOL}:r=f32 -c:a pcm_f32le _tmp_sub_8.wav
  #V5.0TEST
  "$FFMPEG" -i $PCM_IN -af afade=t=out:st=${T_ST_0}:d=${T_D_0}:silence=0.0:curve=tri,equalizer=f=${EQ_F}:t=h:w=${EQ_W}:g=${A_VOL}:r=f32,equalizer=f=523.3:t=h:w=50.0:g=${TONE_BALANCE_C5}:r=f32 -c:a pcm_f32le _tmp_sub_8.wav

  "$FFMPEG" -i $PCM_IN -af afade=t=in:st=${T_ST_0}:d=${T_D_0}:silence=0.0:curve=tri -c:a pcm_f32le _tmp_sub_9.wav

  # Fix attack #2

  ###"$FFMPEG" -i $PCM_IN -af afade=t=out:st=0:d=0.15:silence=0.0:curve=tri,volume=-20dB -c:a pcm_f32le _tmp_sub_a.wav
  ###"$FFMPEG" -i $PCM_IN -af afade=t=out:st=0:d=0.15:silence=0.0:curve=tri,volume=-80dB -c:a pcm_f32le _tmp_sub_a.wav

  ###"$FFMPEG" -i _tmp_sub_8.wav -i _tmp_sub_9.wav -i _tmp_sub_a.wav -filter_complex "amix=inputs=3:normalize=0,volume=1.0" -c:a pcm_f32le $PCM_OUT

  "$FFMPEG" -i _tmp_sub_8.wav -i _tmp_sub_9.wav -filter_complex "amix=inputs=2:normalize=0,volume=1.0" -c:a pcm_f32le $PCM_OUT


  ####
  #### Final overtone adjustment
  ####
  PCM_IN=_tmp_sub_p4.wav
  PCM_OUT=_tmp_sub_p5.wav

  #########      v1     v2     v3     v4     v5     v6     v7     v8     v9    v10    v11    v12    v13    v14    v15    v16
  # V5.0RC3
  #HPASS_VOL="  -6dB  -10dB  -3.9dB -2.9dB -2.8dB -2.7dB -2.6dB -2.5dB  -1dB   -0dB   -0dB   -0dB   -0dB   +3dB   -0dB   -0dB"
  # V5.0
  HPASS_VOL="  -20dB  -10dB  -3.9dB -2.9dB -2.8dB -2.7dB -2.6dB -2.5dB  -1dB   -0dB   -0dB   -0dB   -0dB   +3dB   -0dB   -0dB"
  OUTPT_VOL="    1.0    1.0   1.0    1.0    1.0    1.0    1.0    1.0    1.0    1.0    1.0    1.0    1.0    1.0    1.0    1.0"
  #
  H_VOL=`echo $VEL $HPASS_VOL | awk '{ split($0,ARR," "); print ARR[1 + ARR[1]]; }'`
  O_VOL=`echo $VEL $OUTPT_VOL | awk '{ split($0,ARR," "); print ARR[1 + ARR[1]]; }'`

  # Enhance overtone
  ####"$FFMPEG" -i $PCM_IN -af highpass=f=230.0:t=q:w=0.707:r=f32,volume=$H_VOL -c:a pcm_f32le _tmp_sub_b.wav
  "$FFMPEG" -i $PCM_IN -af highpass=f=330.0:t=q:w=0.707:r=f32,volume=$H_VOL -c:a pcm_f32le _tmp_sub_b.wav
  "$FFMPEG" -i $PCM_IN -i _tmp_sub_b.wav -filter_complex "amix=normalize=0,volume=${O_VOL}" -c:a pcm_f32le $PCM_OUT

  ###"$FFMPEG" -i $PCM_IN -af volume=-6dB,equalizer=f=1500:t=h:w=500:g=+20:r=f32 -c:a pcm_f32le $PCM_OUT

  cat $PCM_OUT > $OUT_FILE

  ############################################################################
  ############################################################################

fi

