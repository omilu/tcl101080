#!/usr/bin/tclsh

#todo
#ammend mySend so that it includes a parameter to specify the return data
#position, right now it defaults to the last, but sinad data is not in
#last postion
#add function to raise a signal to enable  quiting async without having
#to poll
package require Expect

proc csv:parse {line {sepa ,}} {
	set lst [split $line $sepa]
	set nlst {}
	set l [llength $lst]
	for {set i 0} {$i < $l} {incr i} {
		if {[string index [lindex $lst $i] 0] == "\""} {
			# start of a stringhttp://purl.org/thecliff/tcl/wiki/721.html
			if {[string index [lindex $lst $i] end] == "\""} {
				# check for completeness, on our way we repair double double quotes
				set c1 [string range [lindex $lst $i] 1 end]
				set n1 [regsub -all {""} $c1 {"} c2]
					set n2 [regsub -all {"} $c2 {"} c3]
					if {$n1 == $n2} {
					# string extents to next list element
					set new_el [join [lrange $lst $i [expr {$i + 1}]] $sepa]
					set lst [lreplace $lst $i [expr {$i + 1}] $new_el]
					incr i -1
					incr l -1
					continue
	  } else {
	  # we are done with this element
	  lappend nlst [string range $c2 0 [expr {[string length $c2] - 2}]]
	  continue
	  }
       } else {
       # string extents to next list element
       set new_el [join [lrange $lst $i [expr {$i + 1}]] $sepa]
       set lst [lreplace $lst $i [expr {$i + 1}] $new_el]
       incr i -1
       incr l -1
       continue
       }
    } else {
    # the most simple case
    lappend nlst [lindex $lst $i]
    continue
    }
 }
 return $nlst
 }


 #globals

 proc init_globals {} {
	 global g_globals;
	 set g_globals(g_myTimer) 0;
	 set g_globals(g_systemTime) [clock seconds];
	 set g_globals(g_ifrIp) "199.131.111.62 1234";
	 set g_globals(g_arduinoSerialPort) "/dev/ttyS24";
	 set g_globals(g_state) on;
	 set g_globals(g_accumulator) 0 ;
	 set g_globals(g_myQuit) false;
	 set g_globals(g_myError) false;
	 set g_globals(g_myQuitMessage) 0;
	 set g_globals(g_logFile) empty;
	 set g_globals(g_serialFile) empty;
	 set g_globals(g_startTime) 0;
	 set g_globals(g_endTime) 0;
	 set g_globals(g_quit) 0;
	 set g_globals(g_error) 0;
	 set g_globals(g_currentProcedure) 0;
	 set g_globals(g_txPower) 20;
	 set g_globals(g_txDist) 110;
	 set g_globals(g_txFreqError) 450;
	 set g_globals(g_rxSensitivity) 12;#was 12
	 set g_globals(g_txTime) 55;#eiterh 55sec for 100% or 30 for 50percent
	 set g_globals(g_rxTime) 5;#either 5 for 100% or 25 for 50percent duty
	 set g_globals(g_idleTime) 5; #in seconds
	 set g_globals(g_ifrSettleTime) 4000; #in useconds length to wait to meas
	 set g_globals(g_ifrResponseTime) 100; #in useconds legnth to wait for expect response
}

proc init_accumulator {} {
	global g_accumulator;
	set g_accumulator(idleTime) 0;
	set g_accumulator(txTime) 0;
	set g_accumulator(rxTime) 0;
	set g_accumulator(sens) 0;
	set g_accumulator(txPower) 0;
	set g_accumulator(txDist) 0;
	set g_accumulator(txFreqError) 0;
	set g_accumulator(rxBattery) 0;
	set g_accumulator(txBattery) 0;
	set g_accumulator(idleBattery) 0;
}

#mySend message sends message to the ifr waits 100msec and captures
#the entire response from the ifr
#it then parses the return message and returns the last item
#which is the returned data that was requested
#this needs to be changed becuase not all data is in last position
#for instance sinad, therefore need a  paramter to specify at what position
#position is the position away from last, ie position zero is last position
#one is 2nd from last, default is zero so can call without position arg
proc mySend {message {position 0}} {
	global g_globals;
	send -i $g_globals(g_ifrHost) "$message";
	after $g_globals(g_ifrResponseTime);
	expect -i $g_globals(g_ifrHost) -re {....\n$};
	#parse the returned csv
	set myList [csv:parse $expect_out(buffer)];
	#return the last item which is the data
	return [lindex $myList [expr [llength $myList] - [expr 1 + $position]]];
}

#not useed
proc myExpect {} {
	global g_globals;
	expect -i $g_globals(g_ifrHost) -re {^.*.\n$};
	puts "the ifr said $expect_out(buffer)";

}

#polls error or quit if either gos to the signal handler to exit
#gracefuuly
proc checkError {} {
	global g_globals;
	if {$g_globals(g_myError)} {
		#exit i got an error
		puts "error detected"
		puts "ABORTING";
		sigint_handler;
}
}

proc currentProc {} {
	set myShit [info frame -1];
	set myOther [lindex $myShit [expr [lsearch $myShit "proc"] + 1]];
	puts $myOther;
	return $myOther;
}

proc setError {myvar} {
	global g_globals;
	set g_globals(g_myError) $myvar;
	puts "g_myError changed to $g_globals(g_myError)";
}

proc setQuit {myvar myMessage} {
	global g_globals;
	set g_globals(g_myQuit) $myvar;
	set g_globals(g_myQuitMessage) $myMessage;
	puts "g_myQuit changed to $g_globals(g_myQuit)";
}


#need to spawn the process globally so can refer to it in subprocess
#will be handled with expect
#fucking variable can't get to work with spawn therefore hardcode it
#spawn telnet $g_ifrIp;
spawn telnet 192.168.2.2 1234;
set g_globals(g_ifrHost) $spawn_id;


#the Timer is an egg timer
#exports 2 function setTimer {timeInSeconds} and checkTimer
#setTimer sets the global g_myTimer
proc setTimer {timeInSeconds} {
	global g_globals;
	set g_globals(g_myTimer) [expr {[clock milliseconds] + [expr $timeInSeconds * 1000]}];
}

#checks g_myTimer returns true if expired false else
proc checkTimer {} {
	global g_globals;
	expr {[clock milliseconds] > $g_globals(g_myTimer)};
}


#get a time stamp for the logfile name
proc myGetTime {} {
	set thisTime [clock seconds];
	#clock format $thisTime -format %Y%m%d%H%M%S
}

proc myGetSeconds {} {
	set thisTime [clock seconds];
	return $thisTime;
}

proc openLogFile {} {
	global g_globals;
	set fawkBad [myGetTime];
	set theTimeIs [clock format $fawkBad -format %Y%m%d%H%M%S];
	set logFileName [concat $theTimeIs.txt];
	set g_globals(g_logFile) [open "$logFileName" w]
	puts $g_globals(g_logFile) [concat [myGetTime] "101080 battery test start"];
	puts "LOg file opened $g_globals(g_logFile)";
}


proc traceWriteTitlesToFile {} {
	global g_accumulator;
	global g_globals;
	set myList [array get g_accumulator];
	for {set i 0} {$i < [llength $myList]} {set i [expr $i + 2]} {
		puts -nonewline $g_globals(g_logFile) "[lindex $myList $i]";
		if {$i < [expr [llength $myList] - 3]} {
			puts -nonewline $g_globals(g_logFile) ", ";
	} else {
		puts $g_globals(g_logFile) "";
	}

}
puts $g_globals(g_logFile) "start";
}
#writes to the file and empties the trace
proc traceAppendToFile {} {
	global g_accumulator;
	global g_globals;
	foreach i [array names g_accumulator] {
		puts -nonewline $g_globals(g_logFile) "$g_accumulator($i)\t";
}
puts $g_globals(g_logFile) "";
traceEmpty
}

proc traceAdd {someKey someValue} {
	global g_accumulator;
	if {![info exists g_accumulator($someKey)]} {
		puts "tried to add an Invalid key";
		return;
}
set g_accumulator($someKey) $someValue;
}

proc traceEmpty {} {
	global g_accumulator;
	foreach i [array names g_accumulator] {
		set g_accumulator($i) 0;
}
}




proc ifrInit {} {
	global g_accumulator;
	global g_globals;
	after $g_globals(g_ifrResponseTime);
	send -i $g_globals(g_ifrHost) "*idn?\r";
	after $g_globals(g_ifrResponseTime);
	puts "about to say expect";
	expect -i $g_globals(g_ifrHost) -re {^.*.\n$};
	puts "expect is done";
	puts "the ifr buffer said $expect_out(buffer)";
	puts ".............................";
	puts "\n"
	puts "IFR ready for communications, any setup should have been manually"
	#this can be ignored for now set the damn thing up manually
	#ifrSetRcvFreq; #DUT transmit frequency
	#ifrSetGenFreq; #DUT RCV Frequency
	after 100;
}

proc ardInit {} {
	#the arduino serial looks just like a file
	#no need for expect
	global g_globals;
	set g_globals(g_serialFile) [open "/dev/ttyS24" r+];
	fconfigure $g_globals(g_serialFile) -mode "9600,n,8,1";
	fconfigure $g_globals(g_serialFile) -buffering none;
	global g_globals;
	after $g_globals(g_ifrResponseTime);
	set data [gets $g_globals(g_serialFile)];
	puts "Arduino sent $data"
	after $g_globals(g_ifrResponseTime);
	#flush the buffer
	flush $g_globals(g_serialFile);
	puts $g_globals(g_serialFile) "b";
	after $g_globals(g_ifrResponseTime);
	set data [gets $g_globals(g_serialFile)];
	puts "Arduino measured $data";
	puts "Arduino ready";
}

proc ardUnkeyRadio {} {
	global g_globals;
	global g_accumulator;
	#flush the buffer first
	flush $g_globals(g_serialFile);
	puts $g_globals(g_serialFile) "b";
	after 1000;
	set data [gets $g_globals(g_serialFile)];
	puts "arduino measured $data";
	return $data;
}
proc ardKeyRadio {} {
	global g_globals;
	global g_accumulator;
	#flush the buffer first
	flush $g_globals(g_serialFile);
	puts $g_globals(g_serialFile) "a";
	after 1000;
	set data [gets $g_globals(g_serialFile)];
	puts "arduino measured $data";
	return $data;
}
proc ardMeas {} {
	global g_globals;
	global g_accumulator;
	#flush the buffer first
	flush $g_globals(g_serialFile);
	puts $g_globals(g_serialFile) "a";
	after 1000;
	set data [gets $g_globals(g_serialFile)];
	puts "arduino measured $data";
	return $data;
}


proc abort {}	{
	puts "aborting!"
	exit
}


proc ifrSetRcvFreq {} {
	puts "setting RCVR frequency"
	global g_globals;
	after $g_globals(g_ifrResponseTime);
}

proc ifrSetGenFreq {} {
	puts "setting RF generator frequency"
	global g_globals;
	after $g_globals(g_ifrResponseTime);
}

proc ifrKeyRadio {} {
	puts "keying radio"
	global g_globals;
	set mytemp [mySend ":syst:conf:port:uut 0\r"];
}

proc ifrFreqError {} {
	global g_globals;
	puts "checking freq error"
	#send ifr string
	#if {expect_out(buffer)}
	after $g_globals(g_ifrResponseTime);
}

proc ifrTxPower {} {
	puts "checking tx power"
	#take a reading
	#mySend ":fetc:rf:anal:trip? dbm\r";
	set mytemp [mySend ":fetc:rf:anal:trip? dbm\r"];
	puts "outside the function call"
	puts "here is what the variable returned";
	puts "$mytemp";
	return $mytemp;
	#puts [myExpect];
	#test its value
	#logit
}

proc ifrTxDist {} {
	puts "checking tx dist"
	#take a reading
	#mySend ":fetc:mod:anal:dist? dbm\r";
	set mytemp [mySend ":fetc:mod:anal:dist?\r" 1];
	puts "outside the function call"
	puts "here is what the variable returned";
	puts "$mytemp";
	return $mytemp;
	#puts [myExpect];
	#test its value
	#logit

}

proc ifrTxFreqError {} {
	puts "checking tx freq error"
	#take a reading
	#mySend ":fetc:rf:anal:foff?\r";
	set mytemp [mySend ":fetc:rf:anal:foff?\r" 1];
	puts "outside the function call"
	puts "here is what the variable returned";
	puts "$mytemp";
	return $mytemp;
	#puts [myExpect];
	#test its value
	#logit
}


proc ifrUnkeyRadio {} {
	global g_globals;
	set mytemp [mySend ":syst:conf:port:uut 15\r"];
	#	after $g_globals(g_ifrResponseTime);

}

proc ifrTestPort {toggle} {
	if {$toggle == on} {
		mySend ":syst:conf:port:uut 15\r"
}
if {$toggle == off} {
	mySend ":syst:conf:port:uut 0\r"
} else {
	mySend ":syst:conf:port:uut 15\r"
}
}

proc ifrTestPortQuery {} {
	return [mySend ":syst:conf:port:uut?\r"]
}

proc ifrGenOn {} {
	set mytemp [mySend "rf:gen:enab On\r"];
}

proc ifrGenOff {} {
	set mytemp [mySend "rf:gen:enab Off\r"];
}

proc ifrCheckSinad {} {
	puts "checking sinad"
	#take a reading, but must send position 1 to grab second from
	#last data
	set mytemp [mySend ":fetc:af:anal:sin?\r" 1];
	puts "outside the function call"
	puts "here is what the variable returned";
	puts "$mytemp";
	return $mytemp;
	#puts [myExpect];
	#test its value
	#logit
}

proc debugIfr {} {
	ifrGenOn;
	global g_globals;
	#set timer for 6 sec
	setTimer $g_globals(g_txTime); 
	#wait for 4 sec
	after $g_globals(g_ifrSettleTime);
	#take a measurement
	#this function does the limit checking and logging
	#ifrFreqError;
	#only check for power initially

	if {[set myvar [ifrTxPower]] > $g_globals(g_txPower)} {
		puts "power is good" $g_globals(g_txPower);
} else {
	puts "power is bad";
}
#wait until timer expires
while {![checkTimer]} {
}
ifrgenoff;
}
proc txTest {} {
	global g_globals;
	global g_accumulator;
	#set timer for 6 sec
	setTimer $g_globals(g_txTime); 
	puts "performing transmit test"
	#ifrKeyRadio;
	ardKeyRadio;
	#wait for 4 sec
	set g_globals(g_currentProcedure) [currentProc];
	checkError;
	after $g_globals(g_ifrSettleTime);
	while {![checkTimer]} {
		#take a measurement
		#this function does the limit checking and logging
		#ifrfreqerror;
		#only check for power initially
		if {[set myVar [ifrTxPower]] > $g_globals(g_txPower)} {
		#	puts "power is good";
		} else {
			puts "power is bad";
			setQuit true "Power failed $g_globals(g_txPower)";
			setError true
		}
		#traceAdd txBattery [ardMeas];
		if {($g_accumulator(txPower) == 0) ||  
			($g_accumulator(txPower) > [string trim $myVar])} {
			traceAdd txPower [string trim $myVar];
		}
			after $g_globals(g_ifrResponseTime);
			if {[set myVar [ifrTxDist]] < $g_globals(g_txDist)} {
		#		puts "txdist is good";
		} else {
			puts "txdist is bad";
			setQuit true "txdist failed $g_globals(g_txDist)";
			setError true
		}
		if {($g_accumulator(txDist) == 0) ||  
			($g_accumulator(txDist) < [string trim $myVar])} {
			traceAdd txDist [string trim $myVar];
		}
			after $g_globals(g_ifrResponseTime);
			if {abs([set myVar [ifrTxFreqError]]) < $g_globals(g_txFreqError)} {
				puts "txFreqError is good";
		} else {
			puts "txFreqError is bad";
			setQuit true "txFreqError $g_globals(g_txFreqError)";
			setError true
		}
		if {(abs($g_accumulator(txFreqError)) == 0) ||  
			(abs($g_accumulator(txFreqError)) < abs([string trim $myVar]))} {
		traceAdd txFreqError [string trim $myVar];
	}
			after $g_globals(g_ifrSettleTime);
}
#wait until timer expires
#while {![checkTimer]} {
#}
#ifrUnkeyRadio;
ardUnkeyRadio;
#insert an error to test
}


proc rxTest {} {
	#ifrGenOn;
	global g_globals;
	global g_accumulator;
	#set timer for 6 sec
	setTimer $g_globals(g_rxTime); 
	puts "performing Recive test"
	ifrGenOn;
	#wait for 4 sec
	set g_globals(g_currentProcedure) [currentProc];
	checkError;
	after $g_globals(g_ifrSettleTime);
	while {![checkTimer]} {
		#take a measurement
		#this function does the limit checking and logging
		#ifrFreqError;
		#only check for power initially

		if {[set myVar [ifrCheckSinad]] > $g_globals(g_rxSensitivity)} {
			puts "sinad is good";
		} else {
			puts "sinad is bad";
			setQuit true "Bad Sinad";
			setError true;
		}
		if {($g_accumulator(sens) == 0) ||  
			($g_accumulator(sens) > [string trim $myVar])} {
			traceAdd sens [string trim $myVar];
		}
		after $g_globals(g_ifrSettleTime);
	}
#wait until timer expires
#wait until timer expires
#traceAdd rxBattery [ardMeas];
while {![checkTimer]} {
}
ifrGenOff;
}

proc idleTest {} {
	global g_globals;
	#set timer for 6 sec
	setTimer $g_globals(g_idleTime); 
	puts "idling";
	#wait for 4 sec
	checkError;
	after $g_globals(g_ifrSettleTime);
	#take a measurement
	#log shit and measrue from the arduinoo also
	#query the arduino

	#log shit here and query the arduino
	#wait until timer expires
	#traceAdd idleBattery [ardMeas];
	while {![checkTimer]} {
}
#insert an error to test
#	after $g_globals(g_ifrResponseTime);
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

#this adds catches the ctrl-c signal and allow for a graceful
#shutdown how to ad
package require Expect

proc sigint_handler {} {
	puts "\n\n\n\nelapsed time";
	puts "exiting gracefuly";
	#exit
	global g_globals;
	set g_globals(g_endTime) [myGetTime];
	#ifrUnkeyRadio; 
	ardUnkeyRadio; 
	ifrGenOff;
	puts $g_globals(g_startTime);
	puts $g_globals(g_endTime);
	puts $g_globals(g_logFile) "";
	puts $g_globals(g_logFile) "";
	puts $g_globals(g_logFile) "$g_globals(g_currentProcedure)\t died";
	puts $g_globals(g_logFile) "$g_globals(g_myQuitMessage)\t died";
	puts $g_globals(g_logFile) "[clock format $g_globals(g_startTime) -format %Y%m%d%H%M%S] \t startTime";
	puts $g_globals(g_logFile) "[clock format $g_globals(g_endTime) -format %Y%m%d%H%M%S] \t endTime";
	puts $g_globals(g_logFile) "[expr $g_globals(g_endTime) - $g_globals(g_startTime)] seconds duration of test";
	set myShit [expr $g_globals(g_endTime) - $g_globals(g_startTime)];
	set myShit [duration $myShit];
	puts $g_globals(g_logFile) "$myShit seconds duration of test";
	set ::looping false;
	abort
}

trap sigint_handler SIGINT

#set start_time [clock seconds]
#set n 0
#set looping true


proc main {} {
	init_accumulator;
	init_globals;
	global g_globals;
	openLogFile;
	traceEmpty;
	traceWriteTitlesToFile;
	ifrInit; 
	ardInit;
#	traceAdd idleBattery [ardMeas];
#	traceAdd idleBattery [ardMeas];
#	traceAdd idleBattery [ardMeas];
#	traceAdd idleBattery [ardMeas];
#	traceAdd idleBattery [ardMeas];

	set g_globals(g_startTime) [myGetTime];
	puts $g_globals(g_logFile) {$g_globals(g_startTime)};


	set x 0
	while {!$g_globals(g_myQuit) && !$g_globals(g_myError)}	{
		puts "\nStarting a cycle"
		#debugIfr;
		#dump trace to file
		traceAppendToFile;		
		puts "\n";
		set myVar [lindex [time {idleTest}] 0];
		puts "time for idleTest: $myVar";
		traceAdd idleTime $myVar;
		puts "\n";
		set myVar [lindex [time {txTest}] 0];
		traceAdd txTime $myVar;
		puts "time for txTest: $myVar";
		puts "\n";
		set myVar [lindex [time {rxTest}] 0];
		traceAdd rxTime $myVar;
		puts "time for rxTest: $myVar";
		puts "\n";
		puts "Cycle complete\n"
		#setQuit true "a test message to try and quit";
		puts "Quit = $g_globals(g_myQuit)";
		puts "Error = $g_globals(g_myError)";
		puts "the current procdure $g_globals(g_currentProcedure)";
		checkError;
}	

puts "\n\n\n\nTest Complete\n\n"
#go to clean up
sigint_handler;


}

main;

#troubleshooting and examples
#declaring globals

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


