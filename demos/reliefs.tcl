# $Id$
# this simple demo has been developped by P.Lecoanet <lecoanet@cena.fr>

if {![info exists zincDemo]} {
    error "This script should be run from the zinc-widget demo."
}

namespace eval reliefDemo {
    variable w .reliefs
    catch {destroy $w}
    toplevel $w
    wm title $w "Zinc Relief Testbed"
    wm iconname $w reliefs

    variable allReliefs {flat raised sunken groove ridge \
			roundraised roundsunken roundgroove roundridge \
			sunkenrule raisedrule}

    variable defaultfont [font create -family Helvetica -size 14 -weight normal]

    grid [button $w.dismiss -text Dismiss -command "destroy $w"] -row 2 -column 0 -pady 10
    grid [button $w.code -text "See Code" -command "showCode $w"] -row 2 -column 1 -pady 10


    ###########################################
    # Text zone
    #######################
    ####################

    grid [text $w.text -relief sunken -borderwidth 2 -height 8 -width 50] \
	-row 0 -column 0 -columnspan 2 -sticky ew

    $w.text insert end {  This demo lets you play with the various relief parameters
	on rectangles polygons and arcs. Some reliefs and The smooth relief
	capability is only available with openGL.
	You can modify the items with your mouse:

	Drag-Button 1 for moving    Ctrl/Shft-Button 1 for Incr/Decr sides
	Drag-Button 2 for zooming   Ctrl/Shft-Button 2 for cycling reliefs
	Drag-Button 3 for rotating  Ctrl/Shft-Button 3 for Incr/Decr border}


    ###########################################
    # Zinc
    ##########################################
    proc deg2Rad {deg} {
	return [expr 3.14159 * $deg / 180.0]
    }

    proc rad2Deg {rad} {
	return [expr int(fmod(($rad * 180.0 / 3.14159)+360.0, 360.0))]
    }

    variable bw 4
    variable width 60
    variable lightAngle 120
    variable lightAngleRad [deg2Rad $lightAngle]
    variable zincSize 500

    grid [zinc $w.zinc -width $zincSize -height $zincSize -render 1 -font 10x20 \
	-highlightthickness 0 -borderwidth 0 -relief sunken -backcolor lightgray \
	-lightangle $lightAngle] -row 1 -column 0 -columnspan 2 -sticky news
    grid columnconfigure $w 0 -weight 1
    grid columnconfigure $w 1 -weight 1
    grid rowconfigure $w 1 -weight 2

    variable topGroup [$w.zinc add group 1]

    proc polyPoints { ox oy rad n } {
	set step [expr 2 * 3.14159 / $n]
	for {set i 0} {$i < $n} {incr i} {
	    set x [expr $ox + ($rad * cos($i * $step))];
	    set y [expr $oy + ($rad * sin($i * $step))];
	    lappend coords $x $y;
	}
	lappend coords [lindex $coords 0] [lindex $coords 1]
	return $coords
    }

    proc makePoly {x y bw sides color group} {
	variable w
	variable state
	variable allReliefs
	variable width

	set relief 2

	set g [$w.zinc add group $group]
	$w.zinc translate $g $x $y
	$w.zinc add curve $g [polyPoints 0 0 $width $sides] \
	    -relief [lindex $allReliefs $relief] -linewidth $bw \
	    -smoothrelief 1 -fillcolor $color -linecolor $color \
	    -filled t -tags {subject polygon}
	$w.zinc add text $g -anchor center \
	    -text [lindex $allReliefs $relief] -tags {subject relief}
	$w.zinc add text $g -anchor center -position {0 16} \
	    -text $bw -tags {subject bw}
	set state($g,sides) $sides
	set state($g,relief) $relief
	set state($g,bw) $bw
	return $g
    }

    variable poly [makePoly 100 100 $bw 8 lightblue $topGroup]
    variable poly [makePoly [expr 100 + 2*($width + 10)] 100 $bw 8 tan $topGroup]
    variable poly [makePoly [expr 100 + 4*($width + 10) ] 100 $bw 8 slateblue $topGroup]

    proc lightCenter {radius angle} {
	return [list [expr $radius * (1 + 0.95*cos($angle))] \
		    [expr $radius * (1 - 0.95*sin($angle))]]
    }

    #
    # Place the light at lightAngle on the circle
    $w.zinc add arc 1 {-5 -5 5 5} -filled 1 -fillcolor yellow \
	-tags light -priority 10
    eval "$w.zinc translate light [lightCenter [expr $zincSize/2] $lightAngleRad]"

