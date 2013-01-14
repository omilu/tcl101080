#!/usr/bin/tclsh
package require Expect

#globals
set system_time [clock seconds];
set ifr_ip "121.111.168.111 1080";
set arduino_serial_port "/dev/ttyS18";
set state on 
set accumulator empty;
set my_Quit false;

#need to spawn the process globally so can refer to it in subprocess
#will be handled with expect
#spawn telnet "$ifr_ip";
#set ifr_host $spawn_id;

#the arduino serial looks just like a file
#no need for expect
#set arduino_serial [open $arduino_serial_port r+];
#fconfigure $arduino_serial -mode "9600,n,8,1";
#fconfigure $arduino_serial -buffering none

#get a time stamp for the logfile name
proc myGetTime {} {
	set thisTime [clock seconds];
	clock format $thisTime -format %Y%m%d%H%M%S
}

set filename [myGetTime];
set logFileName [concat $filename.txt];
set logFile [open "$logFileName" w]
puts $logFile [concat [myGetTime] "101080 battery test start"];

proc traceAdd {someText} {
	global accumulator;
	append accumulator $someText;
}

proc traceEmpty {} {
	global accumulator;
	set accumulator "_";
}

puts $accumulator
traceEmpty
traceAdd "shome shitty medssage";
traceAdd "and more shit:"
puts $accumulator




proc ifrInit {} {
	puts "\n"
	puts "setting up the ifr\n"
	#this can be ignored for now set the damn thing up manually
	ifrSetRcvFreq; #DUT transmit frequency
	ifrSetGenFreq; #DUT RCV Frequency
	after 1000;
}

proc abort {}	{
	puts "aborting!"
	exit
}


proc ifrSetRcvFreq {} {
	puts "setting RCVR frequency"
	after 500;
}

proc ifrSetGenFreq {} {
	puts "setting RF generator frequency"
	after 500;
}

proc ifrKeyRadio {} {
	puts "keying radio"
	after 500;
}

proc ifrFreqError {} {
	puts "checking freq error"
	#send ifr string
	#if {expect_out(buffer)}
	after 500;
}

proc ifrUnKeyRadio {} {
	puts "unkey radio"
	after 500;
}

proc ifrGenOn {} {
	puts "turn gen on"
	after 500;
}

proc ifrGenOff {} {
	puts "turn gen off:"
	after 500;
}

proc ifrCheckSinad {} {
	puts "checking sinad"
	after 500;
}

proc txTest {} {
	puts "performing transmit test"
	ifrKeyRadio;
	after 500;
	ifrFreqError;
	
	after 1000;
	ifrUnKeyRadio;
}

proc rxTest {} {
	puts "performing Recive test"
	ifrGenOn;
	after 500;
	ifrCheckSinad;
}

proc idleTest {} {
	puts "idling";
	after 500;
}





proc ifrRunTest {} {
	puts "running test\n"
	after 1000;
}

proc ifrClean {} {
	puts "test done\n"
	after 1000;
}




proc sum {arg1 arg2} {
	set x [expr ($arg1 + $arg2)];
	return $x
}

proc timetest3 {} {
	after 500
}


puts "time to wait 5 sec: [time {timetest3}]"

#++++++++++++++++++++++++++++++++++++++++++
#this adds catches the ctrl-c signal and allow for a graceful
#shutdown how to ad
package require Expect

proc sigint_handler {} {
	puts "\n\n\n\nelapsed time"
	puts "exiting gracefuly"
	#exit
	abort
	set ::looping false
}

trap sigint_handler SIGINT

#set start_time [clock seconds]
#set n 0
#set looping true


proc main {} {
	ifrInit;

	set x 0
	while {$x < 2}	{
		puts "\nStarting a cycle"
	txTest;
	rxTest;
	idleTest;
	puts "Cycle complete\n"

	set x [expr {$x + 1}]
	}	
		puts "\n\n\n\nTest Complete\n\n"
}

main;

#troubleshooting and examples
#declaring globals
puts $ifr_ip;
puts $state;

#passing a global to a function with upvar
proc glotest {state} {
	upvar $state myvar;
	puts $myvar;
	set myvar off;
	puts $myvar;
}

proc glotest2 {} {
	global state;
	puts "glotest2";
	puts $state;
}

#exectuing the function
glotest state;
glotest2;
puts "$state out of proc";
