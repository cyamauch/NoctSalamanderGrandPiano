#!/bin/sh

#
# Setup overtone --- Generate gain1_factor.txt, gain2_factor.txt, 
#                    gain3_factor.txt and vol_factor_effective.txt.
#

if [ "$OVERTONE_CONFIG" = "" ]; then
  OVERTONE_CONFIG=overtone_config.txt
fi

if [ "$OVERTONE3_CONFIG" = "" ]; then
  OVERTONE3_CONFIG=overtone3_config.txt
fi

echo "setup_overtone: using [$OVERTONE_CONFIG]"


######## OVERTONE 1 ########

OUTFILE=gain1_factor.txt

echo "#### DO NOT EDIT.  Generated by setup_overtone.sh ####" > $OUTFILE
echo "#"                                                     >> $OUTFILE
echo "# GAIN(db) of filter1(frequency*12)"                   >> $OUTFILE
echo "#            for 200Hz <= frequency"                   >> $OUTFILE
echo "#"                                                     >> $OUTFILE
cat $OVERTONE_CONFIG | awk '{ \
  if ( substr($1,1,1) == "0" || substr($1,1,1) == "1" ) { \
    if ( $2 != "0" ) { \
      printf("%s ",substr($1,5)); \
      split($0,ARR," "); \
      for ( i=1 ; i <= 16 ; i++ ) { \
        if ( i != 1 ) { printf(","); }
        printf("%.2f",$2 * ARR[4+i]); \
      } \
      printf("\n"); \
    } \
  } \
}'      >> $OUTFILE
echo "" >> $OUTFILE


######## OVERTONE 2 ########

OUTFILE=gain2_factor.txt

echo "#### DO NOT EDIT.  Generated by setup_overtone.sh ####" > $OUTFILE
echo "#"                                                     >> $OUTFILE
echo "# GAIN(db) for filter2(frequency*26)"                  >> $OUTFILE
echo "#              for frequency < 500Hz"                  >> $OUTFILE
echo "#"                                                     >> $OUTFILE
cat $OVERTONE_CONFIG | awk '{ \
  if ( substr($1,1,1) == "0" || substr($1,1,1) == "1" ) { \
    if ( $3 != "0" ) { \
      printf("%s ",substr($1,5)); \
      split($0,ARR," "); \
      for ( i=1 ; i <= 16 ; i++ ) { \
        if ( i != 1 ) { printf(","); }
        printf("%.2f",$3 * ARR[4+i]); \
      } \
      printf("\n"); \
    } \
  } \
}'      >> $OUTFILE
echo "" >> $OUTFILE


######## OVERTONE 3 ########

OUTFILE=gain3_factor.txt

echo "#### DO NOT EDIT.  Generated by setup_overtone.sh ####" > $OUTFILE
echo "#"                                                     >> $OUTFILE
echo "# GAIN(db) of filter3(frequency*4)"                    >> $OUTFILE
echo "#            for 500Hz <= frequency"                   >> $OUTFILE
echo "#"                                                     >> $OUTFILE
cat $OVERTONE3_CONFIG | awk '{ \
  if ( substr($1,1,1) == "0" || substr($1,1,1) == "1" ) { \
    if ( $2 != "0" ) { \
      printf("%s ",substr($1,5)); \
      split($0,ARR," "); \
      for ( i=1 ; i <= 16 ; i++ ) { \
        if ( i != 1 ) { printf(","); }
        printf("%.2f",$2 * ARR[4+i]); \
      } \
      printf("\n"); \
    } \
  } \
}'      >> $OUTFILE
echo "" >> $OUTFILE


######## VOL FACTOR ########

OUTFILE_TMP=_tmp_.txt
OUTFILE=vol_factor_effective.txt

## merge two configuration files !! ##

cat $OVERTONE_CONFIG $OVERTONE3_CONFIG | awk '{ \
  p0 = match($1, /[0-9][0-9][0-9]_[A-Z]/); \
  if ( 0 < p0 ) { \
    if ( $2 != "0" || $3 != "0" ) { \
      printf("%s ",$1); \
      split($0,ARR," "); \
      for ( i=5 ; i <= 20 ; i++ ) { \
        if ( i != 5 ) { printf(" "); }
        printf("%.2f",$4 * (1.0 - ARR[i])); \
      } \
      printf("\n"); \
    } \
    else { \
      printf("%s 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00\n",$1); \
    } \
  } \
}' | sort  > $OUTFILE_TMP

# Do not remove this line!
echo "" >> $OUTFILE_TMP

echo "#### DO NOT EDIT.  Generated by setup_overtone.sh ####" > $OUTFILE
echo "#"                                                     >> $OUTFILE
echo "# for effective ratio of filter[1,2,3]."               >> $OUTFILE
echo "#"                                                     >> $OUTFILE

cat $OUTFILE_TMP | awk '{ \
  if ( NR==1 ) { \
    flg = 0; \
    p0 = match($0, /[0-9][0-9][0-9]_[A-Z]/); \
    if ( p0 == 1 ) { \
      prev_key=$1; \
      split($0,ARR," "); \
      flg = 1; \
    } \
  } \
  else { \
    p0 = match($0, /[0-9][0-9][0-9]_[A-Z]/); \
    if ( p0 == 1 ) { \
      split($0,ARR_0," "); \
      if ( prev_key == $1 ) { \
        for ( i=1 ; i <= 16 ; i++ ) { \
          ARR[1+i] = ARR[1+i] + ARR_0[1+i]; \
        } \
        flg = 3; \
      } \
      else { \
        saved=$0; \
        prev_key=$1; \
        flg = 2; \
      } \
    } \
    else { \
      if ( 1 < flg ) { flg = 1; } \
    } \
    if ( flg != 3 ) {
      if ( 0 < flg ) { \
        printf("%s",ARR[1]); \
        for ( i=1 ; i <= 16 ; i++ ) { \
          printf(" %.2f", ARR[1+i]); \
        } \
        printf("\n"); \
      } \
      if ( flg == 2 ) { split(saved,ARR," "); } \
    } \
  } \
}' >> $OUTFILE


