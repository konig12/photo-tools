#!/bin/bash

DIR=$1

if [ x$DIR == x"" ]; then
    echo "Usage: autoPano.sh [dir]"
    exit -1
fi
if [ ! -d $DIR ]; then
    echo "Directory $DIR does not exist."
    exit -2
fi
echo "Processing directory $DIR"

# generate the project name from the first input file name
OUTPUT_FILE=$(ls $DIR/*.JPG | head -n 1 | sed -e 's/\.JPG$/_hdr.pto/')
echo "creating '$OUTPUT_FILE'..."

NUM_IMAGES=$(ls $DIR/*.JPG -l | wc -l)


pto_gen $DIR/*.JPG -o -s $NUM_IMAGES $OUTPUT_FILE #-s to set stacks to avoid "enblend: excessive overlap detected" in the event that it can't automaticly detect stacks. But not -l so we don't link positions
cpfind -o $OUTPUT_FILE $OUTPUT_FILE 
cpclean -o $OUTPUT_FILE $OUTPUT_FILE 
autooptimiser -p -o $OUTPUT_FILE $OUTPUT_FILE 


# -p 0 => rectaliniar projection
pano_modify -o $OUTPUT_FILE -p 0 --ldr-file=JPG --output-type=BF $OUTPUT_FILE
pano_modify -o $OUTPUT_FILE --fov=AUTO --canvas=AUTO --crop=AUTO $OUTPUT_FILE

