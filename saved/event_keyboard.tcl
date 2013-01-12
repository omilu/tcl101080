#!/usr/bin/tclsh

proc GetData {chan}	{
	puts "you hit a key";
}
after 500
fconfigure stdin -blocking 0 -buffering none
fileevent stdin readable [list GetData stdin]
puts "entering vwait\n";
puts "done vwait\n";

#puts -nonewline "Enter your name: "
#flush stdout
#set name [gets stdin]

#puts "hello $name";
