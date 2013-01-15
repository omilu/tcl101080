#!/usr/bin/tclsh
package require Expect


#todo
#add a way to raise a signal so can quit async without having
#to poll

#globals
set g_myTimer 0;
set g_systemTime [clock seconds];
set g_ifrIp "199.131.111.62 1234";
set g_arduinoSerialPort "/dev/ttyS18";
set g_state on;
set g_accumulator empty;
set g_myQuit false;
set g_myError false;
set g_logFile empty;

proc mySend {message} {
	global g_ifrHost;
	send -i $g_ifrHost "$message";
	expect -i $g_ifrHost -re {^.*.\n$};
	puts "the ifr said $expect_out(buffer)";

}

proc myExpect {} {
	global g_ifrHost;
	expect -i $g_ifrHost -re {^.*.\n$};
	puts "the ifr said $expect_out(buffer)";

}
proc checkError {} {
	global g_myQuit;
	global g_myError;
	if {$g_myQuit || $g_myError} {
		#exit i got an error
		puts "error detected or quit"
		puts "ABORTING";
		sigint_handler;
	}
	puts "i done checked for errors";
	puts "gmyquit is $g_myQuit";
	puts "gmyerror is $g_myError";
}

proc setError {myvar} {
	global g_myError;
	set g_myError $myvar;
	puts "g_myError changed to $g_myError";
}

proc setQuit {myvar} {
	global g_myQuit;
	set g_myQuit $myvar;
	puts "g_myQuit changed to $g_myQuit";
}


#need to spawn the process globally so can refer to it in subprocess
#will be handled with expect
puts $g_ifrIp;
#fucking variable can't get to work with spawn therefore hardcode it
#spawn telnet $g_ifrIp;
spawn telnet 199.131.111.62 1234;
set g_ifrHost $spawn_id;

#the arduino serial looks just like a file
#no need for expect
#set g_arduinoSerial [open $g_arduinoSerialPort r+];
#fconfigure $g_arduinoSerial -mode "9600,n,8,1";
#fconfigure $g_arduinoSerial -buffering none

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

proc openLogFile {} {
	global g_logFile;
	set theTimeIs [myGetTime];
	set logFileName [concat $theTimeIs.txt];
	set g_logFile [open "$logFileName" w]
	puts $g_logFile [concat [myGetTime] "101080 battery test start"];
}

proc traceAdd {someText} {
	global g_accumulator;
	append g_accumulator $someText;
}

proc traceEmpty {} {
	global g_accumulator;
	set g_accumulator "_";
}




proc ifrInit {} {
	global g_ifrHost;
	after 1000;
	send -i $g_ifrHost "*idn?\r";
	after 1000;
	puts "about to say expect";
	expect -i $g_ifrHost -re {^.*.\n$};
	puts "expect is done";
	puts "the ifr buffer said $expect_out(buffer)";
	puts ".............................";
	puts "the ifr 0,string  said $expect_out(0,string)\n";
	after 1000;
	send -i $g_ifrHost "*idn?\r";
	after 1000;

	puts "about to say expect again";
	expect -i $g_ifrHost -re {^.*.\n$};
	puts "expect is done";
	puts "..................................";
	puts "here is what it buffer said after queriying again ";
	puts "the ifr sid $expect_out(buffer)";

	puts "\n"
	puts "IFR ready for communications, any setup should have been manually"
	#this can be ignored for now set the damn thing up manually
	#ifrSetRcvFreq; #DUT transmit frequency
	#ifrSetGenFreq; #DUT RCV Frequency
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
	send -
	#send ifr string
	#if {expect_out(buffer)}
	after 500;
}

proc ifrTxPower {} {
	puts "checking tx power"
	#take a reading
	#mySend ":fetc:rf:anal:trip? dbm\r";
	mySend "*idn?\r";
	puts [myExpect];
	#test its value
	#logit
}

proc ifrUnkeyRadio {} {
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
	#set timer for 6 sec
	setTimer 2; 
	#wait for 4 sec
	after 1000;
	#take a measurement
	#this function does the limit checking and logging
	#ifrFreqError;
	#only check for power initially
	ifrTxPower;
	#wait until timer expires
	while {![checkTimer]} {
	}
	ifrUnkeyRadio;
	#insert an error to test
	checkError;
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
	puts "\n\n\n\nelapsed time";
	puts "exiting gracefuly";
	#exit
	abort;
	set ::looping false;
}

trap sigint_handler SIGINT

#set start_time [clock seconds]
#set n 0
#set looping true


proc main {} {
	#establish comms with the IFR
	global g_myQuit;
	ifrInit; 


	set x 0
	while {!$g_myQuit}	{
		puts "\nStarting a cycle"
	txTest;
	rxTest;
	idleTest;
	puts "Cycle complete\n"
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

#hot to use the trace file
puts $g_accumulator
traceEmpty
traceAdd "shome shitty medssage";
traceAdd "and more shit:"
puts $g_accumulator

