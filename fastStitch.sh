#!/bin/bash

if [[ $# -ne 1 ]]
then
    echo "Usage:"
    echo "    fastStitch.sh [pano]"
    exit -1
fi

PID=$$
PANOPROJFILE=$(readlink -f $1)
PANOMAKEFILE=$PANOPROJFILE.mk
SSDTMPDIR=/ssd-tmp/fastStitch_$PID
RESULTSDIR=./results_$(date +%F-%T)

if [[ ! -e "$PANOMAKEFILE" ]]
then
    echo "makefile \"$PANOMAKEFILE\" does not exist."
    exit -1
fi

echo "Stitching using $PANOMAKEFILE..."

echo "Using temporary directory $SSDTMPDIR..."
mkdir $SSDTMPDIR

cp "$PANOMAKEFILE" $SSDTMPDIR
cp "$PANOPROJFILE" $SSDTMPDIR

cd $SSDTMPDIR
make -j 8 -f "$PANOMAKEFILE" all
# Cannot run clean on previous command due to the parallel execution.
# Also, run with local makefile copy, don't want to be sensitive to a
# project save after starting.
make -f $SSDTMPDIR/*.mk clean
cd -

echo "Finished, putting results in $RESULTSDIR."
mkdir $RESULTSDIR
mv $SSDTMPDIR/* $RESULTSDIR

rm -rf $SSDTMPDIR

