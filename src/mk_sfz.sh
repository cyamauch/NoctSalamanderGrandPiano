#!/bin/sh

##########################
####   Creating SFZ   ####
##########################

if [ "$VERSION5" = "" ]; then
  # Version 5
  VERSION5=1
  # Version 6
  #VERSION5=0
fi

SRC_SFZ="$1"
N_LAYERS="$2"
MODE_AND_PARAMS="$3"
DEST_DIR="$4"
DEST_SFZ_BASENAME="$5"
SFZ_VOL_FACTOR_BASE_FILE="$6"
SFZ_SUFFIX="$7"
if [ "$8" != "" ]; then
  SFZ_RECOMMENDED_SUFFIX=".$8"
else
  SFZ_RECOMMENDED_SUFFIX=""
fi

#
# Preprocessing SFZ
#

if [ "$VERSION5" = "1" ]; then
  # Version 5
  sh prep_sfz.sh ${SRC_SFZ} $N_LAYERS ${MODE_AND_PARAMS} > prep.sfz
else
  # Version 6 : Volume settings will be added for all 88 keys.
  sh prep_sfz.sh ${SRC_SFZ} $N_LAYERS ${MODE_AND_PARAMS} unsampled_volumes.txt > prep.sfz
fi

#
# Main Processing
#

