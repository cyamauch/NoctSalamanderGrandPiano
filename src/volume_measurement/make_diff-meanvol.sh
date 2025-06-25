#!/bin/sh

if [ "$1" = "" ]; then
    echo "[USAGE]"
    echo "$0 sec"
    echo "$0 0.5"
fi

SEC=$1

PLOT_CMD="plot "

for i in 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 ; do
  OUTPUT="diff-meanvol_sec${SEC}_v${i}.txt"
  paste meanvol-sec${SEC}_v16.txt meanvol-sec${SEC}_v${i}.txt | tr '\t' ' ' | awk '{\
    printf("%s %g\n",$1,$4-($2)); \
   }' > $OUTPUT

  if [ "$i" = "01" ]; then
    PLOT_CMD="${PLOT_CMD} '${OUTPUT}' with linesp title '$i'"
  else
    PLOT_CMD="${PLOT_CMD}, '${OUTPUT}' with linesp title '$i'"
  fi

done

OUTPUT_PLOT="plot_diff-meanvol_sec${SEC}.txt"

echo "set xlabel 'note-id'" > $OUTPUT_PLOT
echo "set ylabel 'gap-volumne (${SEC} sec.)'" >> $OUTPUT_PLOT
echo "set grid" >> $OUTPUT_PLOT
echo "set xtics 10" >> $OUTPUT_PLOT
#echo "set xrange [19:120]" >> $OUTPUT_PLOT

echo $PLOT_CMD >> $OUTPUT_PLOT
