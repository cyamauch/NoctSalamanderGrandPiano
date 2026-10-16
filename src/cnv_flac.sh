#!/bin/sh

####

SRC="$1"
DEST="$2"

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

####

mkdir -p "$DEST"

echo cp -p $SRC/README.txt $DEST/.
cp -p $SRC/README.txt $DEST/.
echo cp -pR $SRC/src $DEST/.
cp -pR $SRC/src $DEST/.

for i in $SRC/sfz_* ; do
  OBJ0=`echo $i | sed -e 's/^[.]*[/]//' -e 's/^[^/]*[/]//'`
  echo mkdir -p $DEST/$OBJ0
  mkdir -p $DEST/$OBJ0
  for j in $i/*.sfz ; do
    OBJ1=`echo $j | sed -e 's/^[.]*[/]//' -e 's/^[^/]*[/]//'`
    echo "$j -> $DEST/$OBJ1"
    cat $j | sed -e 's/[.]wav[ ]/.flac /' > $DEST/$OBJ1
  done
done

for i in $SRC/*bit ; do
  OBJ0=`echo $i | sed -e 's/^[.]*[/]//' -e 's/^[^/]*[/]//'`
  echo mkdir -p $DEST/$OBJ0
  mkdir -p $DEST/$OBJ0
  for j in $i/*.wav ; do
    OBJ1=`echo $j | sed -e 's/^[.]*[/]//' -e 's/^[^/]*[/]//'`
    echo "$j -> $DEST/${OBJ1%.wav}.flac"
    rm -f $DEST/${OBJ1%.wav}.flac
    "$FFMPEG" -i $j $DEST/${OBJ1%.wav}.flac 2> /dev/null
  done
done

