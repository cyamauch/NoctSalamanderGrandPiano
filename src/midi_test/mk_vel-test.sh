#!/bin/sh	

if [ "$1" = "" ]; then
  echo "[USAGE]"
  echo "$0 tempo mark_flag"
  echo "$0 50000 1"
  exit
fi

TEMPO=$1
if [ "$2" = "1" ]; then
  MARK_FLAG=1
else
  MARK_FLAG=0
fi

KEY_ID=`cat ../key_n-id.txt | awk '{printf("%s,%s\n",$1,$2);}'`

#V4.0
#LIST_RAW="26 27 30  34 35 35  36 37 40  43 44 45  46 47 48  50 51 53  56 57 60  64 65 68  72 73 76  80 81 84  88 89 92  96 97 100  104 105 108  112 113 116  120 121 124"

#V4.1
LIST_RAW="26 27 30  33 34 35  37 38 40  43 44 45  47 48 50  52 53 55  58 59 61  64 65 68  72 73 76  80 81 84  88 89 92  96 97 100  104 105 108  112 113 116  120 121 124"


LIST=`echo $LIST_RAW | awk '{ \
  split($0,ARR," "); \
  for ( i=length(ARR) ; 0 < i ; i-- ) { \
    printf("%s ",ARR[i]); \
  } \
  printf("\n"); \
}'`

for i in $KEY_ID ; do

  ID=`echo $i | sed -e 's/^[^ ]*[,]//'`
  KEY=`echo $i | sed -e 's/[,][^ ]*//'`

  echo "Generating NOTE-ID: $ID"

  echo "MFile 1 2 240" > tmp.txt
  echo "MTrk" >> tmp.txt
  echo "0 Tempo ${TEMPO}" >> tmp.txt
  echo "TrkEnd" >> tmp.txt
  echo "MTrk" >> tmp.txt
  echo "0 SysEx f0 41 10 42 12 40 00 7f 00 41 f7" >> tmp.txt

echo $ID $LIST | awk '{ \
  split($0,ARR," "); \
  t=100; \
  for ( i=2 ; ARR[i] != "" ; i+=3 ){ \
    printf("%d On ch=1 n=%d v=%s\n",t,$1,ARR[i]); \
    t+=500; \
    printf("%d On ch=1 n=%d v=0\n",t,$1); \
    t+=1500; \
    printf("%d On ch=1 n=%d v=%s\n",t,$1,ARR[i+1]); \
    t+=500; \
    printf("%d On ch=1 n=%d v=0\n",t,$1); \
    t+=1500; \
    printf("%d On ch=1 n=%d v=%s\n",t,$1,ARR[i+2]); \
    t+=500; \
    printf("%d On ch=1 n=%d v=0\n",t,$1); \
    t+=1500; \
    if ( '$MARK_FLAG' ){ t+=1000; } \
  } \
}' >> tmp.txt

  echo "TrkEnd" >> tmp.txt

  N_ID=`echo $ID | awk '{printf("%03d\n",$1);}'`

  t2mf tmp.txt > vel_test_${N_ID}-${KEY}.mid

  #rm tmp.txt

done


