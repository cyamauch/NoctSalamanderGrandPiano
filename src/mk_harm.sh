#!/bin/sh

#if [ "$1" = "" ]; then
#  echo "[USAGE]"
#  echo "$0 FFMPEG"
#  exit
#fi

SRC_DIR=../SalamanderGrandPianoV3_48khz24bit/48khz24bit
DEST_DIR=./harm_corr

FFMPEG_HARM_LOG_FILE="ffmpeg-harm_log.txt"
COEFF_B_SPAN=8.5

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

if [ -f "$2" ]; then
  SRC_DIR="$2"
fi

if [ -f "$3" ]; then
  DEST_DIR="$3"
fi

#
# Copy ALL
#

mkdir -p $DEST_DIR
cp -p $SRC_DIR/harmL*.wav $DEST_DIR/.
cp -p $SRC_DIR/harmS*.wav $DEST_DIR/.
cp -p $SRC_DIR/harmV3*.wav $DEST_DIR/.

#
# harmLF#2 ... Mechanical noise at the 2.1-second -> Delete the section from 2.1 seconds onwards.
#

IN_FILE="$SRC_DIR/harmLF#2.wav"
OUT_FILE="$DEST_DIR/harmLF#2.wav"

echo "Correct: $IN_FILE -> $OUT_FILE"

rm -f _tmp_sub_0.wav $OUT_FILE

"$FFMPEG" -i $IN_FILE -af afade=t=out:st=1.60:d=0.5:silence=0.0:curve=tri -c:a pcm_f32le _tmp_sub_0.wav 2> /dev/null
"$FFMPEG" -i _tmp_sub_0.wav -ss 0.00 -t 2.10 -c:a pcm_f32le $OUT_FILE 2> /dev/null


#
# harmLC3 ... Mechanical noise at the 1.58-second -> Delete the section from 1.58 seconds onwards.
#

IN_FILE="$SRC_DIR/harmLC3.wav"
OUT_FILE="$DEST_DIR/harmLC3.wav"

echo "Correct: $IN_FILE -> $OUT_FILE"

rm -f _tmp_sub_0.wav $OUT_FILE

"$FFMPEG" -i $IN_FILE -af afade=t=out:st=1.30:d=0.3:silence=0.0:curve=tri -c:a pcm_f32le _tmp_sub_0.wav 2> /dev/null
"$FFMPEG" -i _tmp_sub_0.wav -ss 0.00 -t 1.60 -c:a pcm_f32le $OUT_FILE 2> /dev/null


#
# harmLA3 ... Mechanical noise at the 2.09-second -> Delete the section from 2.09 seconds onwards.
#

IN_FILE="$SRC_DIR/harmLA3.wav"
OUT_FILE="$DEST_DIR/harmLA3.wav"

echo "Correct: $IN_FILE -> $OUT_FILE"

rm -f _tmp_sub_0.wav $OUT_FILE

"$FFMPEG" -i $IN_FILE -af afade=t=out:st=1.60:d=0.5:silence=0.0:curve=tri -c:a pcm_f32le _tmp_sub_0.wav 2> /dev/null
"$FFMPEG" -i _tmp_sub_0.wav -ss 0.00 -t 2.10 -c:a pcm_f32le $OUT_FILE 2> /dev/null


#
# harmSA0 ... Mechanical noise present at the 1.0-second -> Removed that section.
#

IN_FILE="$SRC_DIR/harmSA0.wav"
OUT_FILE="$DEST_DIR/harmSA0.wav"

echo "Correct: $IN_FILE -> $OUT_FILE"

rm -f _tmp_sub_0.wav _tmp_sub_1.wav $OUT_FILE

"$FFMPEG" -i $IN_FILE -ss 0.00 -t 1.00 -c:a pcm_f32le _tmp_sub_0.wav 2> /dev/null
"$FFMPEG" -i $IN_FILE -ss 1.30         -c:a pcm_f32le _tmp_sub_1.wav 2> /dev/null

"$FFMPEG" -i _tmp_sub_0.wav -i _tmp_sub_1.wav -filter_complex concat=n=2:v=0:a=1 -c:a pcm_f32le $OUT_FILE 2> /dev/null


