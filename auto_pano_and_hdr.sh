#!/bin/bash

#set -e

while getopts hPe:? opt
do
    case "$opt" in
        P) NUM_PROCS=$OPTARG;;
        e) EXTENSION=$OPTARG;;
        h|\?) # unknown flag
            echo >&2 "Usage: auto_pano_and_hdr.sh [-P <processes>] [-e <extension>] [-h] dir"
            exit 1;;
    esac
done
shift $((OPTIND-1))
[ "$1" = "--" ] && shift

PARENT_DIR="$1"

if [ x"$PARENT_DIR" == x"" ]; then
    echo >&2 "Usage: auto_pano_and_hdr.sh [-P <processes>] [-e <extension>] [-h] dir"
    echo >&2 "    No directory provided"
    exit 2
fi
if [ ! -d $DIR ]; then
    echo "Directory $PARENT_DIR does not exist."
    exit 3
fi

SCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ x$NUM_PROCS == x"" ]; then
    NUM_PROCS=1
fi

if [ x$EXTENSION == x"" ]; then
    EXTENSION=JPG
fi

find "$PARENT_DIR" -name 'hdr*' -print0 | xargs -0 -P $NUM_PROCS -I% "$SCRIPTS_DIR"/auto_hdr.sh % -e $EXTENSION 
find "$PARENT_DIR" -name 'pano*' -print0 | xargs -0 -P $NUM_PROCS -I% "$SCRIPTS_DIR"/auto_pano.sh % -e $EXTENSION 

#Start stiching
echo "Starting stiching in the BatchProcesser"
nohup PTBatcherGUI -b >/dev/null 2>&1 &

