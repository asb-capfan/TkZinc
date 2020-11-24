# these simple samples have been developped by C. Mertz mertz@cena.fr in perl
# tcl version by Jean-Paul Imbert imbert@cena.fr

if {![info exists zincDemo]} {
    error "This script should be run from the zinc-widget demo."
}


namespace eval curveBezier {
    variable w .curveBezier
    catch {destroy $w}
    toplevel $w
    wm title $w "Zinc Curve Bezier Demonstration"
    wm iconname $w Curve

    variable defaultfont [font create -family Helvetica -size 14 -weight normal]
    #variable imagePath [file join $zinc_library demos images]
    #variable texture [image create photo -file [file join $imagePath paper-grey1.gif]]
    variable splineColor \#AA0000
    variable handleColor grey70
    variable barColor grey30
    variable textColor grey20

    grid [button $w.dismiss -text Dismiss -command "destroy $w"] -row 2 -column 0 -pady 10
    grid [button $w.code -text "See Code" -command "showCode $w"] -row 2 -column 1 -pady 10


    grid [text $w.text -relief sunken -borderwidth 2 -setgrid true -height 3] \
	-row 0 -column 0 -columnspan 2 -sticky ew

    $w.text insert 0.0 {
	6 examples of curves containing control points are displayed 
	with the list of control points written just below.
	You can move the handles to modify the bezier curves
    }

