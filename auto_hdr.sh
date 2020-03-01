#!/bin/bash

DIR=
STACK_SIZE=
while getopts hse: opt
do
    case "$opt" in
        s) STACK_SIZE=$OPTARG;;
        e) EXTENSION=$OPTARG;;
        h|\?) # unknown flag
            echo >&2 "Usage: auto_hdr.sh [-s] [-e <extension>] [-h] dir"
            exit 1;;
    esac
done
shift $((OPTIND-1))
[ "$1" = "--" ] && shift

DIR="$1"

if [ x"$DIR" == x"" ]; then
    echo >&2 "Usage: auto_hdr.sh [-s] [-e <extension>] [-h] dir"
    echo >&2 "    No directory provided"
    exit 2
fi
if [ ! -d "$DIR" ]; then
    echo "Directory $DIR does not exist."
    exit 3
fi

if [ x$EXTENSION == x"" ]; then
    EXTENSION=JPG
fi

echo "Processing directory $DIR"

# generate the project name from the first input file name
BASE_NAME=$(ls "$DIR"/*.$EXTENSION | head -n 1 | sed -e "s/\.$EXTENSION\$/_hdr/")
OUTPUT_FILE="$BASE_NAME.$EXTENSION"'.pto'
echo "creating '$OUTPUT_FILE'..."

# Pass the stack size to pto_gen if needed
if [ x$STACK_SIZE == x"" ]; then
    pto_gen "$DIR"/*.$EXTENSION -o "$OUTPUT_FILE"
else
    pto_gen "$DIR"/*.$EXTENSION -s $STACK_SIZE -o "$OUTPUT_FILE"
fi

cpfind -o "$OUTPUT_FILE" "$OUTPUT_FILE" 
cpclean -o "$OUTPUT_FILE" "$OUTPUT_FILE" 
autooptimiser -p -o "$OUTPUT_FILE" "$OUTPUT_FILE" 

# -p 0 => rectaliniar projection
pano_modify -o "$OUTPUT_FILE" -p 0 --ldr-file=JPG --ldr-compression=95 --output-type=BF "$OUTPUT_FILE"
pano_modify -o "$OUTPUT_FILE" --fov=AUTO --canvas=AUTO --crop=AUTO "$OUTPUT_FILE"

# add it to the batch processer
nohup PTBatcherGUI "$OUTPUT_FILE" "$BASE_NAME" >/dev/null 2>&1 &

