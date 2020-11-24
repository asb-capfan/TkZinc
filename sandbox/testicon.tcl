#!/usr/local/bin/wish -f

load ../tkzinc3.2.so
package require Img

set top 1

image create photo penguin -file xpenguin.png
image create photo bouton -file bouton.xpm
image create photo boutond -file bouton-down.xpm
set mask "fvwm.xbm"

set r [zinc .r -backcolor gray -relief sunken -render 1 -borderwidth 20]
pack .r -expand t -fill both
.r configure -width 800 -height 500
#.r configure -drawbboxes t
.r scale $top 1 -1
set view [.r add group $top -tags "controls"]

proc maskicon {x y group mask color anchor} {
    .r add icon $group -mask "@$mask" -position "$x $y" -anchor $anchor -color $color
    .r add rectangle $group [list [expr $x - 3.0] [expr $y - 3.0] \
    [expr $x + 3.0] [expr $y + 3.0]] -filled 1 -fillcolor red
}

proc imageicon {x y group image anchor} {
    .r add icon $group -image $image -position "$x $y" -anchor $anchor
    .r add rectangle $group [list [expr $x - 3.0] [expr $y - 3.0] \
	    [expr $x + 3.0] [expr $y + 3.0]] -filled 1 -fillcolor red
}

set x 50.0
set y -100.0
maskicon $x $y $view $mask yellow sw
set x [expr $x + 100.0]
maskicon $x $y $view $mask pink s
set x [expr $x + 100.0]
maskicon $x $y $view $mask violet se
set x 50
set y -150
maskicon $x $y $view $mask lightblue w
set x [expr $x + 100.0]
maskicon $x $y $view $mask blue center
set x [expr $x + 100.0]
maskicon $x $y $view $mask darkblue e
set x 50.0
set y -200.0
maskicon $x $y $view $mask violet nw
set x [expr $x + 100.0]
maskicon $x $y $view $mask pink n
set x [expr $x + 100.0]
maskicon $x $y $view $mask yellow ne
set x2 500.0
set y2 -300.0
imageicon $x2 $y2 $view penguin center

.r add icon $view -image bouton -position "$x2 $y2" -anchor center
.r add icon $view -image boutond -position [list [expr $x2 + 50] $y2] -anchor center
.r add text $view -text essai -position "$x2 $y2"

#
# Clip
#
puts "crée les clips"
set clip [.r add rectangle $view "50 -10 600 -300" -filled t \
	-linewidth 0 -fillcolor darkgray]
#.r rotate $clip [expr 3.14159 / 4]; #bug le rectangle forme un bonnet
# d'ane sous certains angles.
.r lower $clip
.r itemconfigure $view -clip $clip

.r addtag test withtype icon
.r bind test "<Shift-ButtonPress-1>"  "testpress %x %y"
.r bind test "<Shift-ButtonRelease-1>"  testrelease

proc testpress {lx ly} {
    global testx testy
    set testx $lx
    set testy $ly
    .r bind test "<Motion>" "testmotion %x %y"
}

proc testmotion {lx ly} {
    global testx testy
    set it [.r find withtag test]
    if {$it != ""} {
	set it [.r group [lindex $it 0]]
    }
    set res [.r transform $it "$lx $ly $testx $testy"]
    set nx [lindex $res 0]
    set ny [lindex $res 1]
    set ox [lindex $res 2]
    set oy [lindex $res 3]
    .r translate current [expr $nx - $ox] [expr $ny - $oy]
    set testx $lx
    set testy $ly
}
proc testrelease {} {
    .r bind test "<Motion>" ""
}

source controls.tcl
