#!/bin/sh

if [ "$1" = "" ]; then
  echo "Specify sfz file."
  exit
fi

SRC_SFZ_FILE="$1"

cat key_n-id_all.txt $SRC_SFZ_FILE | tr -d '\r' | awk '{ \
  if ( FLG == "" ) { \
    if ( 0 < match($0, /[A-Z][#]*[0-9][ ][ ]*[0-9]/) ) { \
      split($0,ARR," "); \
      if ( length(ARR) == 2 ) { \
        ix = int(sprintf("%d",$2)); \
        KEY[ix] = $1; \
      } \
      if ( $1 == "C8" ) { \
        FLG = 1; \
      } \
    } \
  } \
  else { \
    split($0,ARR," "); \
    key_id = 0; \
    tune = 0; \
    for ( i=1 ; i <= length(ARR) ; i++ ) { \
      p_kyg = match(ARR[i], /key_group=[0-9]/); \
      if ( 0 < p_kyg ) { \
        key_id = int(substr(ARR[i], p_kyg + 10)); \
      } \
      else { \
        p_tune = match(ARR[i], /tune=[0-9+-]/); \
        if ( 0 < p_tune ) { \
          tune = int(substr(ARR[i], p_tune + 5)); \
        } \
      } \
    } \
    if ( 0 < key_id ) { \
      TUNE[key_id] = tune; \
    } \
  } \
} END { \
  print "% 1"; \
  for ( i=21 ; i <= 108 ; i+=3 ) { \
    printf("%03d_%s %d\n",i,KEY[i],TUNE[i]); \
    if ( i != 21 ) { \
      TUNE_SHIFT[i-1] = TUNE[i-1] - TUNE[i]; \
    } \
    TUNE_SHIFT[i] = 0; \
    if ( i != 108 ) { \
      TUNE_SHIFT[i+1] = TUNE[i+1] - TUNE[i]; \
    } \
  } \
  print "% 2"; \
  for ( i=21 ; i <= 108 ; i++ ) { \
    printf("%03d_%s %d\n",i,KEY[i],TUNE_SHIFT[i]); \
  } \
  print "% 0"; \
}' > tmp0.txt

sh key2id.sh tuned.txt > tmp1.txt

echo "#### updated tuned.txt ####"

cat tmp0.txt tmp1.txt | awk '{ \
  if ( FLG_OUT == "" ) { \
    if ( $1 == "%" ) { \
      FLG_READ=""; \
      if ( $2 == "1" ) { \
        FLG_READ=1; \
      } \
      else if ( $2 == "0" ) { \
        FLG_OUT=1; \
      } \
    } \
    if ( FLG_READ != "" ) { \
      ix = int(sprintf("%d",substr($1,1,3))); \
      PARAM[ix] = $2; \
      KEY_ID[ix] = $1; \
    } \
  } \
  else { \
    if ( 0 < match($1, /[0-9][0-9][0-9]_[A-Z]/) ) { \
      ix = int(sprintf("%d",substr($1,1,3))); \
      p = $2+PARAM[ix]; \
      PARAM[ix] = ""; \
      if ( p == 0 ) { \
        printf("%-3s %g\n",substr($1,5),p) ; \
      } else { \
        printf("%-3s %+g\n",substr($1,5),p) ; \
      } \
    } \
    else { \
      print; \
    } \
  } \
} END { \
  for ( i=21 ; i <= 108 ; i++ ) { \
    if ( PARAM[i] != "" ) { \
      p = PARAM[i]; \
      if ( p == 0 ) { \
        printf("%-3s %g\n",substr(KEY_ID[i],5),p); \
      } else { \
        printf("%-3s %+g\n",substr(KEY_ID[i],5),p) ; \
      } \
    } \
  } \
}'

echo "#### updated tuned_sfz.txt ####"

cat tmp0.txt tuned_sfz.txt | awk '{ \
  if ( FLG_OUT == "" ) { \
    if ( $1 == "%" ) { \
      FLG_READ=""; \
      if ( $2 == "2" ) { \
        FLG_READ=1; \
      } \
      else if ( $2 == "0" ) { \
        FLG_OUT=1; \
      } \
    } \
    if ( FLG_READ != "" ) { \
      ix = int(sprintf("%d",substr($1,1,3))); \
      PARAM[ix] = $2; \
      KEY_ID[ix] = $1; \
    } \
  } \
  else { \
    if ( 0 < match($1, /[0-9][0-9][0-9]_[A-Z]/) ) { \
      ix = int(sprintf("%d",substr($1,1,3))); \
      p = PARAM[ix]; \
      PARAM[ix] = ""; \
      if ( p == 0 ) { \
        printf("%-7s %g\n",$1,p) ; \
      } else { \
        printf("%-7s %+g\n",$1,p) ; \
      } \
    } \
    else { \
      print; \
    } \
  } \
} END { \
  for ( i=21 ; i <= 108 ; i++ ) { \
    if ( PARAM[i] != "" ) { \
      p = PARAM[i]; \
      if ( p == 0 ) { \
        printf("%-7s %g\n",KEY_ID[i],p) ; \
      } else { \
        printf("%-7s %+g\n",KEY_ID[i],p) ; \
      } \
    } \
  } \
}'

