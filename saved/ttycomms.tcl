#!/usr/bin/expect

#open the serial port and configure it
set serial [open /dev/ttyS18 r+]
fconfigure $serial -mode "9600,n,8,1"
fconfigure $serial -buffering none 

set outfile [open "mydata.txt" w]

after 1000;

puts "running gets on serial";
set data [gets $serial];
set size [string length $data]
if { $size } {
	puts "received $size bytes: $data"
} else {
	puts "no data"
}

set iterations 5;
while {$iterations} {
	puts "writing request"
	if {[expr $iterations % 2] == 0} {
		puts $serial "a";
		puts "semt a";
	} else {
		puts $serial "b";
		puts "sent b";
	}
	after 1000;
	puts "retrieving data"
	set data [gets $serial];
	set size [string length $data]
	if { $size } {
		puts "received $size bytes: $data"

		puts $outfile "[clock format [clock seconds] -format "%Y-%m-%dT%H:%M:%S"] $data";
		} else {
		puts "no data"
	}
	set iterations [expr $iterations - 1];
}
close $serial
close $outfile
