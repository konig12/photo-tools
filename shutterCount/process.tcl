#!/bin/bash
# \
exec tclsh $0 $@

set fd [open "datesAndNumbers.dat" r]
set datesAndNumbers [read $fd]
close $fd

set datesAndNumbers [lsort -index 0 -unique $datesAndNumbers]

set lastNumber -1
set lastLine {}

set outData {}
lappend outData [lindex $datesAndNumbers 0]
puts [lindex $outData 0]

foreach line $datesAndNumbers {
    set number [lindex $line 1]
    #puts "reading $line"

    if { $number >= $lastNumber} {

        #puts "growing"
        set lastLine $line

    } else {

        #puts "===> new max"

        if {[string length $lastLine] > 0} {
            lappend outData $lastLine
            puts $lastLine
        }

        set lastLine {}

        lappend outData $line
        puts $line
    }

    set lastNumber $number
}

puts $lastLine
lappend outData $lastLine

set fd [open "datesAndNumbers_filtered.dat" w]
puts $fd $outData
close $fd

