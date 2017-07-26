#!/bin/bash

#set -e

find ./ -name 'hdr*' -print0 | xargs -0 -P 4 -I% ~/Pictures/scripts/auto_hdr.sh $0 %
find ./ -name 'pano*' -print0 | xargs -0 -P 1 -I% ~/Pictures/scripts/auto_pano.sh $0 %

