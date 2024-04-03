#!/bin/sh	

if [ "$3" = "" ]; then
  echo "[USAGE]"
  echo "$0 tempo start end"
  echo "$0 55000 21 108 (ALL)"
  echo "$0 55000 24 48 (C1 to C3)"
  echo "$0 55000 36 60 (C2 to C4)"
  echo "$0 55000 48 72 (C3 to C5)"
  echo "$0 55000 60 84 (C4 to C6)"
  echo "$0 55000 72 96 (C5 to C7)"
  echo "$0 55000 84 108 (C6 to C8)"
  exit
fi

TEMPO=$1
KEY_S=$2
KEY_E=$3


#     v1       v4          v8          v12            v16
LIST="13 29 35 40 44 49 54 61 68 76 84 92 100 108 116 124"

#TEMPO=55000
#TEMPO=100000

N=1

for i in $LIST ; do

  echo "Generating: $i"

  echo "MFile 1 2 240" > tmp.txt
  echo "MTrk" >> tmp.txt
  echo "0 Tempo ${TEMPO}" >> tmp.txt
  echo "TrkEnd" >> tmp.txt
  echo "MTrk" >> tmp.txt
  echo "0 SysEx f0 41 10 42 12 40 00 7f 00 41 f7" >> tmp.txt

  # key: 21 to 108
  echo $i $KEY_S $KEY_E | awk '{ t=100; for (i=$2; i<1+$3; i++){printf("%d On ch=1 n=%d v=%s\n",t,i,$1); t+=1000; printf("%d On ch=1 n=%d v=0\n",t,i); } t+=4000; for (i=1+$3; $2<i; ){ i--;  printf("%d On ch=1 n=%d v=%s\n",t,i,$1); t+=1000; printf("%d On ch=1 n=%d v=0\n",t,i); } }' >> tmp.txt

  echo "TrkEnd" >> tmp.txt

  VV=`echo $i | awk '{printf("%03d\n",$1);}'`
  NN=`echo $N | awk '{printf("%02d\n",$1);}'`

  t2mf tmp.txt > scale_v${NN}-v${VV}.mid

  N=`expr $N + 1`

  #rm tmp.txt

done