#
# harmSF#1 ... Mechanical noise present at the 0.77-second -> Removed that section.
#

IN_FILE="$SRC_DIR/harmSF#1.wav"
OUT_FILE="$DEST_DIR/harmSF#1.wav"

echo "Correct: $IN_FILE -> $OUT_FILE"

rm -f _tmp_sub_0.wav _tmp_sub_1.wav $OUT_FILE

"$FFMPEG" -i $IN_FILE -af afade=t=out:st=0.639:d=0.001:silence=0.0:curve=tri -ss 0.00 -t 0.640 -c:a pcm_f32le _tmp_sub_0.wav 2> /dev/null
"$FFMPEG" -i $IN_FILE -af afade=t=in:st=0.820:d=0.001:silence=0.0:curve=tri,afade=t=out:st=1.300:d=0.700:silence=0.0:curve=tri -ss 0.820 -c:a pcm_f32le _tmp_sub_1.wav 2> /dev/null

"$FFMPEG" -i _tmp_sub_0.wav -i _tmp_sub_1.wav -filter_complex concat=n=2:v=0:a=1 -c:a pcm_f32le $OUT_FILE 2> /dev/null


#
# harmSD#2 ... Mechanical noise present at the 0.78-second -> Removed that section.
#

IN_FILE="$SRC_DIR/harmSD#2.wav"
OUT_FILE="$DEST_DIR/harmSD#2.wav"

echo "Correct: $IN_FILE -> $OUT_FILE"

rm -f _tmp_sub_0.wav _tmp_sub_1.wav $OUT_FILE

"$FFMPEG" -i $IN_FILE -af afade=t=out:st=0.794:d=0.001:silence=0.0:curve=tri -ss 0.00 -t 0.795 -c:a pcm_f32le _tmp_sub_0.wav 2> /dev/null
"$FFMPEG" -i $IN_FILE -af afade=t=in:st=1.000:d=0.001:silence=0.0:curve=tri  -ss 1.000 -c:a pcm_f32le _tmp_sub_1.wav 2> /dev/null

"$FFMPEG" -i _tmp_sub_0.wav -i _tmp_sub_1.wav -filter_complex concat=n=2:v=0:a=1 -c:a pcm_f32le $OUT_FILE 2> /dev/null


#
# harmSA2 ... Noise present in two locations (issue persists).
#

OUT_FILE="$DEST_DIR/harmSA2.wav"

USE_HARML=1

if [ "$USE_HARML" = "1" ]; then

  IN_FILE="$DEST_DIR/harmLA2.wav"

  echo "Convert: $IN_FILE -> $OUT_FILE"

  rm -f $OUT_FILE

  "$FFMPEG" -i $IN_FILE -af volume=-${COEFF_B_SPAN}dB,equalizer=f=4000:t=h:w=4000:g=-18:r=f32 -c:a pcm_f32le $OUT_FILE 2> /dev/null

else 

  IN_FILE="$SRC_DIR/harmSA2.wav"

  #echo "Correct: $IN_FILE -> $OUT_FILE"

  #rm -f _tmp_sub_0.wav _tmp_sub_1.wav _tmp_sub_2.wav $OUT_FILE

  #"$FFMPEG" -i $IN_FILE -af afade=t=out:st=0.121:d=0.001:silence=0.0:curve=tri -ss 0.00 -t 0.122 -c:a pcm_f32le _tmp_sub_0.wav 2> /dev/null
  ##"$FFMPEG" -i $IN_FILE -af afade=t=in:st=0.150:d=0.001:silence=0.0:curve=tri,afade=t=out:st=0.441:d=0.001:silence=0.0:curve=tri -ss 0.150 -t 0.292 -c:a pcm_f32le _tmp_sub_1.wav 2> /dev/null
  #"$FFMPEG" -i $IN_FILE -af afade=t=in:st=0.150:d=0.001:silence=0.0:curve=tri,afade=t=out:st=0.358:d=0.001:silence=0.0:curve=tri -ss 0.150 -t 0.209 -c:a pcm_f32le _tmp_sub_1.wav 2> /dev/null
  ##"$FFMPEG" -i $IN_FILE -af afade=t=in:st=0.469:d=0.001:silence=0.0:curve=tri -ss 0.492 -c:a pcm_f32le _tmp_sub_2.wav 2> /dev/null
  #"$FFMPEG" -i $IN_FILE -af afade=t=in:st=0.545:d=0.001:silence=0.0:curve=tri -ss 0.545 -c:a pcm_f32le _tmp_sub_2.wav 2> /dev/null

  #"$FFMPEG" -i _tmp_sub_0.wav -i _tmp_sub_1.wav -i _tmp_sub_2.wav -filter_complex concat=n=3:v=0:a=1 -c:a pcm_f32le $OUT_FILE 2> /dev/null

