# these simple samples have been developped by C. Mertz mertz@cena.fr in perl
# tcl version by Jean-Paul Imbert imbert@cena.fr

if {![info exists zincDemo]} {
    error "This script should be run from the zinc-widget demo."
}

namespace eval atomicGroups {
    variable w .atomicGroups
    catch {destroy $w}
    toplevel $w
    wm title $w "Zinc Atomicity Demonstration"
    wm iconname $w "Atomic"

    variable defaultfont [font create -family Helvetica -size 14 -weight normal]

    grid [button $w.dismiss -text Dismiss -command "destroy $w"] -row 6 -column 0 -pady 10
    grid [button $w.code -text "See Code" -command "showCode $w"] -row 6 -column 1 -pady 10

    grid [zinc $w.zinc -width 500 -height 350 -font $defaultfont -borderwidth 0] \
	-row 0 -column 0 -columnspan 2 -sticky news
    grid columnconfigure $w 0 -weight 1
    grid columnconfigure $w 1 -weight 1
    grid rowconfigure $w 0 -weight 2

    variable groupsGroupAtomicity  0
    variable redGroupAtomicity  0
    variable greenGroupAtomicity  0

    $w.zinc add "text"  1 -font  $defaultfont -text  "- There are 3 groups: a red group containing 2 redish objects\na green group containing 2 greenish objects,\nand groupsGroup containing both previous groups.\n- You can make some groups atomic or not by depressing \nthe toggle buttons at the bottom of the window\n- Try and then click on some items to observe that callbacks\n are then different: they modify either the item, or 2 items of\n a group or all items" -anchor  "nw" -position  "10 10"


    ############### creating the top group with its bindings ###############################
    variable groupsGroup [$w.zinc add group 1 -visible 1 -atomic $groupsGroupAtomicity -tags groupsGroup]

    # the following callbacks will be called only if "groupsGroup" IS atomic
    $w.zinc bind $groupsGroup <1> ::atomicGroups::modifyBitmapBg
    $w.zinc bind $groupsGroup <ButtonRelease-1> ::atomicGroups::modifyBitmapBg

    ############### creating the redGroup, with its binding and its content ################
    # the redGroup may be atomic, that is is makes all children as a single object
    # and sensitive to redGroup callbacks
    variable redGroup [$w.zinc add group $groupsGroup -visible 1 -atomic $redGroupAtomicity -sensitive 1 -tags redGroup]

    # the following callbacks will be called only if "groupsGroup" IS NOT-atomic
    # and if "redGroup" IS atomic
    $w.zinc bind $redGroup <1> "::atomicGroups::modifyItemLines $redGroup"
    $w.zinc bind $redGroup <ButtonRelease-1> "::atomicGroups::modifyItemLines $redGroup" 


    variable rc [$w.zinc add arc $redGroup {100 200 140 240} -filled 1 -fillcolor red2 -linewidth 3 -linecolor white -tags redCircle]
    variable rr [$w.zinc add rectangle $redGroup {300 200 400 250} -filled 1 -fillcolor red2 -linewidth 3 -linecolor white -tags redRectangle]

    # the following callbacks will be called only if "groupsGroup" IS NOT atomic
    # and if "redGroup" IS NOT atomic
    $w.zinc bind $rc  <1> ::atomicGroups::toggleColor
    $w.zinc bind $rc  <ButtonRelease-1> ::atomicGroups::toggleColor
    $w.zinc bind $rr  <1> ::atomicGroups::toggleColor
    $w.zinc bind $rr  <ButtonRelease-1> ::atomicGroups::toggleColor

    ############### creating the greenGroup, with its binding and its content ################
    # the greenGroup may be atomic, that is is makes all children as a single object
    # and sensitive to greenGroup callbacks
    variable greenGroup  [$w.zinc add group $groupsGroup -visible 1 -atomic $greenGroupAtomicity -sensitive 1 -tags greenGroup]

    # the following callbacks will be called only if "groupsGroup" IS NOT atomic
    # and if "greenGroup" IS atomic
    $w.zinc bind $greenGroup <1> "::atomicGroups::modifyItemLines $greenGroup"
    $w.zinc bind $greenGroup <ButtonRelease-1> "::atomicGroups::modifyItemLines $greenGroup"

