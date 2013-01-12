#!/usr/bin/tclsh
#
package require Expect

proc sigint_handler {} {
	puts "elapsed time"
	set ::looping false
}

trap sigint_handler SIGINT

set start_time [clock seconds]
set n 0
set looping true
while {$looping} {
	puts [incr n]
	after 500
}

