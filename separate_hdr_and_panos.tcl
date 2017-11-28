#!/bin/bash
# \
exec tclsh "$0" "$@"

# This script attempts to automatically organize the images in a single folder based
# on bracketed hdr frames and panos. We assume that all of the panos that we are
# interested in are bracketed. Therefore, this script looks for all bracketed images
# and puts any which do not occur too close together in time into new hdr## directories,
# while the rest are pulled into pano## directories.
#
# xxx Pano portion is not yet done.


set DIR ./

set images [glob $DIR/*.JPG]
set panoCutoff 5

set AEBNameAndTime {}

# begin by collecting the metadata for all of the images
foreach image $images {

    set exifData [exec exiftool -BracketMode -AEBBracketValue -CreateDate $image]
    set lines [split $exifData "\n"]
    set values {}

    foreach line $lines {
        set cutoffPoint [string first ":" $line]
        incr cutoffPoint
        set raw [string range $line $cutoffPoint end] 
        lappend values [string trim $raw]
    }
    
    # For each image, we want to know if it was part of a bracket and
    # if so, what exposure offset it was taken at.
    if {[lindex $values 0] == "AEB"} {
        set bracketed 1
    } else {
        set bracketed 0
    }
    set AEBValue [expr "1.0*[lindex $values 1]"]
    set time [clock scan [lindex $values 2] -format "%Y:%m:%d %T"]

    # Save away the information about all of the bracketed shots.
    if {$bracketed} {
        lappend AEBNameAndTime [list $AEBValue $image $time]
    }
}

# Sort the images chronologically to fix any mis-ordered images. This happens
# when the glob sort based on file names does not match the times. Number wrapping
# is to blame here.
set AEBNameAndTime [lsort -integer -index 2 $AEBNameAndTime]

# Now that we have the data for the bracketed images, we organize the brackets into
# sets and grab the starting and ending timestamps for the sets.
set nameSets {}
set timeBrackets {}

set end 0

while {$end < [llength $AEBNameAndTime]} {

    set start $end
    incr end
    set currentNames [lindex $AEBNameAndTime $start 1]
    set currentTimes [lindex $AEBNameAndTime $start 2]

    while {[lindex $AEBNameAndTime $end 0] != 0 && $end < [llength $AEBNameAndTime]} {
        lappend currentNames [lindex $AEBNameAndTime $end 1]
        lappend currentTimes [lindex $AEBNameAndTime $end 2]
        incr end
    }

    lappend nameSets $currentNames
    lappend timeBrackets $currentTimes
}

# No find runs of these brackets which occur close together in time. Determine if they are
# panos or HDRs, and move the files.

set end 0

set hdrNumber 1
set panoNumber 1

while {$end < [llength $nameSets]} {

    set start $end
    incr end

    set namesInSet [lindex $nameSets $start]

    if {$end < [llength $nameSets]} {
        set timeGap [expr [lindex $timeBrackets $end 0]-[lindex $timeBrackets $end-1 1]]
        while {$timeGap < $panoCutoff && $end < [llength $nameSets]} {
            # Add the names from this bracket to the set we are currently building.
            lappend namesInSet {*}[lindex $nameSets $end]

            incr end
            set timeGap [expr [lindex $timeBrackets $end 0]-[lindex $timeBrackets $end-1 1]]
        }
    }

    puts "$start $end"
    if {$end <= [expr $start+1]} {
        # There was only one bracket in this set. It must be an HDR.
        set dirName [format "hdr%02d" $hdrNumber]
        incr hdrNumber
    } else {
        # There were multiple brackets. It is a pano
        set dirName [format "pano%02d" $panoNumber]
        incr panoNumber
    }

    puts "Creating $dirName..."
    exec mkdir $dirName
    puts "moving files: $namesInSet..."
    exec mv {*}$namesInSet $dirName
}