    grid [zinc $w.zinc -width 700 -height 650 -font $defaultfont -borderwidth 0 \
	      -backcolor \#898A8F] -row 1 -column 0 -columnspan 2 -sticky news
    grid columnconfigure $w 0 -weight 1
    grid columnconfigure $w 1 -weight 1
    grid rowconfigure $w 1 -weight 2

    variable group [$w.zinc add group 1]

    $w.zinc add text $group -position {50 20} -anchor w -color $textColor \
	-text {Examples of curve items using cubic bezier control points}

    ## Please note: much of the items below could be computed
    $w.zinc add text $group -anchor w -position {25 270} -tags bezier1 -color $textColor -width 270
    $w.zinc add curve $group {100 200 100 100} -tags {line1 l1-2} \
	-linecolor $barColor -filled 0 -linewidth 2
    $w.zinc add curve $group {400 100 400 200} -tags {line1 l3-4} \
	-linecolor $barColor -filled 0 -linewidth 2
    $w.zinc add curve $group {{100 200} {100 100 c} {400 100 c} {400 200}} \
	-tags bezier1 -closed 0 -linecolor $splineColor -linewidth 5
    $w.zinc add arc $group {90 190 110 210} -tags {handle1 p1} -filled 1 \
	-fillcolor \#BBBBBB
    $w.zinc add arc $group {90 90 110 110} -tags {handle1 p2} -filled 1 \
	-linewidth 0 -fillcolor $handleColor -filled 1
    $w.zinc add arc $group {390 90 410 110} -tags {handle1 p3} -filled 1 \
	-linewidth 0 -fillcolor $handleColor -filled 1
    $w.zinc add arc $group {390 190 410 210} -tags {handle1 p4} -filled 1 \
	-fillcolor \#BBBBBB

    $w.zinc add text $group -anchor w -position {570 270} -tags bezier2 -color $textColor -width 270
    $w.zinc add curve $group {600 200 675 100} -tags {line2 l1-2} \
	-linecolor $barColor -linewidth 2
    $w.zinc add curve $group {975 100 900 200} -tags {line2 l3-4} \
	-linecolor $barColor -linewidth 2
    $w.zinc add curve $group {{600 200} {675 100 c} {975 100 c} {900 200}} \
	-tags bezier2 -closed 0 -linecolor $splineColor -linewidth 5
    $w.zinc add arc $group {590 190 610 210} -tags {handle2 p1} -filled 1 \
	-fillcolor $handleColor
    $w.zinc add arc $group {665 90 685 110} -tags {handle2 p2} -filled 1 \
	-linewidth 0 -fillcolor $handleColor
    $w.zinc add arc $group {965 90 985 110} -tags {handle2 p3} -filled 1 \
	-linewidth 0 -fillcolor $handleColor
    $w.zinc add arc $group {890 190 910 210} -tags {handle2 p4} -filled 1 \
	-fillcolor $handleColor

    $w.zinc add text $group -anchor w -position {25 570} -tags bezier3 -color $textColor -width 270
    $w.zinc add curve $group {100 500 25 400} -tags {line3 l1-2} \
	-linecolor $barColor -linewidth 2
    $w.zinc add curve $group {475 400 400 500} -tags {line3 l3-4} \
	-linecolor $barColor -linewidth 2
    $w.zinc add curve $group {{100 500} {25 400 c} {475 400 c} {400 500}} \
	-tags {bezier3} -closed 0 -linecolor $splineColor -linewidth 5
    $w.zinc add arc $group {90 490 110 510} -tags {handle3 p1} -filled 1 \
	-fillcolor $handleColor
    $w.zinc add arc $group {15 390 35 410} -tags {handle3 p2} -filled 1 \
	-linewidth 0 -fillcolor $handleColor 
    $w.zinc add arc $group {465 390 485 410} -tags {handle3 p3} -filled 1 \
	-linewidth 0 -fillcolor $handleColor 
    $w.zinc add arc $group {390 490 410 510} -tags {handle3 p4} -filled 1 \
	-fillcolor $handleColor

    $w.zinc add text $group -anchor w -position {570 570} -tags bezier4 -color $textColor -width 270
    $w.zinc add curve $group {600 500 600 350} -tags {line4 l1-2} \
	-linecolor $barColor -linewidth 2
    $w.zinc add curve $group {900 650 900 500} -tags {line4 l3-4} \
	-linecolor $barColor -linewidth 2
    $w.zinc add curve $group {{600 500} {600 350 c} {900 650 c} {900 500}} \
	-tags {bezier4} -closed 0 -linecolor $splineColor -linewidth 5
    $w.zinc add arc $group {590 490 610 510} -tags {handle4 p1} -filled 1 \
	-fillcolor $handleColor
    $w.zinc add arc $group {590 340 610 360} -tags {handle4 p2} -filled 1 \
	-linewidth 0 -fillcolor $handleColor
    $w.zinc add arc $group {890 640 910 660} -tags {handle4 p3} -filled 1 \
	-linewidth 0 -fillcolor $handleColor
    $w.zinc add arc $group {890 490 910 510} -tags {handle4 p4} -filled 1 \
	-fillcolor $handleColor

    $w.zinc add text $group -anchor w -position {25 870} -tags bezier5 -color $textColor -width 270
    $w.zinc add curve $group {100 800 175 700} -tags {line5 l1-2} \
	-linecolor $barColor -filled 0 -linewidth 2
    $w.zinc add curve $group {325 700 400 800} -tags {line5 l3-4} \
	-linecolor $barColor -filled 0 -linewidth 2
    $w.zinc add curve $group {{100 800} {175 700 c} {325 700 c} {400 800}} \
	-tags {bezier5} -closed 0 -linecolor $splineColor -linewidth 5
    $w.zinc add arc $group {90 790 110 810} -tags {handle5 p1} -filled 1 \
	-fillcolor $handleColor
    $w.zinc add arc $group {165 690 185 710} -tags {handle5 p2} -filled 1 \
	-linewidth 0 -fillcolor $handleColor -filled 1
    $w.zinc add arc $group {315 690 335 710} -tags {handle5 p3} -filled 1 \
	-linewidth 0 -fillcolor $handleColor -filled 1
    $w.zinc add arc $group {390 790 410 810} -tags {handle5 p4} -filled 1 \
	-fillcolor $handleColor

    $w.zinc add text $group -anchor w -position {570 970} -tags bezier6 -color $textColor -width 280
    $w.zinc add curve $group {600 800 625 700} -tags {line6 l1-2} \
	-linecolor $barColor -linewidth 2
    $w.zinc add curve $group {725 700 750 800} -tags {line6 l3-4} \
	-linecolor $barColor -linewidth 2
    $w.zinc add curve $group {750 800 775 900} -tags {line6 l4-5} \
	-linecolor $barColor -linewidth 2
    $w.zinc add curve $group {875 900 900 800} -tags {line6 l6-7} \
	-linecolor $barColor -linewidth 2
    $w.zinc add curve $group {
	{600 800} {625 700 c} {725 700 c} {750 800}
	{775 900 c} {875 900 c} {900 800}
    } -tags {bezier6} -filled 0 -closed 0 -linecolor $splineColor -linewidth 5
    $w.zinc add arc $group {590 790 610 810} -tags {handle6 p1} -filled 1 \
	-fillcolor $handleColor
    $w.zinc add arc $group {615 690 635 710} -tags {handle6 p2} -filled 1 \
	-linewidth 0 -fillcolor $handleColor
    $w.zinc add arc $group {715 690 735 710} -tags {handle6 p3} -filled 1 \
	-linewidth 0 -fillcolor $handleColor
    $w.zinc add arc $group {740 790 760 810} -tags {handle6 p4} -filled 1 \
	-linecolor blue -fillcolor blue -linewidth 2
    $w.zinc add arc $group {766 891 784 909} -tags {handle6 p5} -filled 1 \
	-fillcolor $handleColor
    $w.zinc add arc $group {865 890 885 910} -tags {handle6 p6} -filled 1 \
	-linewidth 0 -fillcolor $handleColor
    $w.zinc add arc $group {890 790 910 810} -tags {handle6 p7} -filled 1 \
	-fillcolor $handleColor


    $w.zinc scale $group 0.6 0.6

    ## Set the text of the text item with a tag "tag"
    ## to a human-readable form of the coords of the
    ## corresponding curve with the same tag "tag"
    proc setText {tag} {
	variable w
	set textItem  [$w.zinc find withtype text $tag]
	set curveItem [$w.zinc find withtype curve $tag]
	set coords [$w.zinc coords $curveItem]
	set count 0
	$w.zinc itemconfigure $textItem -text $coords
    }

    foreach bezierCount {1 2 3 4 5 6} {
	setText "bezier$bezierCount"
	set curveItem [$w.zinc find withtype curve "bezier$bezierCount"]
	set coords [$w.zinc coords $curveItem]
	#puts "$bezierCount : $curveItem : $coords"
	$w.zinc bind "handle$bezierCount" <1> {::curveBezier::itemStartDrag %x %y}
	$w.zinc bind "handle$bezierCount" <B1-Motion> {::curveBezier::itemDrag %x %y}
	#$w.zinc bind "handle$bezierCount" "<ButtonPress-1>" {\&press \&motion}
	#$w.zinc bind "handle$bezierCount" "<ButtonRelease-1>" {\&release}
    }




    ##### bindings for moving the handles
    variable item ""
    variable bezierNum "" 
    variable ptNum ""

    variable xOrig 0
    variable yOrig 0

    proc itemStartDrag {x y} {
	variable w
	variable xOrig
	variable yOrig
	variable bezierNum
	variable ptNum
	variable item

	set xOrig $x
	set yOrig $y
	set item [$w.zinc find withtag current]
	
	foreach val [$w.zinc gettags $item] {
	    regexp {([a-z]+)(\d)} $val "" name num
	    if {$name=="handle"} {set bezierNum $num}
	    if {$name=="p"} {set ptNum $num}
	}
	#puts "bezierNum=$bezierNum ptNum=$ptNum"
    }

    # Callback for moving an item
    proc itemDrag {x y} {
	variable xOrig
	variable yOrig
	variable w
	variable item

	$w.zinc transform $item "[expr $x - $xOrig] [expr $y - $yOrig]"
	moveHandle [expr $x - $xOrig] [expr $y - $yOrig]
	set xOrig $x
	set yOrig $y
    }


    proc moveHandle {dx dy} {
	variable w
	variable bezierNum
	variable ptNum
	variable item

	set pt1 [lindex [$w.zinc coords $item] 0]
	set pt2 [lindex [$w.zinc coords $item] 1]
	
	## modifying the handle coords
	$w.zinc coords $item "[expr [lindex $pt1 0]+$dx] [expr [lindex $pt1 1]+$dy] [expr [lindex $pt2 0]+$dx] [expr [lindex $pt2 1]+$dy]"
	set prevPtNum [expr $ptNum-1]
	
	# there should only be one such item!
	set lineA [$w.zinc find withtag "line$bezierNum && l$prevPtNum-$ptNum"]
	if {$lineA!=""} {
	    set x [lindex [$w.zinc coords $lineA 0 1] 0]
	    set y [lindex [$w.zinc coords $lineA 0 1] 1]
	    $w.zinc coords $lineA 0 1 "[expr $x+$dx] [expr $y+$dy]"
	}
	
	set nextPtNum [expr $ptNum+1]
	# there should only be one such item:
	set lineB [$w.zinc find withtag "line$bezierNum && l$ptNum-$nextPtNum"]
	if {$lineB!=""} {
	    set x [lindex [$w.zinc coords $lineB 0 0] 0]
	    set y [lindex [$w.zinc coords $lineB 0 0] 1]
	    $w.zinc coords $lineB 0 0 "[expr $x+$dx] [expr $y+$dy]"
	}
	set tab [$w.zinc coords "bezier$bezierNum" 0 [expr $ptNum-1]]
	set x [lindex $tab 0]
	set y [lindex $tab 1]
	set control [lindex $tab 2]
	$w.zinc coords "bezier$bezierNum" 0 [expr $ptNum-1] "[expr $x+$dx] [expr $y+$dy] $control"
	setText "bezier$bezierNum"  
    }
}

