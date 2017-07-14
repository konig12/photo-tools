#!/bin/bash

#set -e

find ./ -name 'hdr*' -print0 | xargs -0 -P 4 -I% ~/Pictures/scripts/autohdr.sh %
find ./ -name 'pano*' -print0 | xargs -0 -P 1 -I% ~/Pictures/scripts/autoPano.sh %

