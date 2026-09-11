#!/bin/sh

###########################
#### Preprocessing SFZ ####
###########################

if [ "$1" = "" ]; then
  echo "[USAGE]"
  echo "$0 src_sfz src_unsampled"
fi
SRC_SFZ="$1"
N_LAYERS="$2"
MODE_AND_PARAMS="$3"
SRC_UNSAMPLED="$4"

KEY_NID_TXT=`cat key_n-id.txt | tr -d '\r' | sed -e 's/^[ ]*//'`
ARG_OUTFILE_SED_0=`echo "$KEY_NID_TXT" | awk '{printf("-e s/%sv/%s_%sv/ \n",$1,$2,$1);}'`
ARG_OUTFILE_SED_1=`echo "1_2_3_4_5_6_7_8_9_" | tr '_' '\n' | awk '{printf("-e s/v%s[.]wav/v0%s.wav/ \n",$1,$1);}'`
ARG_OUTFILE_SED=`echo "$ARG_OUTFILE_SED_0" "$ARG_OUTFILE_SED_1"`

#
# Replace WAV filenames: A0v1.wav => 021_A0v01.wav
#
cat sfz_inserted.txt $SRC_SFZ | tr -d '\r' | sed -e 's/[ ][ ]*$//' $ARG_OUTFILE_SED | awk '{ \
  if ( FLG == "" ) { \
    if ( CNT == "" ) { CNT=1; } \
    if ( $0 == "%" ) { CNT=CNT+1; } \
    else if ( $0 == "%%" ) { FLG=1; } \
    else { \
      ins_parts[CNT] = sprintf("%s%s\n",ins_parts[CNT],$0); \
    } \
  } \
  else { \
    if ( match($0,/\/\/Notes$/) == 1 ) { \
      printf("%s",ins_parts[1]); \
    } \
    else if ( match($0,/\/\/Notes without dampers$/) == 1 ) { \
      printf("%s",ins_parts[2]); \
    } \
    else if ( match($0,/\/\/Release string resonances$/) == 1 ) { \
      printf("%s",ins_parts[3]); \
    } \
    else if ( match($0,/\/\/HammerNoise$/) == 1 ) { \
      printf("%s",ins_parts[4]); \
    } \
    else if ( match($0,/\/\/pedalAction$/) == 1 ) { \
      printf("%s",ins_parts[5]); \
    } \
    else if ( 0 < match($0,/pedalU2[.]wav/) ) { \
      print; \
      printf("%s",ins_parts[6]); \
    } \
    else if ( 0 < match($0,/harm[SV][3]*[A-Z][#]*[0-9][.]wav/) ) { \
      split($0,ARR," "); \
      for ( i=1 ; i <= length(ARR) ; i++ ) { \
        printf("%s ",ARR[i]); \
        if ( 0 < match(ARR[i], /hikey=[0-9]/) ) { \
          printf("lovel=1 "); \
        } \
      } \
      if ( 0 < match($0,/lokey=59[ ]hikey=61/) ) { \
        printf("pitch_keycenter=60"); \
      } \
      printf("\n"); \
    } \
    else if ( 0 < match($0,/lokey=59[ ]hikey=61/) ) { \
      print $0 " pitch_keycenter=60"; \
    } \
    else { \
      print; \
    } \
  } \
}' > tmp0.sfz

#
# Mark [L][S] release resonances
#
cat tmp0.sfz | awk '{ \
  if ( NR == 1 ) { \
    cnt = 0; \
  } \
  if ( $1 == "<group>" && $2 == "trigger=release" ) { \
    cnt++; \
  } \
  if ( 1 <= cnt && cnt <= 6 ) { \
    if ( $1 == "<region>" || $1 == "<group>" ) { \
      printf("//&"); \
    } \
  } \
  print; \
}' > tmp1.sfz

