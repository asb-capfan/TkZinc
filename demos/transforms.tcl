# $Id$
# This simple demo has been developped by P. Lecoanet <lecoanet@cena.fr>

#
# TODO:
#
# Add the building of missing items
#

if {![info exists zincDemo]} {
    error "This script should be run from the zinc-widget demo."
}

namespace eval transforms {
    variable w .transforms
    catch {destroy $w}
    toplevel $w
    wm title $w "Zinc Transformation Demonstration"
    wm iconname $w Transformation

    variable defaultfont [font create -family Helvetica -size 14 -weight normal]

    grid [button $w.dismiss -text Dismiss -command "destroy $w"] -row 3 -column 0 -pady 10
    grid [button $w.code -text "See Code" -command "showCode $w"] -row 3 -column 1 -pady 10


    ###########################################
    # Text zone
    ###########################################
    grid [text $w.text -relief sunken -borderwidth 2 -setgrid true -height 12] \
	-row 0 -column 0 -columnspan 2 -sticky ew

    $w.text insert 0.0 {Items are always added to the current group.
	The available commands are:
	Button 1         on the background, add an item with initial translation
	Button 2         on the background, add a group with initial translation
	Button 1         on item/group axes, select/deselect that item coordinates
	Drag Button 1    on item/group axes, translate that item coordinates
	Home             reset the transformation
	Shift-Home       reset a group direct children transformations
	+/-              scale the selected item up/down
	Ctrl-Left/Right  rotate the selected item right/left
	Shift-Up/Down    swap the selected item Y axis
	Shift-Left/Right swap the selected item X axis
	4 arrows         translate in the 4 directions
	Delete           destroy the selected item}
    $w.text configure -state disabled

    ###########################################
    # Zinc
    ###########################################
    variable zincWidth 600
    variable zincHeight 500

    grid [zinc $w.zinc -width $zincWidth -height $zincHeight \
	-font $defaultfont -borderwidth 3 -relief sunken -takefocus 1 -render 0] \
	-row 1 -column 0 -columnspan 2 -sticky news
    grid columnconfigure $w 0 -weight 1
    grid columnconfigure $w 1 -weight 1
    grid rowconfigure $w 1 -weight 2

    variable top 1

    variable inactiveAxisColor blue
    variable activeAxisColor red
    variable worldAxisColor \#a5a5a5

    variable composeRot 1
    variable composeScale 1
    variable drag 0
    variable itemType Rectangle
    variable currentItem 0

    image create photo logo -file [file join $::zinc_demos images zinc.gif]

    grid [frame $w.f] -row 2 -column 0 -columnspan 2 -sticky w

    tk_optionMenu $w.f.types itemType Rectangle Arc Curve Icon Tabular \
	Text Track Triangles WayPoint
    grid $w.f.types -row 0 -column 1 -sticky w

    button $w.f.add -text {Add item} -command "::transforms::addItem $w.zinc"
    grid $w.f.add -row 0 -column 2 -padx 10 -sticky ew

    button $w.f.addg -text {Add group} -command "::transforms::addGroup $w.zinc"
    grid $w.f.addg -row 0 -column 3 -padx 10 -sticky ew

    button $w.f.remove -text Remove -command "::transforms::removeItem $w.zinc"
    grid $w.f.remove -row 0 -column 4 -padx 10 -sticky ew

    checkbutton $w.f.cscale -text -composescale -command "::transforms::toggleComposeScale $w.zinc" \
	-variable ::transforms::composeScale
    grid $w.f.cscale -row 0 -column 6 -sticky w

    checkbutton $w.f.crot -text -composesrotation -command "::transforms::toggleComposeRot $w.zinc" \
	-variable ::transforms::composeRot
    grid $w.f.crot -row 1 -column 6 -sticky w