fi


#
# harmSC3 ... Mechanical noise present at first
#

OUT_FILE="$DEST_DIR/harmSC3.wav"

USE_HARML=1

if [ "$USE_HARML" = "1" ]; then

  IN_FILE="$DEST_DIR/harmLC3.wav"

  echo "Convert: $IN_FILE -> $OUT_FILE"

  rm -f $OUT_FILE

  "$FFMPEG" -i $IN_FILE -af volume=-${COEFF_B_SPAN}dB,equalizer=f=4000:t=h:w=4000:g=-36:r=f32 -c:a pcm_f32le $OUT_FILE 2> /dev/null

fi


#
# harmSD#3 ... Mechanical noise present at the 0.08-second
#

OUT_FILE="$DEST_DIR/harmSD#3.wav"

USE_HARML=1

if [ "$USE_HARML" = "1" ]; then

  IN_FILE="$DEST_DIR/harmLD#3.wav"

  echo "Convert: $IN_FILE -> $OUT_FILE"

  rm -f $OUT_FILE

  "$FFMPEG" -i $IN_FILE -af volume=-${COEFF_B_SPAN}dB,equalizer=f=4000:t=h:w=4000:g=-30:r=f32 -c:a pcm_f32le $OUT_FILE 2> /dev/null

else

  IN_FILE="$SRC_DIR/harmSD#3.wav"

  echo "Correct: $IN_FILE -> $OUT_FILE"

  rm -f $OUT_FILE

  #"$FFMPEG" -i $IN_FILE -af afade=t=out:st=0.070:d=0.001:silence=0.55:curve=tri,afade=t=in:st=0.095:d=0.001:silence=0.55:curve=tri -c:a pcm_f32le $OUT_FILE 2> /dev/null
  "$FFMPEG" -i $IN_FILE -af afade=t=out:st=0.055:d=0.001:silence=0.55:curve=tri,afade=t=in:st=0.095:d=0.001:silence=0.55:curve=tri -c:a pcm_f32le $OUT_FILE 2> /dev/null

fi


#
# harmSF#3 ... Mechanical noise present at the 0.11-second
#

OUT_FILE="$DEST_DIR/harmSF#3.wav"

USE_HARML=1

if [ "$USE_HARML" = "1" ]; then

  IN_FILE="$DEST_DIR/harmLF#3.wav"

  echo "Convert: $IN_FILE -> $OUT_FILE"

  rm -f $OUT_FILE

  "$FFMPEG" -i $IN_FILE -af volume=-${COEFF_B_SPAN}dB,equalizer=f=4000:t=h:w=4000:g=-36:r=f32 -c:a pcm_f32le $OUT_FILE 2> /dev/null

else

  IN_FILE="$SRC_DIR/harmSF#3.wav"

  echo "Correct: $IN_FILE -> $OUT_FILE"

  rm -f $OUT_FILE

  "$FFMPEG" -i $IN_FILE -af afade=t=out:st=0.042:d=0.001:silence=0.55:curve=tri,afade=t=in:st=0.135:d=0.001:silence=0.55:curve=tri -c:a pcm_f32le $OUT_FILE 2> /dev/null

fi


#
# harmSA3 ... Mechanical noise present at the 0.36-second -> Removed that section.
#

OUT_FILE="$DEST_DIR/harmSA3.wav"

USE_HARML=1

if [ "$USE_HARML" = "1" ]; then

  IN_FILE="$DEST_DIR/harmLA3.wav"

  echo "Convert: $IN_FILE -> $OUT_FILE"

  rm -f $OUT_FILE

  "$FFMPEG" -i $IN_FILE -af volume=-${COEFF_B_SPAN}dB,equalizer=f=4000:t=h:w=4000:g=-42:r=f32 -c:a pcm_f32le $OUT_FILE 2> /dev/null

