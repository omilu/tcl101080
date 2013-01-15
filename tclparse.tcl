#!/usr/bin/tclsh

 set orig_string {123,"123,521.2","Mary says ""Hello, I am Mary"""}

 set orig_string {*idn?\rAeroflex,0,1,1,2}; 
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
 # now testing...
set myList [csv:parse $orig_string]
puts "[lindex $myList 3] the 3rd index is";
puts "the last index is [lindex $myList [expr [llength $myList] - 1]]"
 puts [csv:parse $orig_string]
