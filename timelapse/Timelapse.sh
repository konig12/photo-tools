#!/bin/bash
echo "Running ffmpeg."
echo "Consider calling with optional arguments passed to ffmpeg:"
echo "      -t duration"
echo "      -vf transpose=0"

#ffmpeg -r 24 -i IMG_%06d.jpg -y $@ -b 10M -bufsize 100M -s hd1080 -r 24 out.mpg
ffmpeg -r 100 -v error -i IMG_%06d.jpg -y $@ -s hd1080 -b:v 8M -r 24 out.mpg

