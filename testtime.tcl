#!/usr/bin/tclsh

proc foo {} {
	after 100;
	puts "fuck";
}

set myVar [lindex [time {foo}] 0];
puts $myVar;
#puts [lindex $myVar 0];
