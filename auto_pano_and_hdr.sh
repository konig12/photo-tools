#!/bin/bash

#set -e

while getopts hP:? opt
do
    case "$opt" in
        P) NUM_PROCS=$OPTARG;;
        h|\?) # unknown flag
            echo >&2 "Usage: auto_pano_and_hdr.sh [-P] [-h] dir"
            exit 1;;
    esac
done

SCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ x$NUM_PROCS == x"" ]; then
    find ./ -name 'hdr*' -print0 | xargs -0 -P 4 -I% $SCRIPTS_DIR/auto_hdr.sh %
    find ./ -name 'pano*' -print0 | xargs -0 -P 1 -I% $SCRIPTS_DIR/auto_pano.sh %
else
    find ./ -name 'hdr*' -print0 | xargs -0 -P $NUM_PROCS -I% $SCRIPTS_DIR/auto_hdr.sh %
    find ./ -name 'pano*' -print0 | xargs -0 -P $NUM_PROCS -I% $SCRIPTS_DIR/auto_pano.sh %
fi


