#!/bin/sh

L=12
FILES=""


for i in 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 ; do

  if [ $i = "01" ]; then
    DB_VAL="+1.5x${L}+9.0 dB"
  elif [ $i = "02" ]; then
    DB_VAL="+1.5x${L}+5.0 dB"
  elif [ $i = "03" ]; then
    DB_VAL="+1.5x${L}+2.0 dB"
  else
    DB_VAL="+1.5x${L}        dB"
    L=`echo $L | awk '{printf("%02d\n",$1-1);}'`
  fi

  convert -pointsize 24 -annotate +1320+186 "Layer : $i" -pointsize 20 -annotate +1288+300 "$DB_VAL" -pointsize 16 -annotate +144+306 "A0" -annotate +1386+270 "C8"  noct40_v${i}.png tmp.png
  convert -fill '#f7f9ff' -draw 'rectangle 102,280 112,290' -crop 1335x150+103+160 +repage tmp.png tmp1.png
  convert -negate tmp1.png noct40_v${i}_crop.png

  FILES="$FILES noct40_v${i}_crop.png"

done


convert -layers optimize -delay 50 -loop 0 $FILES noct40_v01-16.gif



