#!/bin/sh

###########################
#### Preprocessing SFZ ####
###########################

if [ "$1" = "" ]; then
  echo "[USAGE]"
  echo "$0 src_sfz src_unsampled"
fi
SRC_SFZ="$1"
SRC_UNSAMPLED="$2"

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
    else { \
      print; \
    } \
  } \
}' > tmp0.sfz


if [ "$SRC_UNSAMPLED" = "" ]; then
  #
  # for Version 5
  # to be TRUE Grand piano: i.e. F6 with half damper and F#6-C8 without damper.
  #
  cat tmp0.sfz | grep 'F#6v' | sed -e 's/lokey/key/' -e 's/hikey=91[ ]//' > tmp1.sfz
  cat tmp1.sfz tmp0.sfz | awk '{ \
    if ( FLG == "" ) { \
      if ( substr($0,1,2) == "//" ) { FLG=1; print; } \
      else { \
        ins_parts = sprintf("%s%s\n",ins_parts,$0); \
      } \
    } \
    else { \
      if ( match($0,/\/\/Notes without dampers$/) == 1 ) { \
        printf("//F6 with half damper\n\n<group> amp_veltrack=73 ampeg_release=5.0\n\n"); \
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
            printf("<group> amp_veltrack=73 ampeg_release=1.0\n"); \
            FLG = 2; \
          } \
          else if ( FLG == 2 ) { \
            printf("<group> amp_veltrack=73 ampeg_release=100\n"); \
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
}' | awk '{ printf("%s~\n",$0); }' | tr '~' '\r'
  exit 0
fi

#
# for Version 6
# Expand WAV file assignment: lokey,hikey => key
#
cat tmp0.sfz | awk '{ \
  p0 = match($0, /[A-Z#][0-9]v[0-9]/); \
  if ( 0 < p0 ) { \
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
       for ( j=1 ; j <= length(KEYS) ; j++ ) { \
         if ( 1 < j ) { printf(" "); } \
         if ( j == idx1 ) { printf("key=%d",i); } \
         else if ( j == idx2 ) { printf(""); } \
         else { \
           printf("%s",KEYS[j]); \
         } \
       } \
       printf("\n"); \
     } \
  } \
  else { \
     print; \
  } \
}' > tmp2.sfz

cat $SRC_UNSAMPLED | sed -e 's/[ ][ ]*/ /g' -e 's/[ ]/,-,/g' | tr ',' ' ' > tmp_unsampled.txt

#
# Insert volume parameters
#
cat tmp_unsampled.txt tmp2.sfz | awk '{ \
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
        actual_n = n - 20 + (this_key - keycenter);
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

