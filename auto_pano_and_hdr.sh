#!/bin/bash

#set -e

SCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

find ./ -name 'hdr*' -print0 | xargs -0 -P 4 -I% $SCRIPTS_DIR/autohdr.sh %
find ./ -name 'pano*' -print0 | xargs -0 -P 1 -I% $SCRIPTS_DIR/autoPano.sh %

