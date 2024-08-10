#!/bin/sh

#
# $1...filename  $2...track No.
#
func_output_main ()
{
  cat $1 | awk '{ \
    if ( $0 == "MTrk" ) { TRK++; } \
    else { \
      if ( $0 == "TrkEnd" ) { TEND++; } \
      else { \
        if (TRK == '$2') { print; } \
      } \
    } \
  }'
}

MF2T="mf2t"
T2MF="t2mf"

if [ "$6" == "" ]; then
  echo "[USAGE]"
  echo "$0 80 10 10 80 1.0 filename.mid"
  echo "$0 80 10 0 100 1.0 filename.mid"
  echo "$0 0  0  10 80 1.0 filename.mid"
  echo "$0 pedal_on pedal_off vel_offset vel_scale power filename.mid"
  exit
fi

ADJ_PEDAL_ON=$1
ADJ_PEDAL_OFF=$2
ADJ_VEL_OFF=$3
ADJ_VEL_SCALE=$4
ADJ_VEL_POWER=`echo $5 | awk '{printf("%g\n",$1);}'`
INNAME=$6


echo "Adjusted Pedal Timing to -"$ADJ_PEDAL_ON" -"$ADJ_PEDAL_OFF
echo "         Velocity offset="$ADJ_VEL_OFF" scale="$ADJ_VEL_SCALE" power="$ADJ_VEL_POWER

$MF2T $INNAME | tr -d "\r" > _tmp_input.txt

OUTBASENAME=`echo $INNAME | sed -e 's/[.][^.][^.]*$//'`
OUTSUFFIX=`echo $INNAME | sed -e 's/^.*[.]//'`

if [ "$ADJ_VEL_OFF" = "0" -a "$ADJ_VEL_SCALE" = "100" -a "$ADJ_VEL_POWER" = "1" ]; then
  OUTNAME=${OUTBASENAME}_pdl${ADJ_PEDAL_ON}.${ADJ_PEDAL_OFF}.${OUTSUFFIX}
else
  if [ "$ADJ_PEDAL_ON" = "0" -a "$ADJ_PEDAL_OFF" = "0" ]; then
    OUTNAME=${OUTBASENAME}_vel${ADJ_VEL_OFF}.${ADJ_VEL_SCALE}.${ADJ_VEL_POWER}.${OUTSUFFIX}
  else
    OUTNAME=${OUTBASENAME}_pdl${ADJ_PEDAL_ON}.${ADJ_PEDAL_OFF}_vel${ADJ_VEL_OFF}.${ADJ_VEL_SCALE}.${ADJ_VEL_POWER}.${OUTSUFFIX}
  fi
fi

cat _tmp_input.txt | head -1 > _tmp_output.txt

TRK=0
CNT_TRK=0
while [ 1 ]; do

  TRK=`expr $TRK + 1`

  func_output_main _tmp_input.txt ${TRK} > _tmp_${TRK}.txt

  N=`cat _tmp_${TRK}.txt | wc -l`
  if [ $N = 0 ]; then
    break
  else
    CNT_TRK=$TRK
  fi

  echo "PHASE1 -- TRK: $TRK"

done


TRK=0
while [ 1 ]; do

  if [ $TRK = $CNT_TRK ]; then
    break
  fi

  TRK=`expr $TRK + 1`

  echo "PHASE2 -- TRK: $TRK"

  IN_TMP=_tmp_${TRK}.txt

  echo "MTrk" >> _tmp_output.txt

  cat $IN_TMP | awk '{if ($1=="0") {print;} }' >> _tmp_output.txt

cat $IN_TMP | awk '{if ($1!="0") {print;} }' | grep '^[0-9]' | awk '{ \
  if ($2=="Par" && $3=="ch=1" && $4=="c=64") { \
    if ($5=="v=0") { \
      if ( '$ADJ_PEDAL_OFF' < $1 ) { \
        POFF=$1 - '$ADJ_PEDAL_OFF'; \
      } \
      else { \
        POFF=$1; \
      } \
      printf("%d %s %s %s %s\n",POFF,$2,$3,$4,$5); \
    } \
    else { \
      if ($5=="v=127") { \
        if (POFF + '$ADJ_PEDAL_ON' < $1){ \
          printf("%d %s %s %s %s\n",$1 - '$ADJ_PEDAL_ON',$2,$3,$4,$5); \
        } else { \
          printf("%d %s %s %s %s\n",POFF + 1,$2,$3,$4,$5); \
        } \
      } \
      else { \
        print; \
      } \
    } \
  } \
  else { \
    if ($2=="On" && $5!="v=0") { \
      VEL=substr($5,3); \
      if ( '$ADJ_VEL_POWER' == 1 ) { \
        VEL_NEW='$ADJ_VEL_OFF' + int(VEL * '$ADJ_VEL_SCALE' * 0.01 + 0.5); \
      } else { \
        P_VEL=127.0 * ( (VEL/127.0) ^ '$ADJ_VEL_POWER' ); \
        VEL_NEW='$ADJ_VEL_OFF' + int(P_VEL * '$ADJ_VEL_SCALE' * 0.01 + 0.5); \
      } \
      if ( 127 < VEL_NEW ) { VEL_NEW=127; } \
      if ( VEL_NEW < 0 ) { VEL_NEW=0; } \
      printf("%d %s %s %s v=%d\n",$1,$2,$3,$4,VEL_NEW); \
    } \
    else { \
      print; \
    } \
  } \
}' | sort -n >> _tmp_output.txt

  echo "TrkEnd" >> _tmp_output.txt

done

echo "output to $OUTNAME"
$T2MF _tmp_output.txt > $OUTNAME

