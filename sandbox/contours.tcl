#!/usr/local/bin/wish -f

load ../tkzinc3.2.so
package require Img

set top 1
set lw 8

set r [zinc .r -backcolor gray -relief sunken]
pack .r -expand t -fill both
.r configure -width 800 -height 500
.r scale $top 1 -1
#.r configure -drawbboxes t
set view [.r add group $top -tags controls]
#set poly [.r add curve $view "50 -150 300 -150 300 -300 50 -300 50 -150" \
#	-closed t -fillcolor tan]
set poly [.r add curve $view "50 -150 50 -300 300 -300 300 -150 50 -150" \
	-closed t -fillcolor tan -linecolor tan -linewidth 2 -relief raised]
.r scale $poly 2.0 2.0
.r translate $poly -60 150
set rect [.r add rectangle $view "50 -200 100 -50"]
set ellipse [.r add arc $view "150 -200 300 -350"]
set arc [.r add arc $view "-25 -150 125 -300"]
.r scale $arc 2.0 2.0
.r translate $arc -60 150

set mp [.r add curve $view ""  \
	    -linecolor yellow -fillcolor tan -fillpattern AlphaStipple8 \
	    -markercolor red -tags "poly" -linewidth $lw -filled t -closed t]

.r contour $mp add $poly
.r contour $mp addhole $ellipse
.r contour $mp addhole $rect
.r contour $mp add $arc

.r itemconfigure $mp -relief raised -visible t
.r lower $mp

#.r remove $arc $ellipse $rect $poly
.r remove  $rect $arc $ellipse

#.r itemconfigure $poly -relief raised -linewidth 8

# "50 -200 100 -200 100 -50 50 -50 50 -200"
source "controls.tcl"
