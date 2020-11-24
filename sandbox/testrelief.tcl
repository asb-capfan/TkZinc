#!/usr/local/bin/wish -f

load ../tkzinc3.2.so

set top 1
set lw 8

set r [zinc .r -backcolor gray -relief sunken -lightangle 120 -render 0]
pack .r -expand t -fill both
.r configure -width 1024 -height 800
.r scale $top 1 -1

set view [.r add group $top -tags controls]

proc polypoints { ox oy rad n startangle } {
    set step [expr 2 * 3.14159 / $n]
    set startangle [expr $startangle*3.14159/180]
    set coords ""
    for {set i 0} {$i < $n} {incr i} {
	set x [expr $ox + ($rad * cos($i * $step + $startangle))];
	set y [expr $oy + ($rad * sin($i * $step + $startangle))];
	lappend coords $x $y;
    }
    lappend coords [lindex $coords 0] [lindex $coords 1]
    return $coords
}

set poly [ .r add curve $view [polypoints 200 -200 100 40 0] \
	-relief raised -linewidth $lw -smoothrelief 1 \
	-fillcolor lightblue -linecolor lightblue -filled t]

set poly [ .r add curve $view [polypoints 450 -200 100 40 0] \
	-relief raised -linewidth $lw \
	-fillcolor tan -linecolor tan -filled t]

set poly [ .r add curve $view [polypoints 700 -200 100 40 0] \
	-relief sunken -linewidth $lw \
	-fillcolor tan -linecolor tan -filled t]

set poly [ .r add curve $view [polypoints 200 -450 100 4 -45] \
	-relief sunken -linewidth $lw \
	-fillcolor tan -linecolor tan -filled t]


source "controls.tcl"
