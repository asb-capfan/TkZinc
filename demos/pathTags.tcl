#!/usr/bin/perl -w
# $Id$
# this pathtatg demo have been developped by C. Mertz mertz@cena.fr
# with the help of Daniel Etienne etienne@cena.fr.
# tcl version by Patrick Lecoanet lecoanet@cena.fr


if {![info exists zincDemo]} {
    error "This script should be run from the zinc-widget demo."
}

namespace eval pathTags {
    variable w .pathTags
    catch {destroy $w}
    toplevel $w
    wm title $w "Zinc Path tags Demonstration"
    wm iconname $w "Path tags"

    variable defaultFont [font create -family Helvetica -size 10 -weight bold]

    grid [button $w.dismiss -text Dismiss -command "destroy $w"] -row 3 -column 0 -pady 10
    grid [button $w.code -text "See Code" -command "showCode $w"] -row 3 -column 1 -pady 10

    ## this demo demonstrates the use of path tags to address one or more items
    ## belonging to a hierarchy of groups.
    ## This hierarchy is described just below gr_xxx designates a group
    ## (with a tag xxx and i_yyy designates an non-group item (with a tag yyy .

    #  gr_top --- gr_a --- gr_aa --- gr_aaa --- gr_aaaa --- i_aaaaa
    #          |       |         |          |-- i_aaab  |-- i_aaaab
    #          |       |         -- i_aab
    #          |       |-- i_ab
    #          |       |
    #          |       ---gr_ac --- i_aca
    #          |                |
    #          |-- i_b          --- i_acb
    #          |
    #          --- gr_c --- gr_ca --- i_caa
    #                   |         |
    #                   |         --- i_cab
    #                   |-- i_cb
    #                   |
    #                   ---gr_cc --- i_cca
    #                            |
    #                            --- i_ccb
    #the same objects are cloned and put in an other hierarchy where
    #grTop is replaced by grOtherTop

    variable defaultForeColor grey80
    variable selectedColor yellow

    ###########################################
    # Text zone
    ###########################################

    grid [text $w.text -relief sunken -borderwidth 2 -height 5 -font $defaultFont] \
	-row 0 -column 0 -columnspan 2 -sticky ew

    $w.text insert end {This represents a group hierarchy:
	- groups are represented by a rectangle and an underlined title.
	- non-group items are represented by a text.
	Select a pathTag or a tag with one of the radio-button
	or experiment your own tags in the input field}

    ###########################################
    # Zinc creation
    ###########################################

    grid [zinc $w.zinc -width 850 -height 360 -font $defaultFont -borderwidth 0 \
	-backcolor black -forecolor $defaultForeColor] -row 1 -column 0 -columnspan 2 -sticky news
    grid columnconfigure $w 0 -weight 1
    grid columnconfigure $w 1 -weight 1
    grid rowconfigure $w 1 -weight 2

    ###########################################
    # Creation of a bunch of radiobutton and a text input
    ###########################################

    variable pathtag {}
    variable explanation {...}

    grid [frame $w.toggles] -row 2 -column 0 -columnspan 2 -sticky w

    variable tagsExpl {
	top {a simple tag matching the top group}
	.top {all items with tag 'top' in the root group }
	.top. {direct children of a group with tag 'top' in the root group}
	.top* {descendents of a group with tag 'top' in the root group }
	.top*cca {items with a tag 'cca' in a direct group of root group with tag 'top'}
	.5. {direct content of the group with id 5}
	.top*aa {items with a tag 'aa' in a direct group of root group with tag 'top'}
	.top*aa. {direct children of a group with a tag 'aa', descending from a direct group of root group with tag 'top'}
	.top*aa* {descendance of a group with a tag 'aa', descending from a direct group of root group with tag 'top'}
	.top.a {items with a tag 'a' in a direct group of root group with tag 'top'}
	.top.a. {direct children of a group with tag 'a' in a direct group of root group with tag 'top'}
	.5* {descendents of the group of id 5}
	.top*aa*aaa {all items with tag 'aaa' descending from a group with tag 'aa' descending from a group with tag 'top', child of the root group}
	.top*aa*aaa. {children of a group with a tag 'aaa' descending from ONE group with a tag 'aa' descending from a group with a tag 'top' child of the root group}
	.top*aa*aaa* {descendance of ONE group with a tag 'aaa' descending from ONE group with a tag 'aa' descending from ONE group with a tag 'top' child of the root group}
	.other_top*aa* {descendance of ONE group with a tag 'aa' descending from ONE group with a tag 'other_top' child of the root group}
	.5*ca* {descendance of ONE group with a tag 'ca' descending from THE group with id 5}
	*aa*aaaa {all items with a tag 'aaaa' descending from a group with a tag 'aa'}
	*aaa {all items with a tag 'aaa'}
	aa||ca {items with tag 'aa' or tag 'ca'}
	none {no items, as none has the tag 'none'}
	all {all items}
    }

