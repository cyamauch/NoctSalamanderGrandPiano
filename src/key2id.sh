#!/bin/sh

if [ "$1" = "" ]; then
  echo "Specify txt file having 1st col = key."
  exit
fi

cat key_n-id_all.txt $1 | tr -d '\r' | awk '{\
  if ( FLG == "" ) { \
    if ( $2 != "" ) { \
      ID[$1] = $2; \
      if ( $1 == "C8" ) { \
        FLG=1; \
      } \
    } \
  } \
  else { \
    if ( $2 != "" && 0 < match($1, /[A-Z][#]*[0-9]/) ) { \
      printf("%03d_%s %s\n",ID[$1],$1,$2); \
    } \
    else { \
      print; \
    } \
  } \
}'