else

  IN_FILE="$SRC_DIR/harmSA3.wav"

  echo "Correct: $IN_FILE -> $OUT_FILE"

  rm -f _tmp_sub_0.wav _tmp_sub_1.wav _tmp_sub_2.wav $OUT_FILE

  #"$FFMPEG" -i $IN_FILE -af afade=t=out:st=0.065:d=0.001:silence=0.5:curve=tri,afade=t=in:st=0.105:d=0.001:silence=0.5:curve=tri -c:a pcm_f32le _tmp_sub_0.wav 2> /dev/null
  "$FFMPEG" -i $IN_FILE -af afade=t=out:st=0.050:d=0.001:silence=0.55:curve=tri,afade=t=in:st=0.105:d=0.001:silence=0.55:curve=tri -c:a pcm_f32le _tmp_sub_0.wav 2> /dev/null

  "$FFMPEG" -i _tmp_sub_0.wav -af afade=t=out:st=0.354:d=0.001:silence=0.0:curve=tri -ss 0.00 -t 0.355 -c:a pcm_f32le _tmp_sub_1.wav 2> /dev/null
  "$FFMPEG" -i _tmp_sub_0.wav -af afade=t=in:st=0.500:d=0.001:silence=0.0:curve=tri  -ss 0.500 -c:a pcm_f32le _tmp_sub_2.wav 2> /dev/null

  "$FFMPEG" -i _tmp_sub_1.wav -i _tmp_sub_2.wav -filter_complex concat=n=2:v=0:a=1 -c:a pcm_f32le $OUT_FILE 2> /dev/null

fi


#
# harmSC4 ... Mechanical noise occurred three times -> Those sections were removed.
#

OUT_FILE="$DEST_DIR/harmSC4.wav"

USE_HARML=1

if [ "$USE_HARML" = "1" ]; then

  IN_FILE="$DEST_DIR/harmLC4.wav"

  echo "Convert: $IN_FILE -> $OUT_FILE"

  rm -f $OUT_FILE

  "$FFMPEG" -i $IN_FILE -af volume=-${COEFF_B_SPAN}dB,equalizer=f=4000:t=h:w=4000:g=-42:r=f32 -c:a pcm_f32le $OUT_FILE 2> /dev/null

else

  IN_FILE="$SRC_DIR/harmSC4.wav"

  echo "Correct: $IN_FILE -> $OUT_FILE"

  rm -f _tmp_sub_0.wav _tmp_sub_1.wav _tmp_sub_2.wav _tmp_sub_3.wav _tmp_sub_4.wav $OUT_FILE

  "$FFMPEG" -i $IN_FILE -af afade=t=out:st=0.429:d=0.001:silence=0.0:curve=tri -ss 0.00 -t 0.430 -c:a pcm_f32le _tmp_sub_0.wav 2> /dev/null
  "$FFMPEG" -i $IN_FILE -af afade=t=in:st=0.600:d=0.001:silence=0.0:curve=tri,afade=t=out:st=0.979:d=0.001:silence=0.0:curve=tri -ss 0.600 -t 0.380 -c:a pcm_f32le _tmp_sub_1.wav 2> /dev/null
  "$FFMPEG" -i $IN_FILE -af afade=t=in:st=1.150:d=0.001:silence=0.0:curve=tri,afade=t=out:st=1.399:d=0.001:silence=0.0:curve=tri -ss 1.150 -t 0.250 -c:a pcm_f32le _tmp_sub_2.wav 2> /dev/null
  "$FFMPEG" -i $IN_FILE -af afade=t=in:st=1.550:d=0.001:silence=0.0:curve=tri -ss 1.550 -c:a pcm_f32le _tmp_sub_3.wav 2> /dev/null

  "$FFMPEG" -i _tmp_sub_0.wav -i _tmp_sub_1.wav -i _tmp_sub_2.wav -i _tmp_sub_3.wav -filter_complex concat=n=4:v=0:a=1 -c:a pcm_f32le _tmp_sub_4.wav 2> /dev/null

  cat _tmp_sub_4.wav > $OUT_FILE

