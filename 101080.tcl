#!/usr/bin/tclsh
package require Expect


#globals
set g_myTimer 0;
set g_systemTime [clock seconds];
set g_ifrIp "121.111.168.111 1080";
set g_arduinoSerialPort "/dev/ttyS18";
set g_state on;
set g_accumulator empty;
set g_myQuit false;

#need to spawn the process globally so can refer to it in subprocess
#will be handled with expect
#spawn telnet "$g_ifrIp";
#set g_ifrHost $spawn_id;

#the arduino serial looks just like a file
#no need for expect
#set arduino_serial [open $g_arduinoSerialPort r+];
#fconfigure $arduino_serial -mode "9600,n,8,1";
#fconfigure $arduino_serial -buffering none

#the Timer is an egg timer
#exports 2 function setTimer {timeInSeconds} and checkTimer
#setTimer sets the global g_myTimer
proc setTimer {timeInSeconds} {
	global g_myTimer;
	set g_myTimer [expr {[clock milliseconds] + [expr $timeInSeconds * 1000]}];
}

#checks g_myTimer returns true if expired false else
proc checkTimer {} {
	global g_myTimer;
	expr {[clock milliseconds] > $g_myTimer};
}


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
	global g_accumulator;
	append g_accumulator $someText;
}

proc traceEmpty {} {
	global g_accumulator;
	set g_accumulator "_";
}

puts $g_accumulator
traceEmpty
traceAdd "shome shitty medssage";
traceAdd "and more shit:"
puts $g_accumulator




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
puts $g_ifrIp;
puts $g_state;

#passing a global to a function with upvar
proc glotest {g_state} {
	upvar $g_state myvar;
	puts $myvar;
	set myvar off;
	puts $myvar;
}

proc glotest2 {} {
	global g_state;
	puts "glotest2";
	puts $g_state;
}

#exectuing the function
glotest g_state;
glotest2;
puts "$g_state out of proc";

#how to use the timer and while loops and conditionals
setTimer 3;

while {![checkTimer]} {
	}
puts "done waiting";

setTimer 3;
while {true} {
	if {[checkTimer]} {
		break
	}
}
puts "done waitin gagain";
