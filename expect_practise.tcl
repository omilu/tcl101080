#!/usr/bin/expect
#turns on helpful expect messages for troubleshotting
exp_internal 1
#set timeout short for developement default is 10sec
set timeout 2
send "Greetings what is your name?"
#capture any reply, and match the whole respone
#note the newline character
expect -re {^.*.\n$}
send "\nhi mutha fucka $expect_out(buffer);";
send "\nwhat the $expect_out(0,string)\n";
exit
