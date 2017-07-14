#!/bin/bash

set -e

if [ -e animation.gif ]; then
    echo "Error: animation.gif already exists."
    exit -1
fi

TEMPDIR=/tmp/createAnimatedGif_$$
mkdir $TEMPDIR

for i in "$@"; do
    convert $i +repage -rotate 90 -resize 512x512 $TEMPDIR/`basename $i`.gif
done

gifsicle --loop --delay 20 --dither --colors 256 -O2 $TEMPDIR/*.gif >animation.gif

rm -r $TEMPDIR
