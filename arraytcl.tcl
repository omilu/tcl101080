#!/usr/bin/tclsh

proc addEntry {myKey myData} {
	global myLog

	set myLog($myKey) $myData;
}

global myLog;
addEntry power 0;
addEntry sens 0;
addEntry idleBat 0;
addEntry activeBat 0;
addEntry cycleTime 0;

parray myLog;

proc myPrintLog {} {
	global myLog;
	set myList [array get myLog];

	foreach i $myList {
			puts $i;
		}

	puts "[lindex $myList]";
	for {set i 1} {$i < [llength $myList]} {set i [expr $i + 2]} {
		puts -nonewline "[lindex $myList $i]\t";
	}
	puts "";
}

myPrintLog;
addEntry power 10;
addEntry sens 20;
addEntry idleBat 30;
addEntry activeBat 40;
addEntry cycleTime 50;

myPrintLog;
proc myPrintArray {} {
	global myLog;
	#set myList [array get myLog];

	foreach i [array names myLog] {
			puts -nonewline "$myLog($i)\t";
		}
		puts "";
}
proc currentProc {} {
	set myShit [info frame 2];
	puts [lindex $myShit [expr [lsearch $myShit "proc"] + 1]]
}
proc clearMyArray {} {
	currentProc
	global myLog;
	foreach i [array names myLog] {
		set myLog($i) 0;
	}
}

puts "doing it the right way";
myPrintArray;
clearMyArray;
myPrintArray;
currentProc;
