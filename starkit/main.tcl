
package require starkit

set method [starkit::startup]
if { $method eq "sourced"} return

array set help {
    demo { Launch a package demo

	Usage: demo package
    }
}

set action [lindex $argv 0]
set path [file dirname [info script]]

set validActions [array names help]
if { $action eq "" ||
     ($action eq "help" && [llength $argv] == 1 &&
      [lsearch $validActions $action] < 0) } {
    puts "Specify one of the following commands:\n"
    foreach c [array names help] {
	puts -nonewline " $c"
    }
    puts "\n\nFor more information, type: $argv0 help ?command?"
    exit
} elseif { $action eq "help" } {
    set cmd [lindex $argv 1]
    puts $help($cmd)
    exit
}

set argv [lrange $argv 1 end]

source [file join $path $action.tcl]
