#!/bin/sh

#     v1       v4          v8          v12            v16
LIST="13 30 35 40 45 48 53 60 68 76 84 92 100 108 116 124"

TEMPO=50000
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
  echo $i | awk '{ t=100; for (i=21; i<109; i++){printf("%d On ch=1 n=%d v=%s\n",t,i,$1); t+=1000; printf("%d On ch=1 n=%d v=0\n",t,i); } t+=4000; for (i=109; 21<i; ){ i--;  printf("%d On ch=1 n=%d v=%s\n",t,i,$1); t+=1000; printf("%d On ch=1 n=%d v=0\n",t,i); } }' >> tmp.txt

  echo "TrkEnd" >> tmp.txt

  VV=`echo $i | awk '{printf("%03d\n",$1);}'`
  NN=`echo $N | awk '{printf("%02d\n",$1);}'`

  ./t2mf.exe tmp.txt > scale_v${NN}-v${VV}.mid

  N=`expr $N + 1`

  #rm tmp.txt

done