#
# to be TRUE Grand piano: i.e. F6 with half damper and F#6-C8 without damper.
#
cat tmp1.sfz | grep 'F#6v' | sed -e 's/lokey/key/' -e 's/hikey=91[ ]//' > tmp2.sfz
echo ${MODE_AND_PARAMS} | tr ',' ' ' > tmp3.sfz
cat key_n-id_all.txt | awk '{printf("%s,%s ",$2,$1);} END {printf("\n");}' >> tmp3.sfz
cat tmp2.sfz tmp1.sfz | awk '{ \
  if ( FLG == "" ) { \
    if ( substr($0,1,2) == "//" ) { FLG=1; print; } \
    else { \
      ins_parts = sprintf("%s%s\n",ins_parts,$0); \
    } \
  } \
  else { \
    if ( match($0,/\/\/Notes without dampers$/) == 1 ) { \
      printf("//F6 with half damper\n\n<group> ampeg_release=5.0\n\n"); \
      printf("%s\n%s\n",ins_parts,$0); \
    } \
    else { \
      if ( 0 < match($0,/F#6v/) ) { \
        if ( FLG == 3 ) { \
          gsub(/[ ]lokey=89[ ]/, " lokey=90 ",$0); print $0; \
        } \
        else { \
          print; \
        } \
      } \
      else if ( 0 < match($0,/[ ]ampeg_release=/) ) { \
        if ( FLG == 1 ) { \
          printf("<group> ampeg_release=1.0\n"); \
          FLG = 2; \
        } \
        else if ( FLG == 2 ) { \
          printf("<group> ampeg_release=100\n"); \
          FLG = 3; \
        } \
        else { \
          print; \
        } \
      } \
      else { \
        print; \
      } \
    } \
  } \
}' >> tmp3.sfz

#
# for Version 5
#
if [ "$SRC_UNSAMPLED" = "" ]; then
  cat tmp3.sfz | awk '{ \
    if ( 2 < NR ) { \
      printf("%s\r\n",$0); \
    } \
  }'
  exit 0
fi

#
# for Version 6
#

# Append Velocity 17-

cat tmp3.sfz | awk '{ \
  if ( 2 < NR ) { \
    LINE = $0; \
    p0 = match($0, /v[0-1][0-9][.]wav/); \
    VEL = substr($0, p0, 3); \
    if ( 0 < p0 ) { \
      gsub(/[ ]lovel=[0-9][0-9]*[ ]/, " %vel_" VEL "% ", LINE); \
      gsub(/[ ]hivel=[0-9][0-9]*[ ]/, " ", LINE); \
    } \
    printf("%s\n",LINE); \
    if ( VEL == "v16" ) { \
      for ( i=17 ; i <= '$N_LAYERS' ; i++ ) { \
        s = LINE; \
        v_str = sprintf("v%d",i); \
        gsub(/v16/, v_str, s); \
        printf("%s\n",s); \
      } \
    } \
  } \
  else { \
    print; \
  } \
}' > tmp4.sfz

# - Expand WAV file assignment: lokey,hikey => key.
# - 88 <group> sections are used for each note.
# - "tune=xx" is written in <group> section.
# - If a test flag is specified, the minimum necessary code will be output.

COL_IDX=`expr $N_LAYERS + 3`
LIST_TRANSPOSE=`cat assign.txt | grep -v '^[ ]*#' | sort -n | awk '{ if(NR==1){flag=0;} if ($1!=""){ if(flag!=0){printf(",");} v=$'$COL_IDX'; if(v==""){v=0;} printf("%d:%s",int(substr($1,1,3)),v); flag=1; } }END{printf("\n");}'`
#echo $LIST_TRANSPOSE > _.txt

