#!/bin/bash

set -e

if [ x == "x$1" ]; then
    echo "Usage: videoStabilize.sh [videoFile]"
    exit -1
fi

VIDEO=$1
OUTPUT=${VIDEO%.*}_stab.${VIDEO##*.}
TMP_PREFIX=$$
TRF_FILE=$TMP_PREFIX-vidstab.trf
XML_FILE=$TMP_PREFIX-stabilization.xml

#melt $VIDEO -filter vidstab shakiness=7 crop=1 -consumer xml:temp_stabilization.xml all=1 real_time=-2
echo "Analyzing $VIDEO..."
melt -silent $VIDEO -filter vidstab filename=$TRF_FILE shakiness=7 -consumer xml:$XML_FILE all=1 real_time=-2 &>/dev/null

echo "Processing $VIDEO..."
melt -silent $XML_FILE -audio-track $VIDEO -consumer avformat:$OUTPUT vcodec=libx264 b=5000k acodec=aac ab=128k tune=film preset=slow &>/dev/null

rm $TRF_FILE $XML_FILE

echo "Finished $VIDEO."