    variable world [$w.zinc add group $top]
    variable currentGroup $world
    $w.zinc add curve $top {0 0 80 0} -linewidth 3 \
	-linecolor $worldAxisColor -lastend {6 8 3} -tags axis:$world
    $w.zinc add curve $top {0 0 0 80} -linewidth 3 \
	-linecolor $worldAxisColor -lastend {6 8 3} -tags axis:$world
    $w.zinc add rectangle $top {-2 -2 2 2} -filled 1 \
	-fillcolor $worldAxisColor -linecolor $worldAxisColor \
	-linewidth 3 -tags axis:$world
    $w.zinc add text $top -text "This is the origin\nof the world" \
	-anchor s -color $worldAxisColor -alignment center \
	-tags [list "axis:$world" text]
    $w.zinc lower axis:$world

    bind $w.zinc <1> {::transforms::mouseAdd %W Item %x %y}
    bind $w.zinc <2> {::transforms::mouseAdd %W Group %x %y}
    bind $w.zinc <Up> {::transforms::moveUp %W}
    bind $w.zinc <Left> {::transforms::moveLeft %W}
    bind $w.zinc <Right> {::transforms::moveRight %W}
    bind $w.zinc <Down> {::transforms::moveDown %W}
    bind $w.zinc <minus> {::transforms::scaleDown %W}
    bind $w.zinc <KP_Subtract> {::transforms::scaleDown %W}
    bind $w.zinc <plus> {::transforms::scaleUp %W}
    bind $w.zinc <KP_Add> {::transforms::scaleUp %W}
    bind $w.zinc <Home> {::transforms::reset %W}
    bind $w.zinc <Shift-Home> {::transforms::resetChildren %W}
    bind $w.zinc <Control-Left> {::transforms::rotateLeft %W}
    bind $w.zinc <Control-Right> {::transforms::rotateRight %W}
    bind $w.zinc <Shift-Up> {::transforms::swapAxis %W y}
    bind $w.zinc <Shift-Down> {::transforms::swapAxis %W y}
    bind $w.zinc <Shift-Left> {::transforms::swapAxis %W x}
    bind $w.zinc <Shift-Right> {::transforms::swapAxis %W x}
    bind $w.zinc <Delete> {::transforms::removeItem %W}

    bind $w.zinc <Configure> {::transforms::resize %W %w %h}

    focus $w.zinc
    tk_focusFollowsMouse


    proc resize {z width height} {
	variable world

	set x [expr $width/2]
	set y [expr $height/2]
	
	$z treset $world
	$z treset axis:$world
	$z translate $world $x $y
	$z translate axis:$world $x $y
    }

    proc swapAxis {z axis} {
	variable currentItem

	set sx 1
	set sy 1
	if { $axis eq "x" } {
	    set sx -1
	} elseif { $axis eq "y" } {
	    set sy -1
	}
	if {$currentItem != 0} {
	    $z scale $currentItem $sx $sy
	    $z scale axisgrp:$currentItem $sx $sy
	}
    }

    proc toggleComposeRot {z} {
	variable currentItem
	variable composeRot

	if {$currentItem != 0} {
	    $z itemconfigure $currentItem -composerotation $composeRot
	    $z itemconfigure axisgrp:$currentItem -composerotation $composeRot
	}
    }

    proc toggleComposeScale {z} {
	variable currentItem
	variable composeScale
	
	if {$currentItem != 0} {
	    $z itemconfigure $currentItem -composescale $composeScale
	    $z itemconfigure axisgrp:$currentItem -composescale $composeScale
	}
    }

    proc removeItem {z} { 
	variable currentGroup
	variable currentItem
	variable world
	
	if {$currentItem != 0} {
	    $z remove $currentItem axisgrp:$currentItem
	    if {$currentItem == $currentGroup} {
		set currentGroup $world
	    }
	    set currentItem 0
	    set composeScale 1
	    set composeRot 1
	}
    }

    proc dragItem {z x y} {
	variable drag
	variable currentItem

	set drag 1
	if {$currentItem == 0} {
	    return
	}
	
	set group [$z group $currentItem]
	foreach {x y} [$z transform $group [list $x $y]] break
	
	$z treset $currentItem
	$z treset axisgrp:$currentItem
	$z translate $currentItem $x $y
	$z translate axisgrp:$currentItem $x $y
    }