cat tmp4.sfz | awk '{ \
  if ( NR == 1 ) { \
    LINE_CNT_GLOBAL=0; \
    LINE_CNT_1ST_MASTER_PRMS=0; \
    MODE_STR=$1; \
    OFFSET_SEC=0; \
    if ( $2 != "" ) { \
      OFFSET_SEC=$2; \
    } \
    if ( substr($1,1,1) == "v" ) { \
      SEL_VEL = $1; \
    } \
    else { \
      SEL_VEL = ""; \
    } \
    split("'$LIST_TRANSPOSE'",ARR_TMP_LT,","); \
    for ( i=1 ; i <= length(ARR_TMP_LT) ; i++ ) { \
      split(ARR_TMP_LT[i],ARR_TMP,":"); \
      ARR_TRANSPOSE[ARR_TMP[1]] = ARR_TMP[2]; \
    } \
  } \
  else if ( NR == 2 ) { \
    split($0,ARR," "); \
    for ( i=1 ; i <= length(ARR) ; i++ ) { \
      split(ARR[i],ELM,","); \
      ix = int(sprintf("%d",ELM[1])); \
      NOTE_NAMES[ix] = ELM[2]; \
    } \
  } \
  else { \
    p0 = match($0, /[A-Z#][0-9]v[0-9]/); \
    if ( 0 < p0 ) { \
      p0 = match($0, /[ ]lokey=/); \
    } \
  } \
  if ( NR <= 2 ) { \
  } \
  else if ( $1 == "ampeg_release=1.0" && FLG_1ST_AMPEG_RELEASE == "" ) { \
    FLG_1ST_AMPEG_RELEASE = 1; \
  } \
  else if ( FLG_1ST_AMPEG_RELEASE == 1 && FLG_1ST_MASTER == "" ) { \
    LINE_CNT_GLOBAL ++; \
    ARR_GLOBAL[LINE_CNT_GLOBAL] = $0; \
    if ( $1 == "<master>" ) { \
      FLG_1ST_MASTER = 1; \
    } \
  } \
  else if ( 0 < p0 ) { \
    split($0,KEYS," "); \
    for ( i=1 ; i <= length(KEYS) ; i++ ) { \
      p1 = match(KEYS[i], /lokey=/); \
      if ( p1 == 1 ) { \
        lokey = int(substr(KEYS[i], p1 + 6)); \
        idx1 = i; \
      } \
      p2 = match(KEYS[i], /hikey=/); \
      if ( p2 == 1 ) { \
        hikey = int(substr(KEYS[i], p2 + 6)); \
        idx2 = i; \
      } \
      p3 = match(KEYS[i], /pitch_keycenter=/); \
      if ( p3 == 1 ) { \
        keycenter = int(substr(KEYS[i], p3 + 16)); \
      } \
    } \
    for ( i=lokey ; i <= hikey ; i++ ) { \
      if ( p3 == 1 ) { \
        ARR_KEYCENTER[i] = keycenter; \
      } \
      if ( i != 89 ) { \
        for ( j=1 ; j <= length(KEYS) ; j++ ) { \
          if ( 1 < j ) { \
            LINES[i] = LINES[i] " "; \
          } \
          if ( j == idx1 ) { \
            LINES[i] = LINES[i] sprintf("key=%d",i); \
          } \
          else if ( j == idx2 ) { } \
          else { \
            LINES[i] = LINES[i] sprintf("%s",KEYS[j]); \
          } \
        } \
        LINES[i] = LINES[i] sprintf("\n"); \
      } \
    } \
    if ( hikey == 88 ) { \
      NR_LAST_HIKEY88 = NR; \
    } \
  } \
  else if ( 0 < match($0, /[ ]key=89/) ) { \
    i=89; \
    LINES[i] = LINES[i] sprintf("%s\n",$0); \
    ARR_KEYCENTER[i] = 90; \
  } \
  else if ( NR == NR_LAST_HIKEY88 + 1 && substr($0,1,4) == "//==" ) { \
  } \
  else if ( $1 == "<group>" && substr($2,1,14) == "ampeg_release=" ) { \
    split($0,ARR," "); \
    if ( FLG_1ST_MASTER == 1 ) { \
      for ( i=2 ; i < length(ARR) ; i++ ) { \
        printf("%s ",ARR[i]); \
      } \
      printf("%s",ARR[i]); \
      printf("\n"); \
      for ( i=1 ; i < LINE_CNT_GLOBAL ; i++ ) { \
        printf("%s\n",ARR_GLOBAL[i]); \
      } \
      printf("%s",ARR_GLOBAL[i]); \
      FLG_1ST_MASTER = 2; \
      for ( i=1 ; i <= LINE_CNT_1ST_MASTER_PRMS ; i++ ) { \
        printf("\n%s",ARR_LINE_CNT_1ST_MASTER[i]); \
      } \
    } \
    else { \
      printf("<master>"); \
      for ( i=2 ; i <= length(ARR) ; i++ ) { \
        printf(" %s",ARR[i]); \
      } \
      for ( i=1 ; i <= LINE_CNT_1ST_MASTER_PRMS ; i++ ) { \
        printf("\n%s",ARR_LINE_CNT_1ST_MASTER[i]); \
      } \
    } \
  } \
  else if ( FLG_1ST_MASTER == 1 ) { \
    LINE_CNT_1ST_MASTER_PRMS++; \
    ARR_LINE_CNT_1ST_MASTER[LINE_CNT_1ST_MASTER_PRMS] = $0; \
  } \
  else { \
    if ( $0 == "//F6 with half damper" ) { KEY_S=21; KEY_E=88; } \
    else if ( $0 == "//Notes without dampers" ) { KEY_S=89; KEY_E=89; } \
    else if ( $0 == "//Sampled release" ) { KEY_S=90; KEY_E=108; } \
    else { KEY_S=0; KEY_E=0; } \
    if ( KEY_S != 0 ) { \
      for ( i=KEY_S ; i <= KEY_E ; i++ ) { \
        keycen = ARR_KEYCENTER[i]; \
        trans0 = ARR_TRANSPOSE[keycen]; \
        trans1 = ARR_TRANSPOSE[keycen] + (i - keycen); \
        fs0 = 48000.0 * 2.0^(trans0/12.0); \
        fs1 = 48000.0 * 2.0^(trans1/12.0); \
        offset0 = OFFSET_SEC * fs0; \
        offset1 = (OFFSET_SEC - 0.001) * fs1; \
        printf("<group> offset=%.0f // offset=%.0f-%.0f // key_group=%d [%s]\n",offset0-offset1,offset0,offset1,i,NOTE_NAMES[i]); \
        if ( SEL_VEL == "" ) { print LINES[i]; } \
        else { \
          split(LINES[i],ARR,"\n"); \
          for ( j=1 ; j <= length(ARR) ; j++ ) { \
            p_vxx = match(ARR[j], /v[0-9][0-9][.]wav/); \
            if ( 0 < p_vxx && substr(ARR[j],p_vxx,3) == SEL_VEL ) { \
              gsub(/[ ][%]vel_v[0-9]*[%][ ]/, " lovel=1 ",ARR[j]); \
              printf("%s\n\n",ARR[j]); \
            } \
          } \
        } \
      } \
      printf("\n"); \
      if ( KEY_E == 108 && 0 < match(MODE_STR, /^[a-zA-Z]/) ) { \
        exit; \
      } \
      print $0; \
    } \
    else { \
      print; \
    } \
  } \
}' > tmp5.sfz