    variable gc [$w.zinc add arc $greenGroup {100 270  140 310} -filled 1 -fillcolor green2 -linewidth 3 -linecolor white -tags greenCircle]

    variable gr [$w.zinc add rectangle $greenGroup {300 270   400 320} -filled 1 -fillcolor green2 -linewidth 3 -linecolor white -tags greenRectangle]
    # the following callbacks will be called only if "groupsGroup" IS NOT atomic
    # and if "greenGroup" IS NOT atomic
    $w.zinc bind $gc  <1>  ::atomicGroups::toggleColor
    $w.zinc bind $gc  <ButtonRelease-1>  ::atomicGroups::toggleColor
    $w.zinc bind $gr  <1>  ::atomicGroups::toggleColor
    $w.zinc bind $gr  <ButtonRelease-1>  ::atomicGroups::toggleColor


    variable currentBg  ""
    ###################### groupsGroup callback ##############

    proc modifyBitmapBg {} {
	variable currentBg		      
	variable rc
	variable rr
	variable gc
	variable gr
	variable w
	if {$currentBg=="AlphaStipple2"} {
	    set currentBg {}
	} else {
	    set currentBg AlphaStipple2
	}
	foreach item "$rc  $rr  $gc  $gr" {
	    $w.zinc itemconfigure $item -fillpattern $currentBg
	}
    }

    #################### red/greenGroup callback ##############
    proc modifyItemLines {gr} {
	variable w
	
	set children [$w.zinc find withtag ".$gr*"] 
	# we are using a pathtag (still undocumented feature of 3.2.6) to get items of an atomic group!
	# we could also temporary modify the groups (make it un-atomic) to get its child

	set currentLineWidth [$w.zinc itemcget [lindex $children 0] -linewidth]

	if {$currentLineWidth == 3} {
	    set currentLineWidth 0
	} else {
	    set currentLineWidth 3
	}
	foreach item $children {
	    $w.zinc itemconfigure $item  -linewidth  $currentLineWidth
	}
	
    }


    ##################### items callback ######################
    proc toggleColor {} {
	variable w
	set item  [$w.zinc find withtag current]
	set fillcolor  [$w.zinc itemcget $item  -fillcolor]
	regexp {([a-z]+)(\d)} $fillcolor "" color num

	#my ($color $num) = $fillcolor =~ /("a-z"+)(\d)/ 
	if {$num == 2} {    
	    set val 1
	    set num 4
	} else {
	    set num 2
	}
	$w.zinc itemconfigure $item -fillcolor "$color$num"
    }

    proc  atomicOrNot {gr} {
	variable w
	set val [lindex [$w.zinc itemconfigure $gr  -atomic] 4]
	if {$val==1} {
	    $w.zinc itemconfigure $gr  -atomic 0
	} else {
	    $w.zinc itemconfigure $gr  -atomic 1
	}
	updateFoundItems
    }


    ###################### toggle buttons at the bottom ####

    grid [checkbutton $w.cb -text "groupsGroup is atomic" -variable ::atomicGroups::groupsGroupAtomicity \
	-command "::atomicGroups::atomicOrNot  $groupsGroup"] -row 1 -column 0 -sticky w
    grid [checkbutton $w.cb2 -text "red group is atomic" -foreground red4 \
	-variable ::atomicGroups::redGroupAtomicity \
	      -command "::atomicGroups::atomicOrNot $redGroup"] -row 2 -column 0 -sticky w
    grid [checkbutton $w.cb3 -text "green group is atomic" -foreground green4 \
	-variable  ::atomicGroups::greenGroupAtomicity \
	      -command  "::atomicGroups::atomicOrNot $greenGroup"] -row 3 -column 0 -sticky w

    grid [label $w.lb2 -text "Following command '$w.zinc find overlapping 0 200 500 400', returns:"] \
	-row 4 -column 0 -columnspan 2 -pady 10
    grid [label $w.label -text ""] \
	-row 5 -column 0 -columnspan 2


    ##### to update the list of enclosed items
    proc updateFoundItems {} {
	variable w
	set found  [$w.zinc find overlapping 0 200 500 400]
	set str  ""
	foreach item $found {
	    set tags [$w.zinc itemcget $item  -tags]
	    set str  "$str $tags"
	}
	$w.label configure -text  $str 
    }

    # to init the list of enclosed items
    updateFoundItems
}
