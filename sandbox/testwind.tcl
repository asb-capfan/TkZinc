#!/usr/local/bin/wish -f

load ../tkzinc3.2.so

set top 1

set r [zinc .r -backcolor gray -relief sunken]
pack .r -expand t -fill both
.r configure -width 800 -height 500

.r addtag controls withtag $top

set ent [entry .r.entry]
set wind [.r add window $top -window $ent -position "100 100"]

set container [frame .r.cont -container t]
set id [winfo id $container]
puts "container id is $id\n"
set cont [.r add window $top -window $container -position "200 200"]
