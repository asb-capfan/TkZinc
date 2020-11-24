#!/usr/local/bin/wish -f

lappend auto_path ..
package require Tkzinc
package require Img

set r [zinc .r -render 1 -backcolor gray -relief sunken]
set top 1
pack .r -expand t -fill both
.r configure -width 500 -height 800

set r [.r add rectangle $top "30 50 80 100" -filled t -fillpattern AlphaStipple0 -linewidth 1]
.r translate $r -55 -75
.r rotate $r 45
.r translate $r 55 75

.r add text $top -position "50 110" -text "0"
.r add rectangle $top "100 50 150 100" -filled t -fillpattern AlphaStipple1
.r add text $top -position "120 110" -text "1"
.r add rectangle $top "170 50 220 100" -filled t -fillpattern AlphaStipple2
.r add text $top -position "190 110" -text "2"
.r add rectangle $top "240 50 290 100" -filled t -fillpattern AlphaStipple3
.r add text $top -position "260 110" -text "3"
.r add rectangle $top "310 50 360 100" -filled t -fillpattern AlphaStipple4
.r add text $top -position "330 110" -text "4"
.r add rectangle $top "380 50 430 100" -filled t -fillpattern AlphaStipple5
.r add text $top -position "400 110" -text "5"

.r add rectangle $top "30 150 80 200" -filled t -fillpattern AlphaStipple6
.r add text $top -position "50 210" -text "6"
.r add rectangle $top "100 150 150 200" -filled t -fillpattern AlphaStipple7
.r add text $top -position "120 210" -text "7"
.r add rectangle $top "170 150 220 200" -filled t -fillpattern AlphaStipple8
.r add text $top -position "190 210" -text "8"
.r add rectangle $top "240 150 290 200" -filled t -fillpattern AlphaStipple9
.r add text $top -position "260 210" -text "9"
.r add rectangle $top "310 150 360 200" -filled t -fillpattern AlphaStipple10
.r add text $top -position "330 210" -text "10"
.r add rectangle $top "380 150 430 200" -filled t -fillpattern AlphaStipple11
.r add text $top -position "400 210" -text "11"

.r add rectangle $top "100 250 150 300" -filled t -fillpattern AlphaStipple12
.r add text $top -position "120 310" -text "12"
.r add rectangle $top "170 250 220 300" -filled t -fillpattern AlphaStipple13
.r add text $top -position "190 310" -text "13"
.r add rectangle $top "240 250 290 300" -filled t -fillpattern AlphaStipple14
.r add text $top -position "260 310" -text "14"
.r add rectangle $top "310 250 360 300" -filled t -fillpattern AlphaStipple15
.r add text $top -position "330 310" -text "15"

.r add text $top -position "180 360" -text "AlphaStipple" \
	-font "-*-lucida-bold-r-normal-*-14-*-*-*-*-*-*-*"

for {set i 0} {$i < 22} {incr i} {
    set num [expr $i + 1]
    .r add waypoint $top 0 \
	    -position "[expr 40 + ($i % 8)*60] [expr 420 + ($i / 8)*45]" \
	    -symbol "AtcSymbol$num"
    .r add text $top \
	    -position "[expr 36 + ($i % 8)*60] [expr 430 + ($i / 8)*45]" \
	    -text "$num" \
	    -font "-*-helvetica-medium-r-*-*-*-120-*-*-*-*-*-*"
}

.r add text $top -position "180 560" -text "AtcSymbol" \
	-font "-*-lucida-bold-r-normal-*-14-*-*-*-*-*-*-*"


set im [image create bitmap toto -background "red" -file fvwm.xbm]
set icim [.r add icon 1 -image $im -position {0 0}]
.r rotate $icim 20
.r scale $icim 1.2 1.2
.r translate $icim 50 320
#.r add icon 1 -image $im -position {300 10}
#.r add rectangle 1 {10 10 100 100} -tile $im -filled 1
#$im configure -background red

set icbit [.r add icon 1 -image @fvwm.xbm -position {100 400}]

#.r bind $icbit <Enter> ".r itemconfigure $icbit -color red; \
# $im configure -file fvwm.xbm -foreground black"
#.r bind $icbit <Leave> ".r itemconfigure $icbit -color black; \
# $im configure -file trash.xbm -foreground red "

#.r bind $icim <Enter> "$im configure -background black"
#.r bind $icim <Leave> "$im configure -background red"