fi


#
# harmSD#4 ... Mechanical noise at first
#

OUT_FILE="$DEST_DIR/harmSD#4.wav"

USE_HARML=1

if [ "$USE_HARML" = "1" ]; then

  IN_FILE="$DEST_DIR/harmLD#4.wav"

  echo "Convert: $IN_FILE -> $OUT_FILE"

  rm -f $OUT_FILE

  "$FFMPEG" -i $IN_FILE -af volume=-${COEFF_B_SPAN}dB,equalizer=f=4000:t=h:w=4000:g=-30:r=f32 -c:a pcm_f32le $OUT_FILE 2> /dev/null

fi


#
# harmSF#4 ... Mechanical noise at first
#

OUT_FILE="$DEST_DIR/harmSF#4.wav"

USE_HARML=1

if [ "$USE_HARML" = "1" ]; then

  IN_FILE="$DEST_DIR/harmLF#4.wav"

  echo "Convert: $IN_FILE -> $OUT_FILE"

  rm -f $OUT_FILE

  "$FFMPEG" -i $IN_FILE -af volume=-${COEFF_B_SPAN}dB,equalizer=f=5000:t=h:w=4000:g=-36:r=f32 -c:a pcm_f32le $OUT_FILE 2> /dev/null

fi


#
# harmSA4 ... Mechanical noise present at the 0.78-second -> Removed that section.
#

OUT_FILE="$DEST_DIR/harmSA4.wav"

USE_HARML=1

if [ "$USE_HARML" = "1" ]; then

  IN_FILE="$DEST_DIR/harmLA4.wav"

  echo "Convert: $IN_FILE -> $OUT_FILE"

  rm -f $OUT_FILE

  "$FFMPEG" -i $IN_FILE -af volume=-${COEFF_B_SPAN}dB,equalizer=f=5000:t=h:w=5000:g=-30:r=f32 -c:a pcm_f32le $OUT_FILE 2> /dev/null

else

  IN_FILE="$SRC_DIR/harmSA4.wav"

  echo "Correct: $IN_FILE -> $OUT_FILE"

  rm -f _tmp_sub_0.wav _tmp_sub_1.wav $OUT_FILE

  "$FFMPEG" -i $IN_FILE -ss 0.00 -t 0.74 -c:a pcm_f32le _tmp_sub_0.wav 2> /dev/null
  "$FFMPEG" -i $IN_FILE -af afade=t=in:st=1.000:d=0.001:silence=0.0:curve=tri  -ss 1.000 -c:a pcm_f32le _tmp_sub_1.wav 2> /dev/null

  "$FFMPEG" -i _tmp_sub_0.wav -i _tmp_sub_1.wav -filter_complex concat=n=2:v=0:a=1 -c:a pcm_f32le $OUT_FILE 2> /dev/null

fi


#
# harmSC5 ... Mechanical noise present at first
#

OUT_FILE="$DEST_DIR/harmSC5.wav"

USE_HARML=1

if [ "$USE_HARML" = "1" ]; then

  IN_FILE="$DEST_DIR/harmLC5.wav"

  echo "Convert: $IN_FILE -> $OUT_FILE"

  rm -f $OUT_FILE

  "$FFMPEG" -i $IN_FILE -af volume=-${COEFF_B_SPAN}dB,equalizer=f=4000:t=h:w=4000:g=-36:r=f32 -c:a pcm_f32le $OUT_FILE 2> /dev/null

fi


#
# harmSD#5 ... Mechanical noise present at first
#

OUT_FILE="$DEST_DIR/harmSD#5.wav"

USE_HARML=1

if [ "$USE_HARML" = "1" ]; then

  IN_FILE="$DEST_DIR/harmLD#5.wav"

  echo "Convert: $IN_FILE -> $OUT_FILE"

  rm -f $OUT_FILE

  "$FFMPEG" -i $IN_FILE -af volume=-${COEFF_B_SPAN}dB,equalizer=f=5000:t=h:w=5000:g=-36:r=f32 -c:a pcm_f32le $OUT_FILE 2> /dev/null

fi


#
# harmSF#5 ... Two volume peaks present -> Remove the second section.
#

OUT_FILE="$DEST_DIR/harmSF#5.wav"

