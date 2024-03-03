#!/bin/sh


ARG_TXT_0=`cat $1 | tr -d '\r'`
ARG_TXT_1=`cat $2 | tr -d '\r'`

echo "$ARG_TXT_0" | grep '^[0-1]' | sort > _tmp0_.txt
echo "$ARG_TXT_1" | grep '^[0-1]' | sort > _tmp1_.txt

paste _tmp0_.txt _tmp1_.txt | tr '\t' ' ' | awk '{ split($0,ARR," "); printf("%-7s ",ARR[1]); for (i=0 ; i<16 ; i++) { printf("%+.1f ",ARR[2+i]-ARR[19+i]); } printf("\n"); }'

