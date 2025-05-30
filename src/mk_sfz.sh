#!/bin/sh

##########################
####   Creating SFZ   ####
##########################

# Version 5
VERSION5=1
# Version 6
#VERSION5=0

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

#
# Preprocessing SFZ
#

if [ "$VERSION5" = "1" ]; then
  # Version 5
  sh prep_sfz.sh ${SRC_SFZ} > prep.sfz
else
  # Version 6 : Volume settings will be added for all 88 keys.
  sh prep_sfz.sh ${SRC_SFZ} volume_measurement/unsampled_volumes.txt > prep.sfz
fi

#
# Main Processing
#

if [ "$5" != "" ]; then

  SFZ_SED_ARGS=`cat $SFZ_SED_ARGS_FILE | tr -d '\r'`

  SFZ_VOL_FACTOR_BASE=`cat $SFZ_VOL_FACTOR_BASE_FILE | tr -d '\r' | sed -e 's/^[ ]*//'`

  if [ "$VERSION5" = "1" ]; then
    # Version 5
    echo "5" > tmp.sfz
  else
    # Version 6
    echo "6" > tmp.sfz
  fi

  # Create an 88 note setting by linearly interpolating a 30 note setting (A0,C1,...C8).
  echo "$SFZ_VOL_FACTOR_BASE" | awk '{ \
    if ( NR==1 ) { \
      ix_k=1; ix_v=1; \
    } \
    if ( $1 == "AMP_VELTRACK" ) { \
      PRM_L2 = $2;
    } \
    else if ( $1 == "AMPEG_RELEASE" ) { \
      PRM_L3 = $2;
    } \
    else if ( $1 == "VEL_ALL" ) { \
      split($0,ARR," "); \
      PRM_L4 = ""; \
      for ( i=2 ; i <= length(ARR) ; i++ ) { \
        if ( i != 2 ) { PRM_L4 = PRM_L4 " "; } \
        PRM_L4 = PRM_L4 ARR[i]; \
      } \
    } \
    else if ( substr($1,1,1) != "#" ) { \
      p0 = match($0, /[0-1][0-9][0-9]_[A-Z]/); \
      if ( 0 < p0 ) { \
        KEY = sprintf("%d",substr($1,1,3)); \
        if ( PREV_KEY != "" ) { \
          OUT_KEYS[ix_k] = sprintf("%03d",PREV_KEY + 1 * (KEY - PREV_KEY) / 3); ix_k++; \
          OUT_KEYS[ix_k] = sprintf("%03d",PREV_KEY + 2 * (KEY - PREV_KEY) / 3); ix_k++; \
        } \
        OUT_KEYS[ix_k] = sprintf("%03d",KEY); ix_k++; \
        PREV_KEY = KEY; \
        VOL = $2; \
        if ( PREV_VOL != "" ) { \
          OUT_VOLS[ix_v] = sprintf("%.3f",PREV_VOL + 1.0 * (VOL - PREV_VOL) / 3.0); ix_v++; \
          OUT_VOLS[ix_v] = sprintf("%.3f",PREV_VOL + 2.0 * (VOL - PREV_VOL) / 3.0); ix_v++; \
        } \
        OUT_VOLS[ix_v] = sprintf("%s",VOL); ix_v++; \
        PREV_VOL = VOL; \
      } \
    } \
  } \
  END { \
    print PRM_L2;
    print PRM_L3;
    print PRM_L4;
    for ( i=1 ; i <= length(OUT_KEYS) ; i++ ) { \
      if ( i != 1 ) { printf(" "); } \
      printf("%s",OUT_KEYS[i]); \
    } \
    printf("\n"); \
    for ( i=1 ; i <= length(OUT_VOLS) ; i++ ) { \
      if ( i != 1 ) { printf(" "); } \
      printf("%s",OUT_VOLS[i]); \
    } \
    printf("\n"); \
  }' >> tmp.sfz

  if [ "$VERSION5" = "1" ]; then
    # Version 5
    echo "0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0" >> tmp.sfz
  else
    # Version 6 : Add the final tuning result (tuned_sfz.txt) to the SFZ file.
    cat tuned_sfz.txt | tr -d '\r' | awk '{ \
      if ( NR==1 ) { ix=1; } \
      if ( substr($1,1,1) != "#" ) { \
        p0 = match($0, /[0-1][0-9][0-9]_[A-Z]/); \
        if ( 0 < p0 ) { \
          if ( ix != 1 ) { printf(" "); } \
          printf("%s",$2); \
          ix++; \
        } \
      } \
    } END { printf("\n"); }' >> tmp.sfz
  fi

  # Using '~' is for MinGW shell
  cat prep.sfz | tr -d '\r' | tr ' ' '~' | sed $SFZ_SED_ARGS | tr '~' ' ' >> tmp.sfz

  # Main AWK process
  cat tmp.sfz | awk '{ \
    if ( NR==1 ) { \
      VERSION=$1; \
      ix_rel=1; \
    } \
    else if ( NR==2 ) { \
      if ( $1 == "" ) { \
        AMP_VEL=73; \
      } \
      else { \
        AMP_VEL=$1; \
      } \
    } \
    else if ( NR==3 ) { \
      if ( $1 == "" ) { \
        AMPEG_RELEASE[1]=1.0; AMPEG_RELEASE[2]=5.0; AMPEG_RELEASE[3]=100; \
      } \
      else { \
        split($1,AMPEG_RELEASE,","); \
      } \
    } \
    else if ( NR==4 ) { \
      if ( $0 == "" ) { \
        for ( i=1 ; i <= 16 ; i++ ) { VOL_VEL[i] = 0.0; } \
      } \
      else { \
        split($0,VOL_VEL," "); \
      } \
    } \
    else if ( NR==5 ) { split($0,KEYS," "); } \
    else if ( NR==6 ) { split($0,VOL_KEY," "); } \
    else if ( NR==7 ) { split($0,TUNED_SFZ," "); } \
    else { \
      volume = 0.0; \
      tune = 0; \
      p0 = match($0, /[0-1][0-9][0-9]_[A-Z]/); \
      p1 = 0; \
      p_amp = 0; \
      if ( 0 < p0 ) { \
        p1 = match($0, /v[0-9][0-9][.]wav/); \
        if ( 0 < p1 ) { \
          p2 = match($0, /key=[0-9]./); \
          if ( 5 < VERSION && 0 < p2 ) { \
            key = sprintf("%03d",substr($0,p2+4,3)); \
          } \
          else { \
            key = substr($0,p0,3); \
          } \
          for ( i=1 ; i <= length(KEYS) ; i++ ) { \
            if ( key == KEYS[i] ) { \
              v = int(substr($0,p1+1,2)); \
              volume = 0.0 + VOL_VEL[v] + VOL_KEY[i]; \
              tune = TUNED_SFZ[i]; \
            } \
          } \
        } \
      } \
      else { \
        p_amp = match($0, /amp_veltrack=73/); \
        if ( p_amp < 1 ) { \
          p_amp = match($0, /amp_veltrack=82/); \
        } \
        p_rel = match($0, /ampeg_release=[0-9]/); \
      } \
      if ( 0 < p0 && 0 < p1 && tune != 0 ) { \
        OUTPUT_LINE = $0 " tune=" tune; \
      } \
      else { \
        OUTPUT_LINE = $0; \
      } \
      if ( 0 < p0 && 0 < p1 && volume != 0.0 ) { \
        p_v=match(OUTPUT_LINE, /volume[=][0123456789.+-]*/); \
        if ( 0 < p_v ) { \
          vol_org = substr(OUTPUT_LINE,p_v+7,RLENGTH-7); \
          vol_str = sprintf("volume=%+.2f",vol_org + volume); \
          sub(/volume=[^ ][^ ]*/,vol_str,OUTPUT_LINE); \
        } \
        else { \
          vol_str = sprintf("volume=%+.2f",volume); \
          sub(/[.]wav[ ]/, ".wav " vol_str " ", OUTPUT_LINE); \
        } \
        print OUTPUT_LINE; \
      } \
      else if ( 0 < p_amp ) { \
        gsub(/amp_veltrack=[0-9][0-9]*/, "amp_veltrack=" AMP_VEL, OUTPUT_LINE); print OUTPUT_LINE; \
      } \
      else if ( 0 < p_rel ) { \
        gsub(/ampeg_release=[0-9][0-9.]*/, "ampeg_release=" AMPEG_RELEASE[ix_rel], OUTPUT_LINE); \
        print OUTPUT_LINE; \
        ix_rel++; \
      } \
      else { \
        print OUTPUT_LINE; \
      } \
    } \
  }' > tmp_out.sfz
  #cat tmp_out.sfz | awk '{ printf("%s~\n",$0); }' | tr '~' '\r' > ${DEST_DIR}/../${DEST_SFZ_BASENAME}${SFZ_SUFFIX}.sfz
  cat tmp_out.sfz | awk '{ printf("%s~\n",$0); }' | tr '~' '\r' > ${DEST_DIR}/../${DEST_SFZ_BASENAME}${SFZ_SUFFIX}${SFZ_RECOMMENDED_SUFFIX}.sfz

  # Creating SFZ without Noise.
  #cat tmp_out.sfz | awk '{ \
  #  if ( substr($0,1,13) == "//HammerNoise" ) { FLG=1; } \
  #  if ( FLG == 1 ) { FLG=1; } \
  #  else { print; } \
  #}' | awk '{ printf("%s~\n",$0); }' | tr '~' '\r' > ${DEST_DIR}/../${DEST_SFZ_BASENAME}${SFZ_SUFFIX}_withoutNoise${SFZ_RECOMMENDED_SUFFIX}.sfz

fi