USE_HARML=1

if [ "$USE_HARML" = "1" ]; then

  IN_FILE="$DEST_DIR/harmLF#5.wav"

  echo "Convert: $IN_FILE -> $OUT_FILE"

  rm -f $OUT_FILE

  "$FFMPEG" -i $IN_FILE -af volume=-${COEFF_B_SPAN}dB,equalizer=f=4500:t=h:w=4000:g=-30:r=f32 -c:a pcm_f32le $OUT_FILE 2> /dev/null

else

  IN_FILE="$SRC_DIR/harmSF#5.wav"

  echo "Correct: $IN_FILE -> $OUT_FILE"

  rm -f _tmp_sub_0.wav _tmp_sub_1.wav $OUT_FILE

  #"$FFMPEG" -i $IN_FILE -af afade=t=out:st=0.354:d=0.001:silence=0.0:curve=tri -ss 0.00 -t 0.355 -c:a pcm_f32le _tmp_sub_0.wav 2> /dev/null
  "$FFMPEG" -i $IN_FILE -af afade=t=out:st=0.265:d=0.001:silence=0.0:curve=tri -ss 0.00 -t 0.266 -c:a pcm_f32le _tmp_sub_0.wav 2> /dev/null
  "$FFMPEG" -i $IN_FILE -af afade=t=in:st=0.600:d=0.001:silence=0.0:curve=tri -ss 0.600 -c:a pcm_f32le _tmp_sub_1.wav 2> /dev/null

  "$FFMPEG" -i _tmp_sub_0.wav -i _tmp_sub_1.wav -filter_complex concat=n=2:v=0:a=1 -c:a pcm_f32le $OUT_FILE 2> /dev/null

fi


#
# harmSA5 ... Mechanical noise present at first
#

OUT_FILE="$DEST_DIR/harmSA5.wav"

USE_HARML=1

if [ "$USE_HARML" = "1" ]; then

  IN_FILE="$DEST_DIR/harmLA5.wav"

  echo "Convert: $IN_FILE -> $OUT_FILE"

  rm -f $OUT_FILE

  "$FFMPEG" -i $IN_FILE -af volume=-${COEFF_B_SPAN}dB,equalizer=f=4500:t=h:w=3500:g=-30:r=f32 -c:a pcm_f32le $OUT_FILE 2> /dev/null

fi


#
# harmSC6 ... Mechanical noise present at first
#

OUT_FILE="$DEST_DIR/harmSC6.wav"

USE_HARML=1

if [ "$USE_HARML" = "1" ]; then

  IN_FILE="$DEST_DIR/harmLC6.wav"

  echo "Convert: $IN_FILE -> $OUT_FILE"

  rm -f $OUT_FILE

  "$FFMPEG" -i $IN_FILE -af volume=-${COEFF_B_SPAN}dB,equalizer=f=4500:t=h:w=3000:g=-36:r=f32 -c:a pcm_f32le $OUT_FILE 2> /dev/null

fi


#
# harmSD#6 ... Noise around the 1.0-second mark, and mechanical noise at 1.7 seconds.
#

OUT_FILE="$DEST_DIR/harmSD#6.wav"

USE_HARML=1

if [ "$USE_HARML" = "1" ]; then

  IN_FILE="$DEST_DIR/harmLD#6.wav"

  echo "Convert: $IN_FILE -> $OUT_FILE"

  rm -f $OUT_FILE

  "$FFMPEG" -i $IN_FILE -af volume=-${COEFF_B_SPAN}dB,equalizer=f=4500:t=h:w=3000:g=-12:r=f32 -c:a pcm_f32le $OUT_FILE 2> /dev/null

else

  IN_FILE="$SRC_DIR/harmSD#6.wav"

  echo "Correct: $IN_FILE -> $OUT_FILE"

  rm -f _tmp_sub_0.wav $OUT_FILE

  "$FFMPEG" -i $IN_FILE -af afade=t=out:st=0.6:d=0.8:silence=0.0:curve=tri -c:a pcm_f32le _tmp_sub_0.wav 2> /dev/null
  "$FFMPEG" -i _tmp_sub_0.wav -ss 0.00 -t 1.40 -c:a pcm_f32le $OUT_FILE 2> /dev/null

