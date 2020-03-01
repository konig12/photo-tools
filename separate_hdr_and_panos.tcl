#!/bin/bash
# \
exec tclsh "$0" "$@"

# This script attempts to automatically organize the images in a single folder based
# on bracketed hdr frames and panos. We assume that all of the panos that we are
# interested in are bracketed. Therefore, this script looks for all bracketed images
# and puts any which do not occur too close together in time into new hdr## directories,
# while the rest are pulled into pano## directories.

set DIR [lindex $argv 0]
if {[string length $DIR] == 0} {
    set DIR ./
}

set MODE "both"
if {[llength $argv] > 1} {
    set MODE [lindex $argv 1]
    if {$MODE != "pano" && $MODE != "hdr" && $MODE != "both"} {
        puts "Bad bracket type specifified."
        puts " Usage:"
        puts "   separate_hdr_and_panos.tcl <directory> \[hdr|pano|both]"
        exit
    }
}

set images [glob $DIR/IMG_*.JPG]
set panoCutoff 5

if {$MODE == "pano"} {
    set panoCutoff 10
}

set AEBNameAndTime {}

# begin by collecting the metadata for all of the images
foreach image $images {

    set exifData [exec exiftool -BracketMode -AEBBracketValue -CreateDate $image]
    set lines [split $exifData "\n"]
    set values {}

    puts $exifData

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

    # Save away the information about all of the bracketed shots. The info we
    # need for later is the bracket value, name, and time. We create a fourth
    # value which combines the time and image number to give us a way to sort.
    # Ideally we could use one or the other, but wrapped image names cause
    # problems for name based sorts, and very close times cause issues for time
    # based sorts.
    if {$bracketed} {
        regexp {IMG_([0-9]+).JPG} $image match imageIndex
        lappend AEBNameAndTime [list $AEBValue $image $time $time$imageIndex]
    }
}

# Sort the images chronologically to fix any mis-ordered images. This happens
# when the glob sort based on file names does not match the times. Number wrapping
# is to blame here.
set AEBNameAndTime [lsort -integer -index 3 $AEBNameAndTime]

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

    # It is possible to have a single image which was shot as the first of a bracketed set,
    # but then had the bracketing aborted through something like a camera power cycle. In this
    # case we do not consider this to be a bracket after all.
    if {[llength $currentNames] > 1} {
        lappend nameSets $currentNames
        lappend timeBrackets $currentTimes
    }
}

#puts $nameSets
#puts $timeBrackets

# Now find runs of these brackets which occur close together in time. Determine if they are
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
        while {$MODE != "hdr" && $timeGap < $panoCutoff && $end < [llength $nameSets]} {
            # Add the names from this bracket to the set we are currently building.
            lappend namesInSet {*}[lindex $nameSets $end]

            incr end
            set timeGap [expr [lindex $timeBrackets $end 0]-[lindex $timeBrackets $end-1 1]]
        }
    }

    #puts "$start $end"
    if {$end <= [expr $start+1]} {
        # There was only one bracket in this set. It must be an HDR.
        set dirName [format "hdr%02d" $hdrNumber]
        incr hdrNumber
    } else {
        # There were multiple brackets. It is a pano
        set dirName [format "pano%02d" $panoNumber]
        incr panoNumber
    }

    set globNames {}
    for {set i 0} {$i < [llength $namesInSet]} {incr i} {
        lappend globNames {*}[glob "[file rootname [lindex $namesInSet $i]].*"]
    }

    puts "Creating $DIR/$dirName..."
    exec mkdir $DIR/$dirName
    puts "moving files: $globNames..."
    exec mv {*}$globNames $DIR/$dirName
}