    variable row 1
    variable col 2
    foreach {key val} $tagsExpl {
	grid [radiobutton $w.toggles.r$row+$col -text $key -font $defaultFont \
		  -command ::pathTags::displayPathtag -variable ::pathTags::pathtag -relief flat \
		  -value $key] -column $col -row $row -sticky w -pady 0 -ipady 0
	incr row
	if {$row > 6} {
	    set row 1
	    incr col
	}
    }

    grid [label $w.toggles.lyt -font $defaultFont -relief flat \
	      -text {your own tag:}] -column 2 -row 7 -sticky e -ipady 5
    grid [entry $w.toggles.eyt -font $defaultFont -width 15 \
	      -textvariable ::pathTags::pathtag] -column 3 -row 7 -sticky w
    bind $w.toggles.eyt <Return> ::pathTags::displayPathtag
    grid [label $w.toggles.elabel -font $defaultFont -text "explanation:"] \
	-row 8 -column 2 -sticky e
    grid [label $w.toggles.explan -font $defaultFont -width 70 -height 3 \
	      -justify left -anchor w -wraplength 16c -textvariable explanation] \
	-row 8 -column 3 -columnspan 4 -sticky w
    grid columnconfigure $w.toggles 5 -weight 10


    ### Here we create the genuine hierarchy of groups and items
    ### Later we will create graphical objects to display groups
    proc createSubHierarchy {gr} {
	variable w

	$w.zinc add group $gr -tags a
	$w.zinc add text $gr -tags {b text} -text b -position {270 150}
	$w.zinc add group $gr -tags c
	
	$w.zinc add group a -tags aa
	$w.zinc add text a -tags {ab text} -text ab -position {60 220}
	$w.zinc add group a -tags ac
	
	$w.zinc add group aa -tags aaa
	$w.zinc add text aa -tags {aab text} -text aab -position {90 190}
	$w.zinc add group aaa -tags aaaa
	$w.zinc add text aaaa -tags {aaaaa text} -text aaaaa -position {150 110}
	$w.zinc add text aaaa -tags {aaaab text} -text aaaab -position {150 130}
	$w.zinc add text aaa -tags {aaab text} -text aaab -position {120 160}
	
	$w.zinc add text ac -tags aca -text aca -position {90 260}
	$w.zinc add text ac -tags {acb text} -text acb -position {90 290}
	
	$w.zinc add group c -tags ca
	$w.zinc add text c -tags {cb text} -text cb -position {330 160}
	$w.zinc add group c -tags cc
	
	$w.zinc add text ca -tags {caa text} -text caa -position {360 110}
	$w.zinc add text ca -tags {cab text} -text cab -position {360 130}
	
	$w.zinc add text cc -tags {cca text} -text cca -position {360 200}
	$w.zinc add text cc -tags {ccb text} -text ccb -position {360 220}
    }

    # creating the item hierarchy
    $w.zinc add group 1 -tags top
    createSubHierarchy top

    # creating a parallel hierarchy
    $w.zinc add group 1 -tags other_top
    createSubHierarchy other_top


    ## modifying the priority so that all rectangles and text will be visible
    foreach item [$w.zinc find withtype text ".top*"] {
	$w.zinc itemconfigure $item -priority 20
    }
    foreach item [$w.zinc find withtype text ".other_top*"] {
	$w.zinc itemconfigure $item -priority 20
    }
    foreach item [$w.zinc find withtype group ".top*"] {
	$w.zinc itemconfigure $item -priority 20
    }
    foreach item [$w.zinc find withtype group ".other_top*"] {
	$w.zinc itemconfigure $item -priority 20
    }

    # converts a list of items ids in a list of sorted tags (the first tag of each item)
    proc items2tags {items} {
	variable w

	set selectedTags {}
	foreach item $items {
	    set tags [$w.zinc itemcget $item -tags]
	    if {[regexp {frame|title} [lindex $tags 0]]} {
		# to remove group titles frame
		continue
	    }
	    lappend selectedTags [lindex tags 0]
	}
	return [lsort $selectedTags]
    }

