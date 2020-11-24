#
# $Id$
# this simple demo has been adapted by C. Mertz <mertz@cena.fr> from the original
# work of JL. Vinot <vinot@cena.fr>
# Ported to Tcl by P.Lecoanet

if {![info exists zincDemo]} {
    error "This script should be run from the zinc-widget demo."
}

namespace eval tkZincLogo {
    #
    # We need the zincLogo support
    package require zincLogo


    variable w .tkZincLogo
    catch {destroy $w}
    toplevel $w
    wm title $w "Zinc logo Demonstration"
    wm iconname $w tkZincLogo

    grid [button $w.dismiss -text Dismiss -command "destroy $w"] -row 2 -column 0 -pady 10
    grid [button $w.code -text "See Code" -command "showCode $w"] -row 2 -column 1 -pady 10
 

    ###########################################
    # Text zone
    #######################
    ####################

    grid [text $w.text -relief sunken -borderwidth 2 -height 7] \
	-row 0 -column 0 -columnspan 2 -sticky ew

    $w.text insert end {This tkZinc logo should used openGL for a correct rendering!
	You can transform this logo with your mouse:
	Drag-Button 1 for moving the logo,
	Drag-Button 2 for zooming the logo,
	Drag-Button 3 for rotating the logo,
	Shift-Drag-Button 1 for modifying the logo transparency,
	Shift-Drag-Button 2 for modifying the logo gradient.}


    ###########################################
    # Zinc
    ##########################################
    grid [ zinc $w.zinc -width 350 -height 250 -render 1 \
	-borderwidth 3 -relief sunken] -row 1 -column 0 -columnspan 2 -sticky news
    grid columnconfigure $w 0 -weight 1
    grid columnconfigure $w 1 -weight 1
    grid rowconfigure $w 1 -weight 2

    variable topGroup [$w.zinc add group 1]

    variable logo [zincLogo::create $w.zinc $topGroup 800 40 70 0.6 0.6]

    #
    # Controls for the window transform.
    #
    bind $w.zinc <ButtonPress-1>  "::tkZincLogo::press motion %x %y"
    bind $w.zinc <ButtonRelease-1>  ::tkZincLogo::release
    bind $w.zinc <ButtonPress-2>  "::tkZincLogo::press zoom %x %y"
    bind $w.zinc <ButtonRelease-2>  ::tkZincLogo::release
    bind $w.zinc <ButtonPress-3> "::tkZincLogo::press mouseRotate %x %y"
    bind $w.zinc <ButtonRelease-3> ::tkZincLogo::release

    #
    # Controls for alpha and gradient
    #
    bind $w.zinc <Shift-ButtonPress-1> "::tkZincLogo::press modifyAlpha %x %y"
    bind $w.zinc <Shift-ButtonRelease-1> ::tkZincLogo::release
    bind $w.zinc <Shift-ButtonPress-2> "::tkZincLogo::press modifyGradient %x %y"
    bind $w.zinc <Shift-ButtonRelease-2> ::tkZincLogo::release


    variable curX 0
    variable curY 0
    variable curAngle 0

    proc press {action x y} {
	variable w
	variable curAngle
	variable curX
	variable curY

	set curX $x
	set curY $y
	set curAngle [expr atan2($y, $x)]
	bind $w.zinc <Motion> "::tkZincLogo::$action %x %y"
    }

    proc motion {x y} {
	variable w
	variable topGroup
	variable curX
	variable curY

	foreach {x1 y1 x2 y2} [$w.zinc transform $topGroup \
				   [list $x $y $curX $curY]] break
	$w.zinc translate $topGroup [expr $x1 - $x2] [expr $y1 - $y2]
	set curX $x
	set curY $y
    }

    proc zoom {x y} {
	variable w
	variable topGroup
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
	$w.zinc scale $topGroup $sx $sx

	set curX $x
	set curY $y
    }

    proc mouseRotate {x y} {
	variable w
	variable curAngle
	variable logo

	set lAngle [expr atan2($y, $x)]
	$w.zinc rotate $logo [expr $lAngle - $curAngle]
	set curAngle  $lAngle
    }

    proc release {} {
	variable w

	bind $w.zinc <Motion> {}
    }

    proc modifyAlpha {x y} {
	variable w
	variable topGroup

	set xRate [expr double($x) / [$w.zinc cget -width]]
	set xRate [expr ($xRate < 0) ? 0 : ($xRate > 1) ? 1 : $xRate]
	set alpha [expr int($xRate * 100)]

	$w.zinc itemconfigure $topGroup -alpha $alpha
    }

    proc modifyGradient {x y} {
	variable w

	set yRate [expr double($y) / [$w.zinc cget -height]]
	set yRate [expr ($yRate < 0) ? 0 : ($yRate > 1) ? 1 : $yRate]
	set gradPercent [expr int($yRate * 100)]
	
	$w.zinc itemconfigure letters -fillcolor "=axial 270|#ffffff;100 0 28|#66848c;100 $gradPercent|#7192aa;100 100"
    }
}
