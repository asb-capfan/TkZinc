#!/usr/local/bin/wish -f

load ../tkzinc3.2.so
package require Img

set top 1
set points "50 -150 100 -50 270 -130 220 -200 200 -180 180 -300 140 -320 70 -300"
set lw 3

set r [zinc .r -backcolor gray -relief sunken]
pack .r -expand t -fill both
.r configure -width 800 -height 500
.r scale $top 1 -1
#.r configure -drawbboxes t
set view [.r add group $top -tags controls]


set smooth [.r smooth $points]
set fit [.r fit  $points 0.1]


set mp [.r add curve $view $smooth \
	-linecolor yellow -fillcolor tan -fillpattern AlphaStipple8 \
	-tags "bezier" -linewidth $lw]
set mp2 [.r add curve $view $fit \
	-linecolor yellow -fillcolor tan -fillpattern AlphaStipple8 \
	-tags "bezier" -linewidth $lw]
set poly [.r add curve $view $points -marker AtcSymbol9]
set poly2 [.r add curve $view $points -marker AtcSymbol9]

.r translate $mp2 300 0
.r translate $poly2 300 0

source "controls.tcl"
