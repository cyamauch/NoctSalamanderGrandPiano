#!/bin/sh

#
# sh mk_vol_factor.sh vol_factor.src.src.VERSION.txt > vol_factor.src4build.txt
#

if [ "$1" = "" ]; then
  echo "[USAGE]"
  echo "sh mk_vol_factor.sh vol_factor.src.src.VERSION.txt > vol_factor.src4build.txt"
  exit
fi

VOL_FACTOR_BASE=`cat vol_factor_base.txt | tr -d '\r' | sed -e 's/^[ ]*//'`
VOL_FACTOR_SRC=`cat $1 | tr -d '\r' | sed -e 's/^[ ]*//'`
VOL_FACTOR_EFFECTIVE=`cat vol_factor_effective.txt | tr -d '\r' | sed -e 's/^[ ]*//'`

LIST=`echo "$VOL_FACTOR_BASE" | grep '^[ACDF]' | awk '{printf("%s,%s\n",$1,$2);}'`
OFFSET_SRC=`echo "$VOL_FACTOR_BASE" | grep '^OFFSET_SRC' | awk '{printf("%s\n",$2);}'`


echo "#Key Volume(db)"
echo "#         v1   v2   v3   v4   v5   v6   v7   v8   v9  v10  v11  v12  v13  v14  v15  v16"
echo ""
echo "VEL_ALL  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0"
echo ""


if [ "$VOL_FACTOR_EFFECTIVE" != "" ]; then

  echo "$VOL_FACTOR_EFFECTIVE" | grep '^EFF_RATIO' > _tmp0_.txt
  echo "$VOL_FACTOR_EFFECTIVE" | grep '^[0-1][0-9][0-9]' | sort >> _tmp0_.txt

  echo "" > _tmp1_.txt
  echo "$VOL_FACTOR_SRC" | grep '^[0-1][0-9][0-9]' | sort >> _tmp1_.txt

  paste _tmp0_.txt _tmp1_.txt | tr '\t' ' ' | awk '{ \
    if ( NR==1 ) { \
      split($0,EFF_RATIO," "); \
    } \
    else { \
      split($0,ARR," "); \
      printf("%s",$1); \
      for ( i=1 ; i <= 16 ; i++ ) { \
        printf(" %+.2f",ARR[3+i] + EFF_RATIO[1+i] * ARR[1+1]); \
      } \
      printf("\n"); \
    } \
  }' > _tmp2_.txt


else

  echo "$VOL_FACTOR_SRC" | grep '^[0-1][0-9][0-9]' | sort > _tmp2_.txt

fi


echo "$VOL_FACTOR_BASE" | grep '^[0-1][0-9][0-9]' | awk '{printf("%s %g\n",$1,'$OFFSET_SRC'+$2);}' | sort > _tmp0_.txt

VEL_LINE=`echo "$VOL_FACTOR_SRC" | grep '^VEL'`
if [ "$VEL_LINE" != "" ]; then
  echo "$VEL_LINE" > _tmp3_.txt 
else
  echo "VEL_ALL  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0" > _tmp3_.txt 
fi


paste _tmp0_.txt _tmp2_.txt | tr '\t' ' ' | awk '{ \
  split($0,ARR," "); \
  printf("%s",$3); \
  for ( i=1 ; i <= 16 ; i++ ) { \
    printf(" %+.2f",ARR[3+i] + ARR[1+1]); \
  } \
  printf("\n"); \
}' >> _tmp3_.txt

cat _tmp3_.txt | awk '{ \
  if ( NR==1 ) { \
    split($0,VEL_ALL," "); \
  } \
  else { \
    split($0,ARR," "); \
    printf("%-7s",$1); \
    for ( i=1 ; i <= 16 ; i++ ) { \
      printf(" %+.2f",VEL_ALL[1+i] + ARR[1+i]); \
    } \
    printf("\n"); \
  } \
}'