if [ "$DEST_SFZ_BASENAME" != "" ]; then

  SFZ_BASE_CONFIG=`cat sfz_base_config.txt | tr -d '\r'`

  SFZ_VOL_FACTOR_BASE=`cat $SFZ_VOL_FACTOR_BASE_FILE | tr -d '\r' | sed -e 's/^[ ]*//'`

  if [ "$VERSION5" = "1" ]; then
    # Version 5
    echo "5" > tmp.sfz
  else
    # Version 6
    echo "6" > tmp.sfz
  fi

  # Create an 88 note setting by linearly interpolating a 30 note setting (A0,C1,...C8).
  echo "$SFZ_BASE_CONFIG" "$SFZ_VOL_FACTOR_BASE" | awk '{ \
    if ( NR==1 ) { \
      ix_k=1; ix_v=1; \
    } \
    if ( $1 == "AMP_VELTRACK" ) { \
      PRM_L2 = $2; \
    } \
    else if ( $1 == "AMPEG_RELEASE" ) { \
      PRM_L3 = $2; \
    } \
    else if ( $1 == "VOL_'$N_LAYERS'" ) { \
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
    print PRM_L2; \
    print PRM_L3; \
    print PRM_L4; \
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

  SFZ_SED_ARGS=`echo "$SFZ_BASE_CONFIG" | awk '{ \
    if ( $1 == "VEL_'$N_LAYERS'" ) { \
      split($0,SPAN," "); \
      lo = 1; \
      for ( i=2 ; i <= length(SPAN) ; i++ ) { \
        if ( i < length(SPAN) ) { \
           printf("-e s/%%vel_v%02d%%/lovel=%d~hivel=%d/ ",i-1,lo,lo + SPAN[i] - 1); \
           lo = lo + SPAN[i]; \
        } \
        else { \
          printf("-e s/%%vel_v%02d%%/lovel=%d/ ",i-1,lo); \
        } \
      } \
    } \
  }'`

  # Using '~' is for MinGW shell
  cat prep.sfz | tr -d '\r' | tr ' ' '~' | sed $SFZ_SED_ARGS | tr '~' ' ' | awk '{ \
    if ( NR == 2 ) { \
      printf("// Accurate-Salamander Project\n"); \
      printf("// https://www.ir.isas.jaxa.jp/~cyamauch/AccurateSalamander/\n"); \
      printf("// Contact: cyamauch [at] ir.isas.jaxa.jp\n"); \
      printf("// License: CC-by\n"); \
    } else if ( NR == 3 ) { \
      printf("//\n"); \
      printf("// Original SFZ of Salamander Grand Piano V2\n"); \
    } else { \
      print; \
    } \
  }' >> tmp.sfz

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
        for ( i=1 ; i <= '$N_LAYERS' ; i++ ) { VOL_VEL[i] = 0.0; } \
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
      p_pkt = 0; \
      p_rel = 0; \
      p_kyg = 0; \
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
            } \
          } \
        } \
      } \
      else { \
        p_amp = match($0, /amp_veltrack=73/); \
        if ( p_amp < 1 ) { \
          p_amp = match($0, /amp_veltrack=82/); \
        } \
        p_pkt = match($0, /pitch_keytrack=0/); \
        if ( FLG_1ST_AMPEG_RELEASE == "" ) { \
          p_rel = match($0, /ampeg_release=[0-9]/); \
          if ( 0 < p_rel ) { \
            FLG_1ST_AMPEG_RELEASE = 1; \
          } \
        } \
        else { \
          if ( $1 == "<master>" ) { \
            p_rel = match($0, /ampeg_release=[0-9]/); \
          } \
        } \
        p_kyg = match($0, /[ ]key_group=[0-9]/); \
      } \
      OUTPUT_LINE = $0; \
      if ( 0 < p0 && 0 < p1 ) { \
        p_v=match(OUTPUT_LINE, /[ ]volume[=][0123456789.+-]*/); \
        if ( 0 < p_v ) { \
          vol_org = substr(OUTPUT_LINE,p_v+8,RLENGTH-8); \
          vol_str = sprintf("volume=%+.2f",vol_org + volume); \
          sub(/volume=[^ ][^ ]*/,vol_str,OUTPUT_LINE); \
        } \
        else { \
          vol_str = sprintf("volume=%+.2f",volume); \
          sub(/[.]wav[ ]/, ".wav " vol_str " ", OUTPUT_LINE); \
        } \
        print OUTPUT_LINE; \
      } \
      else if ( 0 < p_kyg ) { \
        split(OUTPUT_LINE,ARR," "); \
        i = int(substr($0, p_kyg + 11, 3)); \
        tune = TUNED_SFZ[i - 20]; \
        for ( i=1 ; i <= length(ARR) ; i++ ) { \
          if ( i == 1 ) { \
            if ( tune == 0 ) { \
              printf("%s tune=%d",ARR[i],tune); \
            } \
            else { \
              printf("%s tune=%+d",ARR[i],tune); \
            } \
          } \
          else { \
            printf(" %s",ARR[i]); \
          } \
        } \
        printf("\n"); \
      } \
      else if ( 0 < p_amp ) { \
        gsub(/amp_veltrack=[0-9][0-9]*/, "amp_veltrack=" AMP_VEL, OUTPUT_LINE); \
        if ( 0 < p_pkt ) { \
          gsub(/trigger=release/, "group=100 trigger=release_key", OUTPUT_LINE); \
        } \
        print OUTPUT_LINE; \
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
  }' > tmp_out_0.sfz
  # replace  key=xxx -> lokey=xxx hikey=xxx
  cat tmp_out_0.sfz | sed -e 's/\([ ]\)\(key=\)\([0-9][0-9]*[ ]\)/\1lokey=\3hikey=\3/' > tmp_out.sfz
  #cat tmp_out.sfz | awk '{ printf("%s\r\n",$0); }' > ${DEST_DIR}/../${DEST_SFZ_BASENAME}${SFZ_SUFFIX}.sfz
  #echo output: ${DEST_DIR}/../${DEST_SFZ_BASENAME}${SFZ_SUFFIX}${SFZ_RECOMMENDED_SUFFIX}.sfz

  if [ "$MODE_AND_PARAMS" != "" ]; then
    FLAG_SFZ_TYPE=`echo $MODE_AND_PARAMS | awk -F, '{print $1;}'`
    FLAG_SFZ_OPT=""
  else
    FLAG_SFZ_TYPE=""
    FLAG_SFZ_OPT=""
  fi

  if [ "$FLAG_SFZ_TYPE" = "+" ]; then
    # SFZ in daw/live
    PCM_DIR=`basename ${DEST_DIR}`
    mkdir -p ${DEST_DIR}/../sfz_minimum
    mkdir -p ${DEST_DIR}/../sfz_daw
    mkdir -p ${DEST_DIR}/../sfz_live
    cat tmp_out.sfz | sed -e "s/sample=${PCM_DIR}/sample=.."'\\'"${PCM_DIR}/" > tmp_out_in_dir.sfz
    cat tmp_out_in_dir.sfz | awk '{ if ( $0 == "//Sampled release" ) { flg=1; } if ( flg !=1 ) { print; } }' > tmp_out_minimum.sfz
    # setup "damper pedal resonance"
    if [ "$FLAG_SFZ_OPT" = "" ]; then
      RESONANCE_VOL_DB=0
    else
      RESONANCE_VOL_DB="$FLAG_SFZ_OPT"
    fi
    #
    cat tmp_out_in_dir.sfz | awk '{ \
      p0 = match($0, /[ ]key_group=[0-9]/); \
      if ( $1 == "<group>" && substr($2,1,5) == "tune=" && 0 < p0 ) { \
        tune = substr($2,6); \
        key_group = int(substr($0,p0+11,3)); \
      } \
      if ( 0 < key_group && $1 == "<region>" && 0 < match($2, /v01[.]wav/) ) { \
        SRC_0[key_group] = sprintf("<region> %s %s tune=%s",$2,$3,tune); \
        SRC_1[key_group] = $8; \
        VOL[key_group] = substr($3,8); \
      } \
      if ( $0 == "//Sampled release" ) { \
        printf("//======================\n"); \
        printf("\n"); \
        printf("// Pseudo Pedal Resonance (suggested by Peter <https://github.com/peastman>)\n"); \
        printf("// Note: In the following description, a %cdetune%c effect (a typical effect used in synthesizers)\n",34,34); \
        printf("//       is implemented using a piano%cs %ctuning curve%c to create pseudo-resonance.\n",39,34,34); \
        printf("\n"); \
        printf("<master> ampeg_attack=0.05 locc23=1\n"); \
        printf("volume_oncc23=-12\n"); \
        printf("volume_curvecc23=2  // 1 to 0 (Linear); see https://sfzformat.com/headers/curve/\n"); \
        printf("//+ampeg_release_curvecc64=12\n"); \
        printf("\n"); \
        if ( 0 ) { \
          printf("<group> group=200 group_volume=-6 locc64=22\n"); \
          printf("\n"); \
          for ( i=33 ; i <= 88 ; i++ ) { \
            printf("%s lokey=%d hikey=%d lovel=1 %s\n",SRC_0[i],i-12,i-12,SRC_1[i]); \
          } \
          printf("\n"); \
          printf("<group> group=201 group_volume=-11 locc64=26\n"); \
          for ( i=40 ; i <= 88 ; i++ ) { \
            printf("%s lokey=%d hikey=%d lovel=1 %s\n",SRC_0[i],i-19,i-19,SRC_1[i]); \
          } \
        } \
        if ( 1 ) { \
          KEY_OFFSET=3; \
          printf("<group> group=201 group_volume=%g locc64=22  // key_offset = -%d,+%d\n",-6.0+('$RESONANCE_VOL_DB'),KEY_OFFSET,KEY_OFFSET); \
          printf("\n"); \
          for ( i=21+KEY_OFFSET ; i <= 52 ; i++ ) { \
            printf("%s lokey=%d hikey=%d lovel=1 %s\n",SRC_0[i-KEY_OFFSET],i,i,SRC_1[i-KEY_OFFSET]); \
          } \
          printf("\n"); \
          for ( i=21 ; i <= 52 ; i++ ) { \
            printf("%s lokey=%d hikey=%d lovel=1 %s\n",SRC_0[i+KEY_OFFSET],i,i,SRC_1[i+KEY_OFFSET]); \
          } \
          printf("\n"); \
          KEY_OFFSET=6; \
          printf("<group> group=202 group_volume=%g locc64=22  // key_offset = -%d,+%d\n",-6.0+('$RESONANCE_VOL_DB'),KEY_OFFSET,KEY_OFFSET); \
          printf("\n"); \
          for ( i=53 ; i <= 61 ; i++ ) { \
            printf("%s lokey=%d hikey=%d lovel=1 %s\n",SRC_0[i-KEY_OFFSET],i,i,SRC_1[i-KEY_OFFSET]); \
          } \
          printf("\n"); \
          for ( i=53 ; i <= 61 ; i++ ) { \
            printf("%s lokey=%d hikey=%d lovel=1 %s\n",SRC_0[i+KEY_OFFSET],i,i,SRC_1[i+KEY_OFFSET]); \
          } \
          printf("\n"); \
          KEY_OFFSET=9; \
          printf("<group> group=203 group_volume=%g locc64=22  // key_offset = -%d,+%d\n",-6.0+('$RESONANCE_VOL_DB'),KEY_OFFSET,KEY_OFFSET); \
          printf("\n"); \
          for ( i=62 ; i <= 70 ; i++ ) { \
            printf("%s lokey=%d hikey=%d lovel=1 %s\n",SRC_0[i-KEY_OFFSET],i,i,SRC_1[i-KEY_OFFSET]); \
          } \
          printf("\n"); \
          for ( i=62 ; i <= 70 ; i++ ) { \
            printf("%s lokey=%d hikey=%d lovel=1 %s\n",SRC_0[i+KEY_OFFSET],i,i,SRC_1[i+KEY_OFFSET]); \
          } \
          printf("\n"); \
          KEY_OFFSET=6; \
          printf("<group> group=204 group_volume=%g locc64=22  // key_offset = -%d,+%d\n",-9.0+('$RESONANCE_VOL_DB'),KEY_OFFSET,KEY_OFFSET); \
          printf("\n"); \
          for ( i=71 ; i <= 77 ; i++ ) { \
            printf("%s lokey=%d hikey=%d lovel=1 %s\n",SRC_0[i-KEY_OFFSET],i,i,SRC_1[i-KEY_OFFSET]); \
          } \
          printf("\n"); \
          for ( i=71 ; i <= 77 ; i++ ) { \
            printf("%s lokey=%d hikey=%d lovel=1 %s\n",SRC_0[i+KEY_OFFSET],i,i,SRC_1[i+KEY_OFFSET]); \
          } \
          printf("\n"); \
          KEY_OFFSET=3; \
          printf("<group> group=205 group_volume=%g locc64=22  // key_offset = -%d,+%d\n",-12.0+('$RESONANCE_VOL_DB'),KEY_OFFSET,KEY_OFFSET); \
          printf("\n"); \
          for ( i=78 ; i <= 81 ; i++ ) { \
            printf("%s lokey=%d hikey=%d lovel=1 %s\n",SRC_0[i-KEY_OFFSET],i,i,SRC_1[i-KEY_OFFSET]); \
          } \
          printf("\n"); \
          for ( i=78 ; i <= 81 ; i++ ) { \
            printf("%s lokey=%d hikey=%d lovel=1 %s\n",SRC_0[i+KEY_OFFSET],i,i,SRC_1[i+KEY_OFFSET]); \
          } \
          printf("\n"); \
          KEY_OFFSET=3; \
          printf("<group> group=206 group_volume=%g locc64=22  // key_offset = -%d,+%d\n",-15.0+('$RESONANCE_VOL_DB'),KEY_OFFSET,KEY_OFFSET); \
          printf("\n"); \
          for ( i=82 ; i <= 85 ; i++ ) { \
            printf("%s lokey=%d hikey=%d lovel=1 %s\n",SRC_0[i-KEY_OFFSET],i,i,SRC_1[i-KEY_OFFSET]); \
          } \
          printf("\n"); \
          for ( i=82 ; i <= 85 ; i++ ) { \
            printf("%s lokey=%d hikey=%d lovel=1 %s\n",SRC_0[i+KEY_OFFSET],i,i,SRC_1[i+KEY_OFFSET]); \
          } \
          printf("\n"); \
          KEY_OFFSET=3; \
          printf("<group> group=207 group_volume=%g locc64=22  // key_offset = -%d,+%d\n",-18.0+('$RESONANCE_VOL_DB'),KEY_OFFSET,KEY_OFFSET); \
          printf("\n"); \
          for ( i=86 ; i <= 89 ; i++ ) { \
            printf("%s lokey=%d hikey=%d lovel=1 %s\n",SRC_0[i-KEY_OFFSET],i,i,SRC_1[i-KEY_OFFSET]); \
          } \
          printf("\n"); \
          for ( i=86 ; i <= 89 ; i++ ) { \
            printf("%s lokey=%d hikey=%d lovel=1 %s\n",SRC_0[i+KEY_OFFSET],i,i,SRC_1[i+KEY_OFFSET]); \
          } \
          printf("\n"); \
        } \
        printf("\n"); \
        printf("//======================\n"); \
        printf("\n"); \
      } \
      print; \
    }' > tmp_out_daw.sfz
    cat tmp_out_daw.sfz | sed -e 's/[ ]lovel=1[ ]/ lovel=2 /' -e 's/ampeg_dynamic=0/ampeg_dynamic=1/' -e 's/^[/][/][+&]//' | awk '{ \
      line = $0; \
      if ( $1 == "<group>" ) { \
        p0 = match($0, /[ ][\/][\/][ ]offset=[0-9]/); \
        p1 = match($0, /[ ]key_group=[0-9]/); \
        if ( 0 < p0 && 0 < p1 ) { \
          off_val = substr($0,p0+11); \
          gsub(/[-].*/, "", off_val); \
          gsub(/[ ]offset=[0-9][0-9]*[ ]/, " offset=" off_val " ",line); \
        } \
      } \
      printf("%s\n",line); \
    }' > tmp_out_live.sfz
    # final for minimum/
    cat tmp_out_minimum.sfz | awk '{ \
      if ( substr($0,1,3) == "//+" ) { \
        line = "// " substr($0,4); \
      } \
      else { \
        line = $0; \
      } \
      if ( substr($0,1,3) != "//&" ) { \
        printf("%s\r\n",line); \
      } \
    }' > ${DEST_DIR}/../sfz_minimum/${DEST_SFZ_BASENAME}${SFZ_SUFFIX}${SFZ_RECOMMENDED_SUFFIX}.sfz
    # final for daw/
    cat tmp_out_daw.sfz | awk '{ \
      if ( substr($0,1,3) == "//+" ) { \
        line = "// " substr($0,4); \
      } \
      else if ( substr($0,1,3) == "//&" ) { \
        line = substr($0,4); \
      } \
      else { \
        line = $0; \
      } \
      printf("%s\r\n",line); \
    }' > ${DEST_DIR}/../sfz_daw/${DEST_SFZ_BASENAME}${SFZ_SUFFIX}${SFZ_RECOMMENDED_SUFFIX}.sfz
    # final for live/
    cat tmp_out_live.sfz | awk '{ printf("%s\r\n",$0); }' > ${DEST_DIR}/../sfz_live/${DEST_SFZ_BASENAME}${SFZ_SUFFIX}${SFZ_RECOMMENDED_SUFFIX}.sfz
  elif [ "$FLAG_SFZ_TYPE" = "-" ]; then
    PCM_DIR=`basename ${DEST_DIR}`
    mkdir -p ${DEST_DIR}/../sfz_int_daw
    cat tmp_out.sfz | sed -e "s/sample=${PCM_DIR}/sample=.."'\\'"${PCM_DIR}/" > tmp_out_daw.sfz
    cat tmp_out_daw.sfz | awk '{ printf("%s\r\n",$0); }' > ${DEST_DIR}/../sfz_int_daw/${DEST_SFZ_BASENAME}${SFZ_SUFFIX}${SFZ_RECOMMENDED_SUFFIX}.sfz
  else
    # SFZ for testing
    cat tmp_out.sfz | awk '{ printf("%s\r\n",$0); }' > ${DEST_DIR}/../${DEST_SFZ_BASENAME}${SFZ_SUFFIX}${SFZ_RECOMMENDED_SUFFIX}.sfz
  fi

  # Creating SFZ without Noise.
  #cat tmp_out.sfz | awk '{ \
  #  if ( substr($0,1,13) == "//HammerNoise" ) { FLG=1; } \
  #  if ( FLG == 1 ) { FLG=1; } \
  #  else { print; } \
  #}' | awk '{ printf("%s\r\n",$0); }' > ${DEST_DIR}/../${DEST_SFZ_BASENAME}${SFZ_SUFFIX}_withoutNoise${SFZ_RECOMMENDED_SUFFIX}.sfz

fi

