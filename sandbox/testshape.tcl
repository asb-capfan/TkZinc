#!/usr/local/bin/wish -f

load ../tkzinc3.2.so

set top 1

set r [zinc .r -render 0 -borderwidth 0 -fullreshape 0 -relief sunken]
pack $r -expand t -fill both
$r configure -width 500 -height 500

set arc [.r add arc $top "50 50 200 150" -visible 1 -closed 0 -filled 0 -fillcolor white -extent 200 -pieslice 0]

set cv [.r add curve $top "50 50 100 150 270 70 220 0 200 20 180 -100 140 40 70 -100" \
	-visible  0]

.r rotate $arc [expr 3.14/10] 125 100

.r itemconfigure $top -clip $cv