    proc select {z} {
	foreach t [$z gettags current] {
	    if {[regexp {^axis:(\d+)} $t m item]} {
		changeItem $z $item
	    }
	}
    }

    proc changeItem {z item} {
	variable currentItem
	variable currentGroup
	variable composeRot
	variable composeScale
	variable drag
	variable activeAxisColor
	variable inactiveAxisColor

	if {($currentItem != 0) && !$drag} {
	    $z itemconfigure axis:$currentItem&&!text \
		-linecolor $inactiveAxisColor -fillcolor $inactiveAxisColor
	}
	if {($currentItem == 0) || ($item != $currentItem)} {
	    $z itemconfigure axis:$item&&!text \
		-linecolor $activeAxisColor -fillcolor $activeAxisColor -linewidth 3
	    set currentItem $item
	    set composeRot [$z itemcget $currentItem -composerotation]
	    $z itemconfigure axisgrp:$currentItem -composerotation $composeRot
	    set composeScale [$z itemcget $currentItem -composescale]
	    $z itemconfigure axisgrp:$currentItem -composescale $composeScale
	} elseif {!$drag} {
	    set currentItem 0
	    set composeRot 1
	    set composeScale 1
	}
    }

    proc selectGroup {z} {
	foreach t [$z gettags current] {
	    if {[regexp {^axis:(\d+)} $t m item]} {
		changeGroup $z $item
		return
	    }
	}
    }

    proc changeGroup {z grp} {
	variable currentItem
	variable currentGroup
	variable world
	
	changeItem $z $grp
	if {$currentItem != 0} {
	    set currentGroup $currentItem
	} else {
	    set currentGroup $world
	}
    }

    proc reset {z } {
	variable currentItem

	if {$currentItem != 0} {
	    $z treset $currentItem
	    $z treset axisgrp:$currentItem
	}
    }

    proc resetChildren {z} {
	variable currentItem

	if {($currentItem != 0) && ([$z type $currentItem] == "group")} {
	    $z addtag rt withtag .$currentItem.
	    $z treset rt
	    $z dtag rt rt
	}
    }

    proc moveUp {z} {
	move $z 0 20
    }

    proc moveDown {z} {
	move $z 0 -20
    }

    proc moveRight {z} {
	move $z 20 0
    }

    proc moveLeft {z} {
	move $z -20 0
    }

    proc move {z dx dy} {
	variable currentItem

	if {$currentItem != 0} {
	    $z translate $currentItem $dx $dy
	    $z translate axisgrp:$currentItem $dx $dy
	}
    }

    proc scaleUp {z} {
	scale $z 1.1 1.1
    }

    proc scaleDown {z} {
	scale $z 0.9 0.9
    }

    proc scale {z dx dy} {
	variable currentItem

	if {$currentItem != 0} {
	    $z scale $currentItem $dx $dy
	    $z scale axisgrp:$currentItem $dx $dy
	}
    }

    proc rotateLeft {z} {
	rotate $z [expr -3.14159/18]
    }

    proc rotateRight {z} {
	rotate $z [expr 3.14159/18]
    }

    proc rotate {z angle} {
	variable currentItem
	
	if {$currentItem != 0} {
	    $z rotate $currentItem $angle
	    $z rotate axisgrp:$currentItem $angle
	}
    }

    proc newRectangle {z} {
	variable currentGroup

	return [$z add rectangle $currentGroup {-15 -15 15 15} \
		    -filled 1 -linewidth 0 -fillcolor tan]
    }

    proc newArc {z} {
	variable currentGroup

	return [$z add arc $currentGroup {-25 -15 25 15} \
		    -filled 1 -linewidth 0 -fillcolor tan]
    }

    proc newCurve {z} {
	variable currentGroup

	return [$z add curve $currentGroup {-15 -15 -15 15 15 15 15 -15} \
		    -filled 1 -linewidth 0 -fillcolor tan]
    }

    proc newText {z} {
	variable currentGroup

	set item [$z add text $currentGroup -anchor s]
	$z itemconfigure $item -text "Item id: $item"
	return $item;
    }

    proc newIcon {z} {
	variable currentGroup

	return [$z add icon $currentGroup -image logo -anchor center]
    }

