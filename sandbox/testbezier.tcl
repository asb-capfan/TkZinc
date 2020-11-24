#!/usr/local/bin/wish -f

load ../tkzinc3.2.so
package require Img

set top 1
set lw 8
set arrow "8 10 6"


#
#  Cap        Filled Border Relief Title
#
set show {\
  {round      f      1      flat   CapRound}\
  {butt       f      1      flat   CapButt}\
  {projecting f      1      flat   CapProjecting}\
  {round      f      1      sunken Sunken}\
  {round      f      1      raised Raised}\
  {round      f      1      groove Groove}\
  {round      f      1      ridge  Ridge}\
  {round      t      1      sunken FilledSunken}\
  {round      t      1      raised FilledRaised}\
  {round      t      1      groove FilledGroove}\
  {round      t      1      ridge  FilledRidge}\
  {round      t      0      flat   Fill}\
  {round      t      1      flat   FillBorder}}

image create photo logo -file /usr/share/toccata/images/logo.gif
#image create photo papier -file /usr/share/toccata/images/dgtexture-dragstrip.xpm

set r [zinc .r -backcolor gray -relief sunken]
pack .r -expand t -fill both
.r configure -width 1024 -height 800
.r scale $top 1 -1
#.r configure -drawbboxes t
set view [.r add group $top -tags controls]

#
# Create the model
#
set model [.r add group $view]
set mp [.r add bezier $model "50 -150 100 -50 270 -130 220 -200 200 -180 180 -300 140 -160 70 -300" \
	    -linecolor yellow -fillcolor tan -fillpattern AlphaStipple8 \
	    -tags "bezier" -linewidth $lw]
#.r add rectangle $model "50 -150 100 -50"
set bbox [.r transform $model [.r bbox $mp]]
set x [expr ([lindex $bbox 2] + [lindex $bbox 0]) / 2]
set y [expr [lindex $bbox 1] + 5]
.r add text $model -text "CapRound" -color blue -alignment center -anchor s -tags "title" \
    -position "$x $y"

#
# Now clone for each variation on the polygon
#
set col 0
set row 0
foreach current $show {
    foreach {cap filled border relief title} $current {
	set grp [.r clone $model]
	.r translate $grp [expr $col * 240] [expr $row * (-290 - (2 * $lw))]
	.r itemconfigure [.r find withtag "bezier" $grp] \
	    -capstyle $cap -filled $filled \
	    -linewidth [expr $border ? $lw : 0] \
	    -relief $relief -linecolor [expr $relief == flat ? yellow : tan]
	.r itemconfigure [.r find withtag "title" $grp] -text $title
	incr col
	if {$col >= 4} {
	    set col 0
	    incr row
	}
    }
}

#
# Suppress the model
#
.r remove $model


#
# Some optional graphic features
set closed 0
#set smooth 0
set arrows none

proc toggle_arrows { } {
    global arrows arrow
    if {$arrows == "none"} {
	set arrows first
	set f $arrow
	set l ""
    } elseif {$arrows == "first"} {
	set arrows last
	set f ""
	set l $arrow
    } elseif {$arrows == "last"} {
	set arrows both
	set f $arrow
	set l $arrow
    } elseif {$arrows == "both"} {
	set arrows none
	set f ""
	set l ""
    }
    .r itemconfigure bezier -firstend $f -lastend $l
}


proc toggle_closed { } {
    global closed
    set closed [expr ! $closed]
    foreach curve [.r find withtag "bezier"] {
	if {$closed} {
	    .r coords $curve add [.r coords $curve 0]
	} {
	    .r coords $curve remove -1
	}
    }
	
}

focus .r

bind .r "<a>" toggle_arrows
bind .r "<c>" toggle_closed

bind .r "<Shift-1>" {set it [.r find closest %x %y]; puts "$it [.r verticeat $it %x %y]"}
bind .r "<Shift-ButtonRelease-1>" {break}

source "controls.tcl"
