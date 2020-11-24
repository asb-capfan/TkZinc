# $Id$
# this simple demo has been developped by C. Mertz <mertz@cena.fr>
# Ported to Tcl by P.Lecoanet

if {![info exists zincDemo]} {
    error "This script should be run from the zinc-widget demo."
}


namespace eval iconTransform {
    variable w .iconTransform
    catch {destroy $w}
    toplevel $w
    wm title $w "Zinc icon scale/rotate Demonstration"
    wm iconname $w iconTransform

    variable defaultfont [font create -family Helvetica -size 16 -weight normal]

    grid [button $w.dismiss -text Dismiss -command "destroy $w"] -row 2 -column 0 -pady 10
    grid [button $w.code -text "See Code" -command "showCode $w"] -row 2 -column 1 -pady 10


    ###########################################
    # Text zone
    #######################
    ####################

    grid [text $w.text -relief sunken -borderwidth 2 -height 6] \
	-row 0 -column 0 -columnspan 2 -sticky ew

    $w.text insert end {You can transform this image with your mouse:
	Drag-Button 1 for moving,
	Drag-Button 2 for zooming,
	Drag-Button 3 for rotating,
	Shift-Drag-Button 1 for modifying the transparency (OpenGL only).}


    ###########################################
    # Zinc
    ##########################################
    grid [zinc $w.zinc -width 350 -height 250 -render 1 -font $defaultfont \
	-borderwidth 3 -relief sunken] -row 1 -column 0 -columnspan 2 -sticky news
    grid columnconfigure $w 0 -weight 1
    grid columnconfigure $w 1 -weight 1
    grid rowconfigure $w 1 -weight 2

    variable topGroup [$w.zinc add group 1]

    image create photo zincAA -file [file join $::zinc_demos images zinc.gif]

    variable zincAA [$w.zinc add icon $topGroup -image zincAA \
			 -position {10 10} -composescale 1 -composerotation 1]

    $w.zinc add text $topGroup \
	-text "try to zoom/resize the banner!\nNow works also without openGL ;-)" \
        -color white -composescale 1 -composerotation 1 -position {15 100}

    #
    # Controls for the window transform.
    #
    bind $w.zinc <ButtonPress-1>  "::iconTransform::press motion %x %y"
    bind $w.zinc <ButtonRelease-1>  ::iconTransform::release
    bind $w.zinc <ButtonPress-2>  "::iconTransform::press zoom %x %y"
    bind $w.zinc <ButtonRelease-2>  ::iconTransform::release
    bind $w.zinc <ButtonPress-3>  "::iconTransform::press mouseRotate %x %y"
    bind $w.zinc <ButtonRelease-3>  ::iconTransform::release

    #
    # Controls for alpha and gradient
    #
    bind $w.zinc <Shift-ButtonPress-1> "::iconTransform::press modifyAlpha %x %y"
    bind $w.zinc <Shift-ButtonRelease-1> ::iconTransform::release


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
	bind $w.zinc <Motion> "::iconTransform::$action %x %y"
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
	variable topGroup

	set lAngle [expr atan2($y, $x)]
	$w.zinc rotate $topGroup [expr -($lAngle - $curAngle)]
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
}
