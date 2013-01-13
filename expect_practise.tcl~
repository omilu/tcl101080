#!/usr/bin/expect
exp_internal 1
set timeout 2
send "Greetings what is your name?"
expect -re {^.*.\n$}
send "\nhi mutha fucka $expect_out(buffer);";
send "\nwhat the $expect_out(0,string)\n";
exit