    proc newTriangles {z} {
	variable currentGroup

	return [$z add triangles $currentGroup \
		    {-25 15 -10 -15 5 15 20 -15 35 15 50 -30} \
		    -colors {tan wheat tan wheat}]
    }

    proc newTrack {z} {
	variable currentGroup

	set labelformat {x80x50+0+0 a0a0^0^0 a0a0^0>1 a0a0>2>1 x30a0>3>1 a0a0^0>2}
	
	set item [$z add track $currentGroup 6 -labelformat $labelformat \
		      -speedvector {30 -15} -markersize 20]
	$z itemconfigure $item 0 -filled 0 -bordercolor DarkGreen -border contour
	$z itemconfigure $item 1 -filled 1 -backcolor gray60 -text AFR6128
	$z itemconfigure $item 2 -filled 0 -backcolor gray65 -text 390
	$z itemconfigure $item 3 -filled 0 -backcolor gray65 -text /
	$z itemconfigure $item 4 -filled 0 -backcolor gray65 -text 350
	$z itemconfigure $item 5 -filled 0 -backcolor gray65 -text TUR

	return $item;
    }

    proc newWayPoint {z} {
	variable currentGroup

	set labelformat {a0a0+0+0 a0a0>0^1}

	set item [$z add waypoint $currentGroup 2 -labelformat $labelformat]
	$z itemconfigure $item 0 -filled 1 -backcolor DarkGreen -text TUR
	$z itemconfigure $item 1 -text >>>

	return $item;
    }

    proc newTabular {z} {
	variable currentGroup

	set labelformat {f700f600+0+0 f700a0^0^0 f700a0^0>1 \
			     f700a0^0>2 f700a0^0>3 f700a0^0>4 f700a0^0>5}

	set item [$z add tabular $currentGroup 7 -labelformat $labelformat]
	$z itemconfigure $item 0 -filled 1 -border contour \
	    -bordercolor black -backcolor gray60
	$z itemconfigure $item 1 -alignment center -text AFR6128
	$z itemconfigure $item 2 -alignment center -text 390
	$z itemconfigure $item 3 -alignment center -text 370
	$z itemconfigure $item 4 -alignment center -text 350
	$z itemconfigure $item 5 -alignment center -text 330
	$z itemconfigure $item 6 -alignment center -text TUR

	return $item;
    }

    proc addAxes {z item length command inFront} {
	variable currentGroup

	set axesGroup [$z add group $currentGroup -tags axisgrp:$item]
	$z add curve $axesGroup [list 0 0 $length 0] -linewidth 3 \
	    -lastend {6 8 3} -tags axis:$item
	$z add curve $axesGroup [list 0 0 0 $length] -linewidth 3 \
	    -lastend {6 8 3} -tags axis:$item
	$z add rectangle $axesGroup {-3 -3 3 3} -filled 1 \
	    -linewidth 0 -composescale 0 -tags axis:$item
	if {$inFront} {
	    $z raise $item $axesGroup
	}
	$z bind axis:$item <B1-Motion> {::transforms::dragItem %W %x %y}
	$z bind axis:$item <ButtonRelease-1> "::transforms::$command %W; set drag 0"
    }

    proc addItem {z} {
	variable itemType

	set length 25
	set itemOnTop 0

	set item [eval "new$itemType $z"]
	if {($itemType == "Track") || ($itemType == "WayPoint")} {
	    set itemOnTop 1
	}

	addAxes $z $item 25 select $itemOnTop
	changeItem $z $item
    }

    proc addGroup {z} {
	variable currentGroup

	set item [$z add group $currentGroup]

	addAxes $z $item 80 selectGroup 1
	changeGroup $z $item
    }

    proc mouseAdd {z itemOrGroup x y} {
	variable currentGroup
	variable currentItem

	if {[llength [$z find withtag current]] != 0} {
	    return
	}

	foreach {x y} [$z transform $currentGroup [list $x $y]] break

	eval "add$itemOrGroup $z"

	$z translate $currentItem $x $y
	$z translate axisgrp:$currentItem $x $y
    }
}