fi


################################################################


#
# harmV3F#1 ... Mechanical noise present at the 0.69-second -> Removed that section.
#

IN_FILE="$SRC_DIR/harmV3F#1.wav"
OUT_FILE="$DEST_DIR/harmV3F#1.wav"

echo "Correct: $IN_FILE -> $OUT_FILE"

rm -f _tmp_sub_0.wav _tmp_sub_1.wav $OUT_FILE

"$FFMPEG" -i $IN_FILE -af afade=t=out:st=0.698:d=0.001:silence=0.0:curve=tri -ss 0.00 -t 0.699 -c:a pcm_f32le _tmp_sub_0.wav 2> /dev/null
#"$FFMPEG" -i $IN_FILE -af afade=t=in:st=0.802:d=0.001:silence=0.0:curve=tri  -ss 0.802         -c:a pcm_f32le _tmp_sub_1.wav 2> /dev/null
"$FFMPEG" -i $IN_FILE -af afade=t=in:st=0.846:d=0.001:silence=0.0:curve=tri  -ss 0.846         -c:a pcm_f32le _tmp_sub_1.wav 2> /dev/null
#"$FFMPEG" -i $IN_FILE -af afade=t=in:st=0.895:d=0.001:silence=0.0:curve=tri  -ss 0.895         -c:a pcm_f32le _tmp_sub_1.wav 2> /dev/null

"$FFMPEG" -i _tmp_sub_0.wav -i _tmp_sub_1.wav -filter_complex concat=n=2:v=0:a=1 -c:a pcm_f32le $OUT_FILE 2> /dev/null


#
# harmV3F#2 ... Mechanical noise present at the 0.2-second -> Removed that section.
#

IN_FILE="$SRC_DIR/harmV3F#2.wav"
OUT_FILE="$DEST_DIR/harmV3F#2.wav"

echo "Correct: $IN_FILE -> $OUT_FILE"

rm -f _tmp_sub_0.wav _tmp_sub_1.wav $OUT_FILE

"$FFMPEG" -i $IN_FILE -af afade=t=out:st=0.207:d=0.001:silence=0.0:curve=tri -ss 0.00 -t 0.208 -c:a pcm_f32le _tmp_sub_0.wav 2> /dev/null
#"$FFMPEG" -i $IN_FILE -af afade=t=in:st=0.257:d=0.001:silence=0.0:curve=tri  -ss 0.257         -c:a pcm_f32le _tmp_sub_1.wav 2> /dev/null
"$FFMPEG" -i $IN_FILE -af afade=t=in:st=0.320:d=0.001:silence=0.0:curve=tri  -ss 0.320         -c:a pcm_f32le _tmp_sub_1.wav 2> /dev/null

"$FFMPEG" -i _tmp_sub_0.wav -i _tmp_sub_1.wav -filter_complex concat=n=2:v=0:a=1 -c:a pcm_f32le $OUT_FILE 2> /dev/null


#
#harmV3A2 ... There is mechanical noise at the beginning ...
#             since it occurs in the first half of the off_time, it will be left as is.
#

#
#harmV3A3 ... Mechanical noise present at the 0.2-second -> Removed that section.
#

IN_FILE="$SRC_DIR/harmV3A3.wav"
OUT_FILE="$DEST_DIR/harmV3A3.wav"

echo "Correct: $IN_FILE -> $OUT_FILE"

rm -f _tmp_sub_0.wav _tmp_sub_1.wav $OUT_FILE

"$FFMPEG" -i $IN_FILE -af afade=t=out:st=0.209:d=0.001:silence=0.0:curve=tri -ss 0.00 -t 0.210 -c:a pcm_f32le _tmp_sub_0.wav 2> /dev/null
#"$FFMPEG" -i $IN_FILE -af afade=t=in:st=0.309:d=0.001:silence=0.0:curve=tri  -ss 0.309         -c:a pcm_f32le _tmp_sub_1.wav 2> /dev/null
"$FFMPEG" -i $IN_FILE -af afade=t=in:st=0.330:d=0.001:silence=0.0:curve=tri  -ss 0.330         -c:a pcm_f32le _tmp_sub_1.wav 2> /dev/null

