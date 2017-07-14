#!/bin/bash
#\
exec tclsh "$0" "$@"

if {[llength $argv] != 1} {
    puts "Usage:"
    puts "    extractOpenShotVideoSegments.tcl <xmlProject>"
    exit
}

# strip out  the file info
set fileInfo [exec xmlstarlet sel -t -m //mlt/tractor/multitrack/playlist/producer -o "{" -v property -o " " -v @in -o " " -v @out -o "} " $argv]

#puts $fileInfo

set lastFile ""
set suffix 1

foreach entry $fileInfo {
    set fileName [lindex $entry 0]
    set startFrame [lindex $entry 1]
    set stopFrames [lindex $entry 2]

    if {[file isfile $fileName]} {

        # get the file's framerate
        # http://xmlstar.sourceforge.net/doc/xmlstarlet.txt
        # mediainfo --Output=XML <file> > <xml-file>
        # xmlstarlet sel -t -m //Mediainfo/File/track -v Frame_rate <xml-file>
        
        # I belive this should work, but the frame counts appear to always be based on 30 fps.
        #set frameRate [exec mediainfo --Output=XML $fileName | xmlstarlet sel -t -m //Mediainfo/File/track -v Frame_rate]
        #regexp {^[0-9.]*} $frameRate frameRateNum
        set frameRateNum [expr 30000/1001.0]

        # XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX Need to adjust this based on frame rate
        set startTime [expr $startFrame/double($frameRateNum)]
        set stopTime [expr $stopFrames/double($frameRateNum)-$startTime]

        # update the suffix number if needed.
        if {$fileName == $lastFile} {
            incr suffix
        } else {
            set suffix 1
            set lastFile $fileName
        }

        set targetName [file dirname $fileName]/[file rootname [file tail $fileName]]_[format %02u $suffix][file extension $fileName]

        puts "Extracting segment from $fileName"
        puts "    Target file: $targetName"
        puts [format "    Start: %6.3f for: %6.3f framerate: %6.3f" $startTime $stopTime $frameRateNum]

        exec ffmpeg -n -ss $startTime -i $fileName -c copy -to $stopTime $targetName -loglevel fatal
    }

}

