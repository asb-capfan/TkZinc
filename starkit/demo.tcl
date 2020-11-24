
set path [file dirname [info script]]

source [file join [lindex [glob -directory [file join $path lib] Tkzinc*] 0] demos zinc-widget]