cat $SRC_UNSAMPLED | sed -e 's/[ ][ ]*/ /g' -e 's/[ ]/,-,/g' | tr ',' ' ' > tmp_unsampled.txt

#
# Insert volume parameters
#
cat tmp_unsampled.txt tmp5.sfz | awk '{ \
  if ( match($1, /^[0-9][0-9]$/) < 1 ) { \
    FLG = 1; \
  } \
  if ( FLG != 1 ) { \
    idx = int($1); \
    if ( idx == 1 ) { split(substr($0,4),VOL1," "); } \
    else if ( idx == 2 ) { split(substr($0,4),VOL2," "); } \
    else if ( idx == 3 ) { split(substr($0,4),VOL3," "); } \
    else if ( idx == 4 ) { split(substr($0,4),VOL4," "); } \
    else if ( idx == 5 ) { split(substr($0,4),VOL5," "); } \
    else if ( idx == 6 ) { split(substr($0,4),VOL6," "); } \
    else if ( idx == 7 ) { split(substr($0,4),VOL7," "); } \
    else if ( idx == 8 ) { split(substr($0,4),VOL8," "); } \
    else if ( idx == 9 ) { split(substr($0,4),VOL9," "); } \
    else if ( idx == 10 ) { split(substr($0,4),VOL10," "); } \
    else if ( idx == 11 ) { split(substr($0,4),VOL11," "); } \
    else if ( idx == 12 ) { split(substr($0,4),VOL12," "); } \
    else if ( idx == 13 ) { split(substr($0,4),VOL13," "); } \
    else if ( idx == 14 ) { split(substr($0,4),VOL14," "); } \
    else if ( idx == 15 ) { split(substr($0,4),VOL15," "); } \
    else if ( idx == 16 ) { \
      split(substr($0,4),VOL16," "); \
      if ( idx == '$N_LAYERS' ) { FLG = 1; } \
    } \
    else if ( idx == 17 ) { \
      split(substr($0,4),VOL17," "); \
      if ( idx == '$N_LAYERS' ) { FLG = 1; } \
    } \
    else if ( idx == 18 ) { \
      split(substr($0,4),VOL18," "); \
      if ( idx == '$N_LAYERS' ) { FLG = 1; } \
    } \
    else if ( idx == 19 ) { \
      split(substr($0,4),VOL19," "); \
      if ( idx == '$N_LAYERS' ) { FLG = 1; } \
    } \
    else if ( idx == 20 ) { \
      split(substr($0,4),VOL20," "); \
      if ( idx == '$N_LAYERS' ) { FLG = 1; } \
    } \
  } \
  else { \
    p0 = match($0, /[0-9][0-9][0-9]_[A-Z][#]*[0-9]v[0-9]/); \
    if ( 0 < p0 ) { \
      p1 = match($0, /v[0-9][0-9]*[.]wav/); \
      if ( 1 <= p1 ) { \
        n = int(substr($0, p0, 3)); \
        v = int(substr($0, p1 + 1, 2)); \
        p2 = match($0, /[ ]key=/); \
        if ( 1 <= p2 ) { \
          this_key = int(substr($0, p2 + 5)); \
        } \
        p3 = match($0, /[ ]pitch_keycenter=/); \
        if ( 1 <= p3 ) { \
          keycenter = int(substr($0, p3 + 17)); \
        } \
        actual_n = n - 20 + (this_key - keycenter); \
        if ( v == 1 ) { vol = VOL1[actual_n]; } \
        else if ( v == 2 ) { vol = VOL2[actual_n]; } \
        else if ( v == 3 ) { vol = VOL3[actual_n]; } \
        else if ( v == 4 ) { vol = VOL4[actual_n]; } \
        else if ( v == 5 ) { vol = VOL5[actual_n]; } \
        else if ( v == 6 ) { vol = VOL6[actual_n]; } \
        else if ( v == 7 ) { vol = VOL7[actual_n]; } \
        else if ( v == 8 ) { vol = VOL8[actual_n]; } \
        else if ( v == 9 ) { vol = VOL9[actual_n]; } \
        else if ( v == 10 ) { vol = VOL10[actual_n]; } \
        else if ( v == 11 ) { vol = VOL11[actual_n]; } \
        else if ( v == 12 ) { vol = VOL12[actual_n]; } \
        else if ( v == 13 ) { vol = VOL13[actual_n]; } \
        else if ( v == 14 ) { vol = VOL14[actual_n]; } \
        else if ( v == 15 ) { vol = VOL15[actual_n]; } \
        else if ( v == 16 ) { vol = VOL16[actual_n]; } \
        else if ( v == 17 ) { vol = VOL17[actual_n]; } \
        else if ( v == 18 ) { vol = VOL18[actual_n]; } \
        else if ( v == 19 ) { vol = VOL19[actual_n]; } \
        else if ( v == 20 ) { vol = VOL20[actual_n]; } \
        if ( vol != "-" ) { \
          vol_str = sprintf("%+.2f",vol); \
          if ( substr(vol_str,2) == "0.00" ) { \
            vol_str = "-"; \
          } \
        } \
        else { \
          vol_str = vol; \
        } \
        split($0,KEYS," "); \
        if ( vol_str != "-" ) { \
          for ( i=1 ; i <= length(KEYS) ; i++ ) { \
            if ( 1 < i ) { printf(" "); } \
            printf("%s", KEYS[i]); \
            if ( i == 2 ) { printf(" volume=%s",vol_str); } \
          } \
          printf("\n"); \
        } \
        else { \
          for ( i=1 ; i <= length(KEYS) ; i++ ) { \
            if ( 1 < i ) { printf(" "); } \
            printf("%s", KEYS[i]); \
          } \
          printf("\n"); \
        } \
      } \
      else { \
        print; \
      } \
    } \
    else { \
      print; \
    } \
  } \
}' | awk '{ printf("%s\r\n",$0); }'

