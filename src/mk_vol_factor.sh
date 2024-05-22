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

  echo "$VOL_FACTOR_EFFECTIVE" | grep '^[0-1]' | sort > _tmp0_.txt

  echo "$VOL_FACTOR_SRC" | grep '^[0-1]' | sort > _tmp1_.txt

  paste _tmp1_.txt _tmp0_.txt | tr '\t' ' ' | awk '{ \
    printf("%s ",$1); \
    split($0,ARR," "); \
    for ( i=1 ; i <= 16 ; i++ ) { \
      printf("%+.2f ",ARR[1+i] + ARR[18+i]); \
    } \
    printf("\n"); \
  }' > _tmp2_.txt

else

  echo "$VOL_FACTOR_SRC" | grep '^[0-1]' | sort > _tmp2_.txt

fi

echo "$VOL_FACTOR_BASE" | grep '^[0-1]' | awk '{printf("%s %g\n",$1,'$OFFSET_SRC'+$2);}' | sort > _tmp0_.txt

VEL_LINE=`echo "$VOL_FACTOR_SRC" | grep '^VEL'`
if [ "$VEL_LINE" != "" ]; then
  echo "$VEL_LINE" > _tmp3_.txt 
else
  echo "VEL_ALL  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0" > _tmp3_.txt 
fi


paste _tmp0_.txt _tmp2_.txt | tr '\t' ' ' | awk '{ \
  split($0,ARR," "); \
  printf("%-7s", ARR[3]); \
  for ( i=1 ; i <= 16 ; i++ ) { \
    printf(" %+.2f",ARR[3+i] + ARR[2]); \
  } \
  printf("\n"); \
}' >> _tmp3_.txt


cat _tmp3_.txt | awk '{ \
  if ( NR==1 ){ \
    split($0,V_ALL_ARR," "); \
  } \
  else { \
    split($0,V_ARR," "); \
    printf("%-7s",$1); \
    for ( i=1 ; i <= 16 ; i++ ) { \
      printf(" %+.2f",V_ALL_ARR[1+i] + V_ARR[1+i]); \
    } \
    printf("\n"); \
  } \
}'



