#!/bin/sh

#
# sh mk_vol_factor.sh  > vol_factor.txt
#

VOL_FACTOR_BASE=`cat vol_factor_base.txt | tr -d '\r'`
VOL_FACTOR_SRC=`cat vol_factor.src.txt | tr -d '\r'`

LIST=`echo "$VOL_FACTOR_BASE" | grep '^[ACDF]' | awk '{printf("%s,%s\n",$1,$2);}'`
OFFSET_SRC=`echo "$VOL_FACTOR_BASE" | grep '^OFFSET_SRC' | awk '{printf("%s\n",$2);}'`

#echo $LIST

echo "$VOL_FACTOR_SRC" | grep '^#'
echo "$VOL_FACTOR_BASE" | grep '^OFFSET '

echo "$VOL_FACTOR_BASE" | grep '^[0-1]' | awk '{printf("%s %g\n",$1,'$OFFSET_SRC'+$2);}' | sort > _tmp0_.txt
echo "$VOL_FACTOR_SRC" | grep '^[0-1]' | sort > _tmp1_.txt

echo "$VOL_FACTOR_SRC" | grep '^VEL' > _tmp2_.txt 

paste _tmp0_.txt _tmp1_.txt | tr '\t' ' ' | awk '{printf("%-7s %+.1f %+.1f %+.1f %+.1f %+.1f %+.1f %+.1f %+.1f %+.1f %+.1f %+.1f %+.1f %+.1f %+.1f %+.1f %+.1f\n",$3,$4+$2,$5+$2,$6+$2,$7+$2,$8+$2,$9+$2,$10+$2,$11+$2,$12+$2,$13+$2,$14+$2,$15+$2,$16+$2,$17+$2,$18+$2,$19+$2);}' >> _tmp2_.txt

cat _tmp2_.txt | awk '{ if(NR==1){V1=$2; V2=$3; V3=$4; V4=$5; V5=$6; V6=$7; V7=$8; V8=$9; V9=$10; V10=$11; V11=$12; V12=$13; V13=$14; V14=$15; V15=$16; V16=$17;} else { printf("%-7s %+.1f %+.1f %+.1f %+.1f %+.1f %+.1f %+.1f %+.1f %+.1f %+.1f %+.1f %+.1f %+.1f %+.1f %+.1f %+.1f\n",$1,V1+$2,V2+$3,V3+$4,V4+$5,V5+$6,V6+$7,V7+$8,V8+$9,V9+$10,V10+$11,V11+$12,V12+$13,V13+$14,V14+$15,V15+$16,V16+$17); } }'

