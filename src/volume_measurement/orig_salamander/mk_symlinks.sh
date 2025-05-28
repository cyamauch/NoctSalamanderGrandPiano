#!/bin/sh

DIR=$1

if [ "$DIR" = "" ]; then
    echo "Specify directory."
    exit
fi

LIST=`ls $DIR | grep '^[CDEFGAB][#]*[0-9]*v[0-9][0-9]*[.]wav'`
KEY_N_ID=`cat ../../key_n-id.txt`

for i in $LIST ; do
    KEY=`echo $i | sed -e 's/v.*//'`
    ID=`echo "$KEY_N_ID" | grep $KEY | sed -e 's/^[^ ][^ ]*[ ]//'`
    VEL=`echo ${i} | sed -e 's/^[CDEFGAB][#]*[0-9]*v//' -e 's/[.]wav//'`
    NEW_NAME=`echo $ID $KEY $VEL | awk '{printf("%s_%sv%02d.wav\n",$1,$2,$3);}'`
    echo "ln -s ${DIR}/${i} $NEW_NAME"
    ln -s ${DIR}/${i} $NEW_NAME
done


