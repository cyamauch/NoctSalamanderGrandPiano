#!/bin/sh

#
# sh mk_vol_factor.sh  > vol_factor.txt
#

LIST=`cat vol_factor_base.txt | grep '^[A-Z]' | awk '{printf("%s,%s\n",$1,$2);}'`

echo $LIST

cat vol_factor.src.txt | grep '^#'

for i in $LIST ; do
  #echo $i
  KEY=`echo $i | sed -e 's/[,][^,].*//'`
  VOL=`echo $i | sed -e 's/[^,][^,].[,]*//'`
  #echo $KEY
  #echo $VOL
  VOL16=`cat vol_factor.src.txt | grep "^$KEY"`
  echo $VOL $VOL16 | awk '{printf("%-3s %+.1f %+.1f %+.1f %+.1f %+.1f %+.1f %+.1f %+.1f %+.1f %+.1f %+.1f %+.1f %+.1f %+.1f %+.1f %+.1f\n",$2,$3+$1,$4+$1,$5+$1,$6+$1,$7+$1,$8+$1,$9+$1,$10+$1,$11+$1,$12+$1,$13+$1,$14+$1,$15+$1,$16+$1,$17+$1,$18+$1);}'
done


