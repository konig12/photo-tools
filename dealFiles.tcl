#!/bin/sh
# \
exec tclsh "$0" "$@"

if {[llength $argv] != 2} {
    puts "Usage:"
    puts "    dealFiles.tcl <prefix> <filesPerDir>"
    puts ""
    puts " This will create enough directories with the specified prefix to"
    puts " house all of the files in the current directory, and split them up"
    puts " in groups of the specified size."
    exit -1
}

set prefix [lindex $argv 0]
set filesPerDir [lindex $argv 1]

set files [lsort [glob *]]
set numFiles [llength $files]
set numDirectories [expr {$numFiles/$filesPerDir}]
set digitsForDirectoryNumbers [expr "int(floor(log10($numDirectories)))+1"]

for {set i 1} {$i<=$numDirectories} {incr i} {
    set firstFile [expr {($i-1)*$filesPerDir}]
    set lastFile [expr {$firstFile+$filesPerDir-1}]
    if {$lastFile > $numFiles} {
        set lastFile $numFiles
    }

    set directoryName [format "$prefix%0${digitsForDirectoryNumbers}d" $i]
    puts "Creating $directoryName..."
    file mkdir $directoryName
    file rename {*}[lrange $files $firstFile $lastFile] $directoryName
}

