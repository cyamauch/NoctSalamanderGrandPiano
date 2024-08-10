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

if [ "$2" == "" ]; then
  echo "[USAGE]"
  echo "$0 1 filename.mid"
  echo "$0 ch filename.mid"
  exit
fi

CH_ID=$1

########
while [ "$2" != "" ]; do
IN_NAME=$2
########



$MF2T $IN_NAME | tr -d "\r" > _tmp_input.txt

OUTBASENAME=`echo $IN_NAME | sed -e 's/[.][^.][^.]*$//'`
OUTSUFFIX=`echo $IN_NAME | sed -e 's/^.*[.]//'`

OUTNAME=${OUTBASENAME}_withoutCC64.${OUTSUFFIX}

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

#
# CCSTAT  ... CC64 Pedal On/Off info
# CCFLG[] ... Flags for hold/key ON/OFF info
#              0 ... OFF
#              1 ... key ON
#             10 ... hold ON
#             11 ... hold and key ON
#
cat $IN_TMP | awk '{ \
  if ( NR == 1 ) { CCSTAT=0; for (i=1 ; i<128 ; i++){ CCFLG[i]=0; } } \
  if ( substr($3,1,3) == "ch=" && substr($3,4) == "'$CH_ID'" && substr($5,1,2) == "v=" ) { \
    VVAL = int(substr($5,3)); \
    if ( substr($4,1,2) == "n=" ) { \
      NVAL = int(substr($4,3)); \
      if ( VVAL == 0 || $2 == "Off" ) { \
        if ( CCSTAT == 0 ) { \
          printf("%s On %s %s v=0\n",$1,$3,$4); \
          CCFLG[NVAL] = 0; \
        } \
        else { \
          if ( CCFLG[NVAL] % 10 == 1 ) { CCFLG[NVAL] -= 1; }; \
        } \
      } \
      else if ( $2 == "On" ) { \
        if ( 0 < CCFLG[NVAL] ) { \
          printf("%d On %s %s v=0\n",int($1) - 1,$3,$4); \
        } \
        printf("%s On %s %s %s\n",$1,$3,$4,$5); \
        CCFLG[NVAL] = 1; \
        if ( CCSTAT != 0 ) { CCFLG[NVAL] += 10; };
      } \
      else { \
        print; \
      } \
    } \
    else if ( $4 == "c=64" ) { \
      if ( 63 < VVAL ) { \
        CCSTAT = 1; \
        for (i=1 ; i<128 ; i++){ \
          if ( CCFLG[i] == 1 ) { \
            CCFLG[i] += 10; \
          } \
        } \
      } \
      else { \
        CCSTAT = 0; \
        for (i=1 ; i<128 ; i++){ \
          if ( CCFLG[i] == 10 ) { \
            printf("%s On %s n=%d v=0\n",$1,$3,i); \
            CCFLG[i] = 0; \
          } \
        } \
      } \
    } \
    else { \
      print; \
    } \
  } \
  else { \
    if ( $1 != "0" ) {print;} \
  } \
}' | sort -n >> _tmp_output.txt

  echo "TrkEnd" >> _tmp_output.txt

done

echo "output to $OUTNAME"
$T2MF _tmp_output.txt > $OUTNAME



########
shift
done
########

