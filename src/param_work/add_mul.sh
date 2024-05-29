
#!/bin/sh


ARG_TXT_0=`cat $1 | tr -d '\r' | sed -e 's/^[ ]*//'`
ARG_TXT_1=`cat $2 | tr -d '\r' | sed -e 's/^[ ]*//'`

echo "$ARG_TXT_0" | grep '^[0-1][0-9][0-9]' | sort > _tmp0_.txt
echo "$ARG_TXT_1" | awk '{ \
  if ( NR==1 ) { \
    VEL_ALL[1] = ""; \
  } \
  p0 = match($1, /^VEL_ALL/); \
  if ( 0 < p0 ) { \
    split($0,VEL_ALL," "); \
  } \
  p0 = match($1, /^[0-1][0-9][0-9]_[A-Z]/); \
  if ( 0 < p0 ) { \
    split($0,ARR," "); \
    if ( ARR[3] == "" ) { \
      for ( i=2 ; i <= 16 ; i++ ) { \
        ARR[1+i] = ARR[1+1]; \
      } \
    } \
    if ( VEL_ALL[1] != "" ) { \
      for ( i=1 ; i <= 16 ; i++ ) { \
        ARR[1+i] = VEL_ALL[1+i] + ARR[1+i]; \
      } \
    } \
    printf("%s",$1); \
    for ( i=1 ; i <= 16 ; i++ ) { \
      printf(" %.2f",ARR[1+i]); \
    } \
    printf("\n"); \
  } \
}' | sort > _tmp1_.txt

paste _tmp0_.txt _tmp1_.txt | tr '\t' ' ' | awk '{ \
  split($0,ARR," "); \
  printf("%-7s",ARR[1]); \
  for (i=0 ; i<16 ; i++) { \
    printf(" %+.2f",ARR[2+i]+ARR[19+i]); \
  } \
  printf("\n"); \
}'

