#!/bin/sh
# \
exec tclsh $0 $@

set files [glob *.JPG]
set files [split $files " "]
set files [lsort $files]

exec mkdir renamed

set number 1
foreach file $files {
	exec cp -l $file [format "renamed/IMG_%06d.jpg" $number]
	incr number
}

