#!/bin/bash

DIR=
STACK_SIZE=
while getopts hs: opt
do
    case "$opt" in
        s) STACK_SIZE=$OPTARG;;
        h|\?) # unknown flag
            echo >&2 "Usage: auto_pano.sh [-s] [-h] dir"
            exit 1;;
    esac
done
shift $((OPTIND-1))
[ "$1" = "--" ] && shift

DIR=$1

if [ x$DIR == x"" ]; then
    echo >&2 "Usage: auto_pano.sh [-s] [-h] dir"
    echo >&2 "    No directory provided"
    exit 2
fi
if [ ! -d $DIR ]; then
    echo "Directory $DIR does not exist."
    exit 3
fi
echo "Processing directory $DIR"

# generate the project name from the first input file name
BASE_NAME=$(ls $DIR/*.JPG | head -n 1 | sed -e 's/\.JPG$//')
OUTPUT_FILE=$BASE_NAME'_pano.pto'
echo "creating '$OUTPUT_FILE'..."

# Pass the stack size to pto_gen if needed
if [ x$STACK_SIZE == x"" ]; then
    pto_gen $DIR/*.JPG -o $OUTPUT_FILE
else
    pto_gen $DIR/*.JPG -s $STACK_SIZE -o $OUTPUT_FILE
fi

cpfind -o $OUTPUT_FILE $OUTPUT_FILE
#cpclean -o $OUTPUT_FILE $OUTPUT_FILE
autooptimiser -a -l -s -o $OUTPUT_FILE $OUTPUT_FILE

# -p 0 => rectaliniar projection
#pano_modify -o $OUTPUT_FILE -p 0 --ldr-file=JPG --output-type=BF $OUTPUT_FILE
pano_modify -o $OUTPUT_FILE --output-type=BF $OUTPUT_FILE
pano_modify -o $OUTPUT_FILE --center --straighten --canvas=AUTO --crop=AUTO $OUTPUT_FILE

# add it to the batch processer
nohup PTBatcherGUI $OUTPUT_FILE $BASE_NAME >/dev/null 2>&1 &

