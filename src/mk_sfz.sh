#!/bin/sh

#### Creating SFZ ####

SRC_SFZ=$1
DEST_DIR=$2
DEST_SFZ_BASENAME=$3
SFZ_VOL_FACTOR_BASE_FILE=$4
SFZ_SUFFIX=$5

if [ "$4" != "" ]; then

  KEY_NID_TXT=`cat key_n-id.txt | tr -d '\r'`
  ARG_OUTFILE_SED_0=`echo "$KEY_NID_TXT" | awk '{printf("-e s/%sv/%s_%sv/ \n",$1,$2,$1);}'`
  ARG_OUTFILE_SED_1=`echo "1_2_3_4_5_6_7_8_9_" | tr '_' '\n' | awk '{printf("-e s/v%s[.]wav/v0%s.wav/ \n",$1,$1);}'`
  ARG_OUTFILE_SED=`echo "$ARG_OUTFILE_SED_0" "$ARG_OUTFILE_SED_1"`

  SFZ_SED_ARGS=`cat sfz_sed_args.txt | tr -d '\r'`

  SFZ_VOL_FACTOR_BASE=`cat $SFZ_VOL_FACTOR_BASE_FILE | tr \d '\r'`

  echo "$SFZ_VOL_FACTOR_BASE" | grep '^AMP_VEL' | sed -e 's/[^ ][^ ]*[ ][ ]*//' > tmp.sfz
  echo "$SFZ_VOL_FACTOR_BASE" | grep '^VEL_ALL' | sed -e 's/[^ ][^ ]*[ ][ ]*//' >> tmp.sfz
  echo "$SFZ_VOL_FACTOR_BASE" | grep '^[0-9][0-9][0-9][_]' | awk '{printf("%s ",substr($1,1,3));}' >> tmp.sfz
  echo >> tmp.sfz
  echo "$SFZ_VOL_FACTOR_BASE" | grep '^[0-9][0-9][0-9][_]' | awk '{printf("%s ",$2);}' >> tmp.sfz
  echo >> tmp.sfz
  cat ${SRC_SFZ} | sed $ARG_OUTFILE_SED $SFZ_SED_ARGS >> tmp.sfz

  cat tmp.sfz | awk '{ \
    if ( NR==1 ) { AMP_VEL=$1; if ( AMP_VEL == "" ){ AMP_VEL=73; } } \
    else if ( NR==2 ) { split($0,VOL_VEL," "); } \
    else if ( NR==3 ) { split($0,KEYS," "); } \
    else if ( NR==4 ) { split($0,VOL_KEY," "); } \
    else { \
      volume = 0.0; \
      p0 = match($0, /[0-9][0-9][0-9]_[A-Z]/); \
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
      } \
      if ( 0 < p0 && 0 < p1 && volume != 0.0 ) { \
        gsub(/[.]wav[ ]/, ".wav volume=" volume " ", $0); print $0; \
      } \
      else if ( 0 < p_amp ) { \
        gsub(/amp_veltrack=73/, "amp_veltrack=" AMP_VEL, $0); print $0; \
      } \
      else { \
        print $0; \
      } \
    } \
  }' > ${DEST_DIR}/../${DEST_SFZ_BASENAME}${SFZ_SUFFIX}.sfz

  cat ${DEST_DIR}/../${DEST_SFZ_BASENAME}${SFZ_SUFFIX}.sfz | awk '{ if ( substr($0,1,13) == "//HammerNoise" ){ FLG=1; } if ( FLG == 1 ) {FLG=1;} else {print;} }'  > ${DEST_DIR}/../${DEST_SFZ_BASENAME}${SFZ_SUFFIX}_withoutNoise.sfz

fi


