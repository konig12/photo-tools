#!/bin/bash
# \
exec tclsh $0 $@

set files [exec find ./ -iname "IMG_*"]
set files [split $files "\n"]

set datesAndNumbers {}

set ANDREW_T1i_sn 1320502219

foreach thisFile $files {
    if {[catch {
            set name [file rootname [file tail $thisFile]]

            set dateModelIndex [split [exec exiftool -CreateDate -SerialNumber -FileIndex "$thisFile"] "\n"]
            set date [lindex $dateModelIndex 0]
            set serialNumber [lindex $dateModelIndex 1]
            set number [lindex $dateModelIndex 2]

            set serialNumber [string range $serialNumber 34 end]
            if {[string compare $serialNumber $ANDREW_T1i_sn] == 0} {

                set number [string range $number 34 end]

                set date [string range $date 34 end]
                set date [clock scan $date -format "%Y:%m:%d %T"]

                if {[regexp {^[0-9]+$} $number] && [regexp {^[0-9]+$} $date]} {
                    puts "$number $date"
                    lappend datesAndNumbers "$date $number $name"
                } else {
                    puts "Skipping file $thisFile due to bad date or number format: $date $number"
                }
            } else {
                puts "Skipping file $thisFile due to wrong camera serialNumber $serialNumber (not $ANDREW_T1i_sn)"
            }
        } err]} {
        puts "Skipping file $thisFile due to $err"
    }
}

set fd [open "datesAndNumbers.dat" w]
puts $fd $datesAndNumbers
close $fd

