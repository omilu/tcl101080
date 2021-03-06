#!/usr/bin/tclsh

proc duration {int_time} {
	set timeList [list]
	foreach div {86400 3600 60 1} mod {0 24 60 60} name {day hr min sec} {
		set n [expr {$int_time / $div}]
		if {$mod > 0} {set n [expr {$n % $mod}]}
		if {$n > 1} {
			lappend timeList "$n ${name}s"
		} elseif {$n == 1} {
			lappend timeList "$n $name"
		}
	}
	return [join $timeList]
}

puts [duration 3667]
