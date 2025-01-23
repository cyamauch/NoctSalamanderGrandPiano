#!/bin/sh

##########################
####   Creating SFZ   ####
##########################

if [ "$1" != "-" ]; then
  SFZ_SED_ARGS_FILE="$1"
else
  SFZ_SED_ARGS_FILE="sfz_sed_args.txt"
fi
SRC_SFZ="$2"
DEST_DIR="$3"
DEST_SFZ_BASENAME="$4"
SFZ_VOL_FACTOR_BASE_FILE="$5"
SFZ_SUFFIX="$6"
if [ "$7" != "" ]; then
  SFZ_RECOMMENDED_SUFFIX=".$7"
else
  SFZ_RECOMMENDED_SUFFIX=""
fi

# Preprocessing SFZ

# Version 5
sh prep_sfz.sh ${SRC_SFZ} > prep.sfz

# Version 6
#sh prep_sfz.sh ${SRC_SFZ} volumne_measurement/unsampled_volumes.txt > prep.sfz

if [ "$4" != "" ]; then

  SFZ_SED_ARGS=`cat $SFZ_SED_ARGS_FILE | tr -d '\r'`

  SFZ_VOL_FACTOR_BASE=`cat $SFZ_VOL_FACTOR_BASE_FILE | tr -d '\r' | sed -e 's/^[ ]*//'`

  echo "$SFZ_VOL_FACTOR_BASE" | grep '^AMP_VEL' | sed -e 's/[^ ][^ ]*[ ][ ]*//' > tmp.sfz
  echo "$SFZ_VOL_FACTOR_BASE" | grep '^VEL_ALL' | sed -e 's/[^ ][^ ]*[ ][ ]*//' >> tmp.sfz
  echo "$SFZ_VOL_FACTOR_BASE" | grep '^[0-1][0-9][0-9][_][A-Z]' | awk '{printf("%s ",substr($1,1,3));}' >> tmp.sfz
  echo >> tmp.sfz
  echo "$SFZ_VOL_FACTOR_BASE" | grep '^[0-1][0-9][0-9][_][A-Z]' | awk '{printf("%s ",$2);}' >> tmp.sfz
  echo >> tmp.sfz
  # Using '~' is for MinGW shell
  cat prep.sfz | tr -d '\r' | tr ' ' '~' | sed $SFZ_SED_ARGS | tr '~' ' ' >> tmp.sfz

  cat tmp.sfz | awk '{ \
    if ( NR==1 ) { AMP_VEL=$1; if ( AMP_VEL == "" ){ AMP_VEL=73; } } \
    else if ( NR==2 ) { split($0,VOL_VEL," "); } \
    else if ( NR==3 ) { split($0,KEYS," "); } \
    else if ( NR==4 ) { split($0,VOL_KEY," "); } \
    else { \
      volume = 0.0; \
      p0 = match($0, /[0-1][0-9][0-9]_[A-Z]/); \
      p1 = 0; \
      p_amp = 0; \
      if ( 0 < p0 ) { \
        p1 = match($0, /v[0-9][0-9][.]wav/); \
        if ( 0 < p1 ) { \
          key = substr($0,p0,3); \
          for ( i=1 ; i <= length(KEYS) ; i++ ) { \
            if ( key == KEYS[i] ) { \
              v = int(substr($0,p1+1,2)); \
              volume = 0.0 + VOL_VEL[v] + VOL_KEY[i]; \
            } \
          } \
        } \
      } \
      else { \
        p_amp = match($0, /amp_veltrack=73/); \
        if ( p_amp < 1 ) { \
          p_amp = match($0, /amp_veltrack=82/); \
        }
      } \
      if ( 0 < p0 && 0 < p1 && volume != 0.0 ) { \
        p_v=match($0, /volume[=][0123456789.+-]*/); \
        if ( 0 < p_v ) { \
          vol_org = substr($0,p_v+7,RLENGTH-7); \
          vol_str = sprintf("volume=%+.2f",vol_org + volume); \
          sub(/volume=[^ ][^ ]*/,vol_str,$0); \
        } \
        else { \
          vol_str = sprintf("volume=%+.2f",volume); \
          sub(/[.]wav[ ]/, ".wav " vol_str " ", $0); \
        } \
        print $0; \
      } \
      else if ( 0 < p_amp ) { \
        gsub(/amp_veltrack=[0-9][0-9]*/, "amp_veltrack=" AMP_VEL, $0); print $0; \
      } \
      else { \
        print $0; \
      } \
    } \
  }' > tmp_out.sfz
  #cat tmp_out.sfz | awk '{ printf("%s~\n",$0); }' | tr '~' '\r' > ${DEST_DIR}/../${DEST_SFZ_BASENAME}${SFZ_SUFFIX}.sfz
  cat tmp_out.sfz | awk '{ printf("%s~\n",$0); }' | tr '~' '\r' > ${DEST_DIR}/../${DEST_SFZ_BASENAME}${SFZ_SUFFIX}${SFZ_RECOMMENDED_SUFFIX}.sfz

  #cat tmp_out.sfz | awk '{ \
  #  if ( substr($0,1,13) == "//HammerNoise" ) { FLG=1; } \
  #  if ( FLG == 1 ) { FLG=1; } \
  #  else { print; } \
  #}' | awk '{ printf("%s~\n",$0); }' | tr '~' '\r' > ${DEST_DIR}/../${DEST_SFZ_BASENAME}${SFZ_SUFFIX}_withoutNoise${SFZ_RECOMMENDED_SUFFIX}.sfz

fi