"$FFMPEG" -i _tmp_sub_0.wav -i _tmp_sub_1.wav -filter_complex concat=n=2:v=0:a=1 -c:a pcm_f32le $OUT_FILE 2> /dev/null

#
# harmV3A4 ... Mechanical noise present at the 0.64-second -> Removed that section.
#

IN_FILE="$SRC_DIR/harmV3A4.wav"
OUT_FILE="$DEST_DIR/harmV3A4.wav"

echo "Correct: $IN_FILE -> $OUT_FILE"

rm -f _tmp_sub_0.wav _tmp_sub_1.wav $OUT_FILE

"$FFMPEG" -i $IN_FILE -ss 0.00 -t 0.635 -c:a pcm_f32le _tmp_sub_0.wav 2> /dev/null
"$FFMPEG" -i $IN_FILE -af afade=t=in:st=0.825:d=0.001:silence=0.0:curve=tri -ss 0.825 -c:a pcm_f32le _tmp_sub_1.wav 2> /dev/null

"$FFMPEG" -i _tmp_sub_0.wav -i _tmp_sub_1.wav -filter_complex concat=n=2:v=0:a=1 -c:a pcm_f32le $OUT_FILE 2> /dev/null


#
# harmV3C5 ... Mechanical noise present at 2.00 seconds -> Delete from 2.00 seconds onwards.
#

IN_FILE="$SRC_DIR/harmV3C5.wav"
OUT_FILE="$DEST_DIR/harmV3C5.wav"

echo "Correct: $IN_FILE -> $OUT_FILE"

rm -f $OUT_FILE

"$FFMPEG" -i $IN_FILE -af afade=t=out:st=1.900:d=0.100:silence=0.0:curve=tri -ss 0.00 -t 2.000 -c:a pcm_f32le $OUT_FILE 2> /dev/null


#
# harmV3F#5 ... Mechanical noise present at the 0.17-second -> Removed that section.
#

IN_FILE="$SRC_DIR/harmV3F#5.wav"
OUT_FILE="$DEST_DIR/harmV3F#5.wav"

echo "Correct: $IN_FILE -> $OUT_FILE"

rm -f _tmp_sub_0.wav _tmp_sub_1.wav $OUT_FILE

"$FFMPEG" -i $IN_FILE -af afade=t=out:st=0.165:d=0.001:silence=0.0:curve=tri -ss 0.00 -t 0.166 -c:a pcm_f32le _tmp_sub_0.wav 2> /dev/null
#"$FFMPEG" -i $IN_FILE -af afade=t=in:st=0.242:d=0.001:silence=0.0:curve=tri  -ss 0.242         -c:a pcm_f32le _tmp_sub_1.wav 2> /dev/null
#"$FFMPEG" -i $IN_FILE -af afade=t=in:st=0.272:d=0.001:silence=0.0:curve=tri  -ss 0.272         -c:a pcm_f32le _tmp_sub_1.wav 2> /dev/null
#"$FFMPEG" -i $IN_FILE -af afade=t=in:st=0.320:d=0.001:silence=0.0:curve=tri  -ss 0.320         -c:a pcm_f32le _tmp_sub_1.wav 2> /dev/null
"$FFMPEG" -i $IN_FILE -af afade=t=in:st=0.351:d=0.001:silence=0.0:curve=tri  -ss 0.351         -c:a pcm_f32le _tmp_sub_1.wav 2> /dev/null

"$FFMPEG" -i _tmp_sub_0.wav -i _tmp_sub_1.wav -filter_complex concat=n=2:v=0:a=1 -c:a pcm_f32le $OUT_FILE 2> /dev/null

#
# harmV3D#6 ... Mechanical noise present at 1.56 seconds -> Delete from 1.56 seconds onwards.
#

IN_FILE="$SRC_DIR/harmV3D#6.wav"
OUT_FILE="$DEST_DIR/harmV3D#6.wav"

echo "Correct: $IN_FILE -> $OUT_FILE"

rm -f $OUT_FILE

"$FFMPEG" -i $IN_FILE -af afade=t=out:st=0.875:d=0.400:silence=0.0:curve=tri -ss 0.00 -t 1.275 -c:a pcm_f32le $OUT_FILE 2> /dev/null


