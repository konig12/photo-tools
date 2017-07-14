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

pto_gen $DIR/*.JPG -o $DIR/project.pto
cpfind -o $DIR/project.pto $DIR/project.pto 
#cpclean -o $DIR/project.pto $DIR/project.pto 
autooptimiser -a -l -s -o $DIR/project.pto $DIR/project.pto 

# -p 0 => rectaliniar projection
#pano_modify -o $DIR/project.pto -p 0 --ldr-file=JPG --output-type=BF $DIR/project.pto
pano_modify -o $DIR/project.pto --output-type=BF $DIR/project.pto
pano_modify -o $DIR/project.pto --center --straighten --canvas=AUTO --crop=AUTO $DIR/project.pto

