# these simple samples have been developped by C. Mertz mertz@cena.fr in perl
# tcl version by Jean-Paul Imbert imbert@cena.fr

if {![info exists zincDemo]} {
    error "This script should be run from the zinc-widget demo."
}

namespace eval fillRule {
    variable w .fillRule
    catch {destroy $w}
    toplevel $w
    wm title $w "Zinc Fillrule Demonstration"
    wm iconname $w "Fillrule"
    
    variable defaultfont [font create -family Helvetica -size 16 -weight normal]
    
    grid [button $w.dismiss -text Dismiss -command "destroy $w"] -row 2 -column 0 -pady 10
    grid [button $w.code -text "See Code" -command "showCode $w"] -row 2 -column 1 -pady 10
    
    
    ####### This file has been largely inspired from figure 11-3
    ####### of "The OpenGL Programming Guide 3rd Edition The 
    ####### Official Guide to Learning OpenGL Version 1.2" ISBN 0201604582
    
    ####### it illustrates the use of :
    #######  -fillrule attribute of curves
    #######  contour coords and clone method
    
    #variable imagePath [file join $zinc_library demos images]
    #variable texture [image create photo -file [file join $imagePath paper-grey1.gif]]
    
    grid [zinc $w.zinc -width 550 -height 680 -font $defaultfont -borderwidth 0 \
	      -backcolor \#898A8F] -row 1 -column 0 -columnspan 2 -sticky news
    grid columnconfigure $w 0 -weight 1
    grid columnconfigure $w 1 -weight 1
    grid rowconfigure $w 1 -weight 2
    
    
    $w.zinc add text 1 -position {20 8} -alignment center -text {This static example reproduces figure 11-3
of "The OpenGL Programming Guide 3rd Edition" V 1.2}
    
    variable group [$w.zinc add group 1]
    
    variable g1 [$w.zinc add group $group]
    variable curve1 [$w.zinc add curve $g1 {}]
    $w.zinc contour $curve1 add +1 { 0 0 0 120 120 120 120 0 0 0}
    $w.zinc contour $curve1 add +1 { 20 20 20 100 100 100 100 20 20 20}
    $w.zinc contour $curve1 add +1 { 40 40 40 80 80 80 80 40 40 40}
    $w.zinc translate $g1 100 100
    
    
    variable g2 [$w.zinc add group $group]
    variable curve2 [$w.zinc add curve $g2 {}]
    $w.zinc contour $curve2 add +1 { 0 0 0 120 120 120 120 0 0 0}
    $w.zinc contour $curve2 add -1 { 20 20 20 100 100 100 100 20 20 20}
    $w.zinc contour $curve2 add -1 { 40 40 40 80 80 80 80 40 40 40}
    $w.zinc translate $g2 260 100
    
    
    variable g3 [$w.zinc add group $group]
    variable curve3 [$w.zinc add curve $g3 {}]
    $w.zinc contour $curve3 add +1 { 20 0 20 120 100 120 100 0 20 0}
    $w.zinc contour $curve3 add +1 { 40 20 60 140 80 20 40 20}
    $w.zinc contour $curve3 add +1 { 0 60 0 80 120 80 120 60 0 60}
    $w.zinc translate $g3 420 100
    
    variable g4 [$w.zinc add group $group]
    variable curve4 [$w.zinc add curve $g4 {}]
    $w.zinc contour $curve4 add +1 { 0 0 0 140 140 140 140 60 60 60 60 80 80 80 80 40 40 40 40 100 100 100 100 20 20 20 20 120 120 120 120 0 0 0}
    $w.zinc translate $g4 580 100
    
    $w.zinc scale $group 0.6 0.6
    $w.zinc translate $group 80 40
    
    variable t [$w.zinc add text $group -underlined yes -text "Contours"]
    $w.zinc translate $t 280 30
    set t [$w.zinc add text $group -underlined yes -text "-fillrule"]
    $w.zinc translate $t -110 30
    variable dy 0
    foreach fillrule {odd nonzero positive negative abs_geq_2} {
	set dy [expr $dy + 160]
	set t [$w.zinc add text $group -text $fillrule]
	$w.zinc translate $t -110 [expr 100+$dy]
	foreach item "$curve1 $curve2 $curve3 $curve4" {
	    set clone [$w.zinc clone $item -fillrule $fillrule -filled 1 -linewidth 0]
	    $w.zinc translate $clone 0 $dy
	}
    }
    
    # creating simple lines with arrows under each curves
    foreach item "$curve1 $curve2 $curve3 $curve4" {
	set contour_number [$w.zinc contour $item]
	#puts "$item contour_number=$contour_number\n"
	for {set n 0} {$n <=[expr $contour_number-1]} {incr n} {
	    set points [$w.zinc coords $item $n]
	    set nbpoints [llength $points]
	    for {set i 0} {$i <=[expr $nbpoints-2]} {incr i} {
		set firstpoint [lindex $points $i]
		set lastpoint [lindex $points [expr $i+1]]
		set middlepoint "[expr [lindex $firstpoint 0]+([lindex $lastpoint 0]- [lindex $firstpoint 0])/1.5] [expr [lindex $firstpoint 1]+([lindex $lastpoint 1]-[lindex $firstpoint 1])/1.5]"
		$w.zinc add curve [$w.zinc group $item] "$firstpoint $middlepoint" -lastend "7 10 4"
	    }
	}
    }
}
