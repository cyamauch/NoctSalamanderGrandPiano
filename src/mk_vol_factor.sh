#!/bin/sh

#
# sh mk_vol_factor.sh  > vol_factor.txt
#

VOL_FACTOR_BASE=`cat vol_factor_base.txt | tr -d '\r'`
VOL_FACTOR_SRC=`cat vol_factor.src.txt | tr -d '\r'`
VOL_FACTOR_EFFECTIVE=`cat vol_factor_effective.txt | tr -d '\r'`

LIST=`echo "$VOL_FACTOR_BASE" | grep '^[ACDF]' | awk '{printf("%s,%s\n",$1,$2);}'`
OFFSET_SRC=`echo "$VOL_FACTOR_BASE" | grep '^OFFSET_SRC' | awk '{printf("%s\n",$2);}'`

#echo $LIST

echo "$VOL_FACTOR_SRC" | grep '^#'
echo "$VOL_FACTOR_BASE" | grep '^OFFSET '

if [ "$VOL_FACTOR_EFFECTIVE" != "" ]; then

  echo "$VOL_FACTOR_EFFECTIVE" | grep '^EFF_RATIO' > _tmp0_.txt
  echo "$VOL_FACTOR_EFFECTIVE" | grep '^[0-1]' | sort >> _tmp0_.txt

  echo "" > _tmp1_.txt
  echo "$VOL_FACTOR_SRC" | grep '^[0-1]' | sort >> _tmp1_.txt

  paste _tmp0_.txt _tmp1_.txt | tr '\t' ' ' | awk '{ if(NR==1){V1=$2; V2=$3; V3=$4; V4=$5; V5=$6; V6=$7; V7=$8; V8=$9; V9=$10; V10=$11; V11=$12; V12=$13; V13=$14; V14=$15; V15=$16; V16=$17;} else { printf("%-7s %+.2f %+.2f %+.2f %+.2f %+.2f %+.2f %+.2f %+.2f %+.2f %+.2f %+.2f %+.2f %+.2f %+.2f %+.2f %+.2f\n",$1,$4+V1*$2,$5+V2*$2,$6+V3*$2,$7+V4*$2,$8+V5*$2,$9+V6*$2,$10+V7*$2,$11+V8*$2,$12+V9*$2,$13+V10*$2,$14+V11*$2,$15+V12*$2,$16+V13*$2,$17+V14*$2,$18+V15*$2,$19+V16*$2); } }' > _tmp2_.txt

else

  echo "$VOL_FACTOR_SRC" | grep '^[0-1]' | sort > _tmp2_.txt

fi


echo "$VOL_FACTOR_BASE" | grep '^[0-1]' | awk '{printf("%s %g\n",$1,'$OFFSET_SRC'+$2);}' | sort > _tmp0_.txt

echo "$VOL_FACTOR_SRC" | grep '^VEL' > _tmp3_.txt 

paste _tmp0_.txt _tmp2_.txt | tr '\t' ' ' | awk '{printf("%-7s %+.2f %+.2f %+.2f %+.2f %+.2f %+.2f %+.2f %+.2f %+.2f %+.2f %+.2f %+.2f %+.2f %+.2f %+.2f %+.2f\n",$3,$4+$2,$5+$2,$6+$2,$7+$2,$8+$2,$9+$2,$10+$2,$11+$2,$12+$2,$13+$2,$14+$2,$15+$2,$16+$2,$17+$2,$18+$2,$19+$2);}' >> _tmp3_.txt

cat _tmp3_.txt | awk '{ if(NR==1){V1=$2; V2=$3; V3=$4; V4=$5; V5=$6; V6=$7; V7=$8; V8=$9; V9=$10; V10=$11; V11=$12; V12=$13; V13=$14; V14=$15; V15=$16; V16=$17;} else { printf("%-7s %+.2f %+.2f %+.2f %+.2f %+.2f %+.2f %+.2f %+.2f %+.2f %+.2f %+.2f %+.2f %+.2f %+.2f %+.2f %+.2f\n",$1,V1+$2,V2+$3,V3+$4,V4+$5,V5+$6,V6+$7,V7+$8,V8+$9,V9+$10,V10+$11,V11+$12,V12+$13,V13+$14,V14+$15,V15+$16,V16+$17); } }'