    ### drawing :
    ####   a rectangle item for showing the bounding box of each group 
    ###    a text item for the group name (i.e. its first tag)

    ## backgrounds used to fill rectangles representing groups
    variable backgrounds {grey25 grey35 grey43 grey50 grey55}

    proc drawHierarchy {group level} {
	variable w
	variable backgrounds

	set tags [$w.zinc gettags $group]
	#    print "level=$level (" $tags[0],")\n";
	foreach g [$w.zinc find withtype group .$group.] {
	    drawHierarchy $g [expr $level + 1]
	}
	foreach {x y x2 y2} [$w.zinc bbox $group] break
	$w.zinc add text $group -position [list [expr $x-5] [expr $y-4]] \
	    -text [lindex $tags 0] -anchor w -alignment left -underlined 1 \
	    -priority 20 -tags [list title_[lindex $tags 0] group_title]
	foreach {x y x2 y2} [$w.zinc bbox $group] break
	if {$x ne "" } {
	    $w.zinc add rectangle $group [list [expr $x+0] [expr $y+5] \
					      [expr $x2+5] [expr $y2+2]] \
		-filled 1 -fillcolor [lindex $backgrounds $level] -priority $level \
		-tags [list frame_[lindex $tags 0] group_frame]
	} else {
	    puts "undefined bbox for $group : $tags"
	}
    }

    ### this sub extracts out of groups both text and frame representing
    ### each group. This is necessary to avoid unexpected selection of
    ### rectangles and titles inside groups
    proc extractTextAndFrames { } {
	variable w

	foreach group_title [$w.zinc find withtag group_title||group_frame] {
	    set ancestors [$w.zinc find ancestor $group_title]
	    #	puts "$group_title $ancestors"
	    set grandFather [lindex $ancestors 1]
	    $w.zinc chggroup $group_title $grandFather 1
	}
    }

    proc TLGet {list tag {default ""}} {
	foreach {key val} $list {
	    if { [string compare $key $tag] == 0 } {
		return $val
	    }
	}
	return $default
    }

    ## this sub modifies the color/line color of texts and rectangles
    ## representing selected items. 
    proc displayPathtag { } {
	variable w
	variable explanation
	variable pathtag
	variable defaultForeColor
	variable selectedColor
	variable tagsExpl

	if {[catch {set explanation [TLGet $tagsExpl $pathtag]}]} {
	    set explanation {sorry, I am not smart enough to explain your pathTag ;-\)}
	}
	set selected [$w.zinc find withtag $pathtag]
	set tags [items2tags $selected]
	#    puts "selected: $tags"
	
	## unselecting all items 
	foreach item [$w.zinc find withtype text] {
	    $w.zinc itemconfigure $item -color $defaultForeColor
	}
	foreach item [$w.zinc find withtype rectangle] {
	    $w.zinc itemconfigure $item -linecolor $defaultForeColor
	}

	## highlighting selected items
	foreach item $selected {
	    set type [$w.zinc type $item]
	    #puts "$item $type [$w.zinc gettags $item]"
	    if {$type eq "text"} {
		$w.zinc itemconfigure $item -color $selectedColor
	    } elseif {$type eq "rectangle"} {
		$w.zinc itemconfigure $item -linecolor $selectedColor
	    } elseif {$type eq "group"} {
		set tag [lindex [$w.zinc gettags $item] 0]
		## as there is 2 // hierachy we must refine the tag used
		## to restrict to the proper hierarchy
		## NB: this is due to differences between the group hierarchy
		##     and the graphical object hierarchy used for this demo
		if {[llength [$w.zinc find ancestors $item top]]} {
		    $w.zinc itemconfigure ".top*frame_$tag" -linecolor $selectedColor
		    $w.zinc itemconfigure ".top*title_$tag" -color $selectedColor
		} elseif {[llength [$w.zinc find ancestors $item other_top]]} {
		    $w.zinc itemconfigure ".other_top*frame_$tag" -linecolor $selectedColor
		    $w.zinc itemconfigure ".other_top*title_$tag" -color $selectedColor
		} else {
		    $w.zinc itemconfigure "frame_$tag" -linecolor $selectedColor
		    $w.zinc itemconfigure "title_$tag" -color $selectedColor
		}
	    }
	}
    }

    drawHierarchy top 0
    drawHierarchy other_top 0
    $w.zinc translate other_top 400 0
    extractTextAndFrames
}
