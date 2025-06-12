#!/bin/sh

###########################
#### Preprocessing SFZ ####
###########################

if [ "$1" = "" ]; then
  echo "[USAGE]"
  echo "$0 src_sfz src_unsampled"
fi
SRC_SFZ="$1"
FLAG_TEST="$2"
SRC_UNSAMPLED="$3"

KEY_NID_TXT=`cat key_n-id.txt | tr -d '\r' | sed -e 's/^[ ]*//'`
ARG_OUTFILE_SED_0=`echo "$KEY_NID_TXT" | awk '{printf("-e s/%sv/%s_%sv/ \n",$1,$2,$1);}'`
ARG_OUTFILE_SED_1=`echo "1_2_3_4_5_6_7_8_9_" | tr '_' '\n' | awk '{printf("-e s/v%s[.]wav/v0%s.wav/ \n",$1,$1);}'`
ARG_OUTFILE_SED=`echo "$ARG_OUTFILE_SED_0" "$ARG_OUTFILE_SED_1"`

#
# Replace WAV filenames: A0v1.wav => 021_A0v01.wav
#
cat sfz_inserted.txt $SRC_SFZ | tr '\r' '~' | sed -e 's/[ ]*[~]$//' $ARG_OUTFILE_SED | awk '{ \
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
    else if ( 0 < match($0,/C4v[0-9]/) ) { \
      print $0 " pitch_keycenter=60"; \
    } \
    else { \
      print; \
    } \
  } \
}' > tmp0.sfz

#
# to be TRUE Grand piano: i.e. F6 with half damper and F#6-C8 without damper.
#
cat tmp0.sfz | grep 'F#6v' | sed -e 's/lokey/key/' -e 's/hikey=91[ ]//' > tmp1.sfz
echo ${FLAG_TEST} > tmp2.sfz
cat key_n-id_all.txt | awk '{printf("%s,%s ",$2,$1);} END {printf("\n");}' >> tmp2.sfz
cat tmp1.sfz tmp0.sfz | awk '{ \
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
}' >> tmp2.sfz

#
# for Version 5
#
if [ "$SRC_UNSAMPLED" = "" ]; then
  cat tmp2.sfz | awk '{ \
    if ( 2 < NR ) { \
      printf("%s~\n",$0); \
    } \
  }' | tr '~' '\r'
  exit 0
fi

#
# for Version 6
# - Expand WAV file assignment: lokey,hikey => key.
# - 88 <group> sections are used for each note.
# - "tune=xx" is written in <group> section.
# - If a test flag is specified, the minimum necessary code will be output.
#
cat tmp2.sfz | awk '{ \
  if ( NR == 1 ) { \
    FLAG_TEST=$1; \
    if ( substr($1,1,1) == "v" ) { \
      SEL_VEL = $1; \
    } \
    else { \
      SEL_VEL = ""; \
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
  } \
  else if ( $0 == "<master>" && FLG_1ST_MASTER_DEL == "" ) { \
    FLG_1ST_MASTER_DEL = 1; \
  } \
  else if ( NR == NR_LAST_HIKEY88 + 1 && substr($0,1,4) == "//==" ) { \
  } \
  else if ( $1 == "<group>" && substr($2,1,14) == "ampeg_release=" ) { \
    split($0,ARR," "); \
    printf("<master>"); \
    for ( i=2 ; i <= length(ARR) ; i++ ) { \
      printf(" %s",ARR[i]); \
    } \
  } \
  else { \
    if ( $0 == "//F6 with half damper" ) { KEY_S=21; KEY_E=88; } \
    else if ( $0 == "//Notes without dampers" ) { KEY_S=89; KEY_E=89; } \
    else if ( $0 == "//Release string resonances" ) { KEY_S=90; KEY_E=108; } \
    else { KEY_S=0; KEY_E=0; } \
    if ( KEY_S != 0 ) { \
      for ( i=KEY_S ; i <= KEY_E ; i++ ) { \
        printf("<group> // key_group=%d [%s]\n",i,NOTE_NAMES[i]); \
        if ( SEL_VEL == "" ) { print LINES[i]; } \
        else { \
          split(LINES[i],ARR,"\n"); \
          for ( j=1 ; j <= length(ARR) ; j++ ) { \
            p_vxx = match(ARR[j], /v[0-9][0-9][.]wav/); \
            if ( 0 < p_vxx && substr(ARR[j],p_vxx,3) == SEL_VEL ) { \
              gsub(/[ ]lovel=[0-9]*[ ]hivel=[0-9]*[ ]/, " lovel=1 ",ARR[j]); \
              printf("%s\n\n",ARR[j]); \
            } \
          } \
        } \
      } \
      printf("\n"); \
      if ( KEY_E == 108 && 0 < match(FLAG_TEST, /[a-zA-Z]/) ) { \
        exit; \
      } \
      print $0; \
    } \
    else { \
      print; \
    } \
  } \
}' > tmp3.sfz

cat $SRC_UNSAMPLED | sed -e 's/[ ][ ]*/ /g' -e 's/[ ]/,-,/g' | tr ',' ' ' > tmp_unsampled.txt

#
# Insert volume parameters
#
cat tmp_unsampled.txt tmp3.sfz | awk '{ \
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
      FLG = 1; \
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
}' | awk '{ printf("%s~\n",$0); }' | tr '~' '\r'