    #
    # Controls.
    #
    $w.zinc bind subject <ButtonPress-1>  "::reliefDemo::press motion %x %y"
    $w.zinc bind subject <ButtonRelease-1>  ::reliefDemo::release
    $w.zinc bind subject <ButtonPress-2>  "::reliefDemo::press zoom %x %y"
    $w.zinc bind subject <ButtonRelease-2>  ::reliefDemo::release
    $w.zinc bind subject <ButtonPress-3>  "::reliefDemo::press mouseRotate %x %y"
    $w.zinc bind subject <ButtonRelease-3>  ::reliefDemo::release

    $w.zinc bind polygon <Shift-ButtonPress-1>  "::reliefDemo::incrPolySides 1"
    $w.zinc bind polygon <Control-ButtonPress-1>  "::reliefDemo::incrPolySides -1"

    $w.zinc bind subject <Shift-ButtonPress-2>  "::reliefDemo::cycleRelief 1"
    $w.zinc bind subject <Control-ButtonPress-2>  "::reliefDemo::cycleRelief -1"

    $w.zinc bind subject <Shift-ButtonPress-3>  "::reliefDemo::incrBW 1"
    $w.zinc bind subject <Control-ButtonPress-3>  "::reliefDemo::incrBW -1"

    $w.zinc bind light <ButtonPress-1>  "::reliefDemo::press lightMotion %x %y"
    $w.zinc bind light <ButtonRelease-1>  ::reliefDemo::release

    variable curX 0
    variable curY 0
    variable curAngle 0

    proc press {action x y} {
	variable w
	variable curAngle
	variable curX
	variable curY

	$w.zinc raise [$w.zinc group current]

	set curX $x
	set curY $y
	set curAngle [expr atan2($y, $x)]
	bind $w.zinc <Motion> "::reliefDemo::$action %x %y"
    }

    proc motion {x y} {
	variable w
	variable curX
	variable curY
	variable topGroup

	foreach {x1 y1 x2 y2} [$w.zinc transform $topGroup \
				   [list $x $y $curX $curY]] break
	$w.zinc translate [$w.zinc group current] [expr $x1 - $x2] [expr $y1 - $y2]
	set curX $x
	set curY $y
    }

    proc lightMotion {x y} {
	variable w
	variable zincSize
	variable topGroup

	set radius [expr $zincSize/2]
	if { $x < 0 } {
	    set x 0
	} elseif { $x > $zincSize } {
	    set x $zincSize
	}
	
	set angle [expr acos(double($x-$radius)/$radius)]
	if { $y > $radius } {
	    set angle [expr - $angle]
	}
	$w.zinc treset light
	eval "$w.zinc translate light [lightCenter [expr $zincSize/2] $angle]"
	$w.zinc configure -lightangle [rad2Deg $angle]
    }

    proc zoom {x y} {
	variable w
	variable curX
	variable curY

	if {$x > $curX} {
	    set maxX $x
	} else {
	    set maxX $curX
	}
	if {$y > $curY} {
	    set maxY $y
	} else {
	    set maxY $curY
	}
	if {($maxX == 0) || ($maxY == 0)} {
	    return;
	}
	set sx [expr 1.0 + (double($x - $curX) / $maxX)]
	set sy [expr 1.0 + (double($y - $curY) / $maxY)]
	$w.zinc scale current $sx $sx

	set curX $x
	set curY $y
    }

    proc mouseRotate {x y} {
	variable w
	variable curAngle

	set lAngle [expr atan2($y, $x)]
	$w.zinc rotate current [expr $lAngle - $curAngle]
	set curAngle  $lAngle
    }

    proc release {} {
	variable w

	bind $w.zinc <Motion> {}
    }

    proc incrPolySides {incr} {
	variable w
	variable state
	variable width

	set g [$w.zinc group current]
	incr state($g,sides) $incr
	if { $state($g,sides) < 3 } {
	    set state($g,sides) 3
	}

	set points [polyPoints 0 0 $width $state($g,sides)]
	$w.zinc coords $g.polygon $points
    }

    proc cycleRelief {incr} {
	variable w
	variable state
	variable allReliefs

	set g [$w.zinc group current]
	incr state($g,relief) $incr
	if { $state($g,relief) < 0 } {
	    set state($g,relief) [expr [llength $allReliefs] - 1]
	} elseif { $state($g,relief) >= [llength $allReliefs] } {
	    set state($g,relief) 0
	}
	set rlf [lindex $allReliefs $state($g,relief)]
	$w.zinc itemconfigure $g.polygon -relief $rlf
	$w.zinc itemconfigure $g.relief -text $rlf
    }

    proc incrBW {incr} {
	variable w
	variable state

	set g [$w.zinc group current]
	incr state($g,bw) $incr
	if { $state($g,bw) < 0 } {
	    set state($g,bw) 0
	}
	$w.zinc itemconfigure $g.polygon -linewidth $state($g,bw)
	$w.zinc itemconfigure $g.bw -text $state($g,bw)
    }
}
