#!/usr/bin/tclsh

set state on 



proc ifrInit {} {
	puts "setting up the ifr\n"
	ifrSetRcvFreq; #DUT transmit frequency
	ifrSetGenFreq; #DUT RCV Frequency
	after 1000;
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
	after 1000;
	ifrCheckSinad;
}

proc idleTest {} {
	puts "idling";
	after 500;
}

ifrInit;

set x 0
while {$x < 1}	{
	txTest;
	rxTest;
	set x [expr {$x + 1}]
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

