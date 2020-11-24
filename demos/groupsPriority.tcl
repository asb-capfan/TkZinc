# these simple samples have been developped by C. Mertz mertz@cena.fr in perl
# tcl version by Jean-Paul Imbert imbert@cena.fr

if {![info exists zincDemo]} {
    error "This script should be run from the zinc-widget demo."
}


namespace eval groupsPriority {
    variable w .groupsPriority
    catch {destroy $w}
    toplevel $w
    wm title $w "Zinc Groups priority Demonstration"
    wm iconname $w Groups

    variable defaultfont [font create -family Helvetica -size 14 -weight bold]

    grid [button $w.dismiss -text Dismiss -command "destroy $w"] -row 2 -column 0 -pady 10
    grid [button $w.code -text "See Code" -command "showCode $w"] -row 2 -column 1 -pady 10


    ###########################################
    # Text zone
    ###########################################

    grid [text $w.text -relief sunken -borderwidth 2 -height 12] \
	-row 0 -column 0 -columnspan 2 -sticky ew

    $w.text insert end "There are two groups (a red one and a green one) each containing\n4 rectangles. Those rectangles display their current priority.\nThe following operations are possible:\n Mouse Button 1 for dragging objects.\n Mouse Button 2 for dragging a colored group.\n Key + on a rectangle to raise it inside its group.\n Key - on a rectangle to lower it inside its group.\n Key l on a rectangle to lower its colored group.\n Key r on a rectangle to raise its colored group.\n Key t on a rectangle to change its group (but not its color!).\n Key 0-9 on a rectangle to set the priority to 0-9\nRaising or lowering an item inside a group modify its priority if necessary"

    ###########################################
    # Zinc
    ###########################################
    variable zinc_width 600
    variable zinc_height 500
    grid [zinc $w.zinc -width $zinc_width -height $zinc_height -font $defaultfont \
	      -borderwidth 3 -relief sunken] -row 1 -column 0 -columnspan 2 -sticky news
    grid columnconfigure $w 0 -weight 1
    grid columnconfigure $w 1 -weight 1
    grid rowconfigure $w 1 -weight 2


    #########################################################################"
    # Creating the redish group
    variable group1 [$w.zinc add group 1 -visible 1]

    variable counter 0 
    # Adding 4 rectangles with text to redish group
    foreach data { {200 100 red} {210 210 red1} {390 110 red2} {395 215 red3} } {
	set counter [expr $counter+ 2]
	set centerx [lindex $data 0]
	set centery [lindex $data 1]
	set color [lindex $data 2]

	# this small group is for merging together :
	# the rectangle and the text showing its name
	set g [$w.zinc add group $group1 -visible 1 -atomic 1 -sensitive 1 -priority $counter]
	set rec [$w.zinc add rectangle $g \
		     [list [expr $centerx-100] [expr $centery-60] [expr $centerx+100] [expr $centery+60]] \
		     -fillcolor $color -filled 1]

	set txt [$w.zinc add "text" $g -position "$centerx $centery" -text "pri=$counter" -anchor center]

	# Some bindings for dragging the rectangle or the full group
	$w.zinc bind $g <1> "::groupsPriority::itemStartDrag $g %x %y" 
	$w.zinc bind $g <B1-Motion> "::groupsPriority::itemDrag $g %x %y"
	$w.zinc bind $g <2> "::groupsPriority::itemStartDrag $g %x %y" 
	$w.zinc bind $g <B2-Motion> "::groupsPriority::groupDrag $g %x %y"
    }

    #########################################################################"
    # Creating the greenish group
    variable group2 [$w.zinc add group 1 -visible 1]
    variable counter 0

    # Adding 4 rectangles with text to greenish group
    foreach data {{200 300 green1} {210 410 green2} {390 310 green3} {395 415 green4}} {
	incr counter
	set centerx [lindex $data 0]
	set centery [lindex $data 1]
	set color [lindex $data 2]

	# this small group is for merging together a rectangle
	# and the text showing its priority
	set g [$w.zinc add group $group2 -atomic 1 -sensitive 1 -priority $counter]

	set rec [$w.zinc add rectangle $g "[expr $centerx-100] [expr $centery-60] [expr $centerx+100] [expr $centery+60]" -fillcolor $color -filled 1]

	set txt [$w.zinc add text $g -position "$centerx $centery" -text "pri=$counter" -anchor center]

	# Some bindings for dragging the rectangle or the full group
	$w.zinc bind $g <1> "::groupsPriority::itemStartDrag $g %x %y" 
	$w.zinc bind $g <B1-Motion> "::groupsPriority::itemDrag $g %x %y"
	$w.zinc bind $g <2> "::groupsPriority::itemStartDrag $g %x %y" 
	$w.zinc bind $g <B2-Motion> "::groupsPriority::groupDrag $g %x %y"
    }


    #########################################################################"
    # adding the key bindings

    # the focus on the widget is ABSOLUTELY necessary for key bindings!
    focus $w.zinc

    bind $w.zinc <KeyPress-r> ::groupsPriority::raiseGroup
    bind $w.zinc <KeyPress-l> ::groupsPriority::lowerGroup
    bind $w.zinc <KeyPress-plus> ::groupsPriority::raise

    bind $w.zinc <KP_Add> ::groupsPriority::raise
    bind $w.zinc <KeyPress-minus> ::groupsPriority::lower
    bind $w.zinc <KP_Subtract> ::groupsPriority::lower
    bind $w.zinc <KeyPress-t> ::groupsPriority::toggleItemGroup

    for {set i 0} {$i<=9} {incr i} {
	bind $w.zinc <KeyPress-$i> "::groupsPriority::setPriority $i"
	bind $w.zinc <KeyPress-KP_$i> "::groupsPriority::setPriority $i"
    }

    # The following binding is currently not possible only text items
    # with focus can get a KeyPress or KeyRelease event
    # $zinc->bind($g '<KeyPress>' [\&raise $g]

    ####################################withtype#####################################"
    # Definition of all callbacks


    proc updateLabel {group} {
	variable w

	set priority [$w.zinc itemcget $group -priority]
	# we get the text item from this group:
	set textitem [$w.zinc find withtype text ".$group."]
	$w.zinc itemconfigure $textitem -text "pri=$priority"
    }

    proc setPriority {priority} {
	variable w

	set item [$w.zinc find withtag current]
	#return unless $item
	$w.zinc itemconfigure $item -priority $priority
	updateLabel $item
    }


    # Callback to lower a small group of a rectangle and a text
    proc lower {} {
	variable w

	# to get the item under the cursor!
	set item [$w.zinc find withtag current]
	#return unless $item
	$w.zinc lower $item
	updateLabel $item
    }


    # Callback to raise a small group of a rectangle and a text
    proc raise {} {
	variable w

	# to get the item under the cursor!
	set item [$w.zinc find withtag current]
	#return unless $item
	$w.zinc raise $item
	updateLabel $item
    }

    # Callback to raise the group of groups of a rectangle and a text
    proc lowerGroup {} {
	variable w 

	# to get the item under the cursor!
	set item [$w.zinc find withtag current]
	#return unless $item
	set coloredGroup [$w.zinc group $item]
	$w.zinc lower $coloredGroup
    }

    # Callback to raise the group of groups of a rectangle and a text
    proc raiseGroup {} {
	variable w

	# to get the item under the cursor!
	set item [$w.zinc find withtag current]
	#return unless $item
	set coloredGroup [$w.zinc group $item]
	$w.zinc raise $coloredGroup
	updateLabel $item
    }

    # Callback to change  puts raise
    #the group of groups of a rectangle and a text
    proc toggleItemGroup {} {
	variable group1
	variable group2
	variable w

	# to get the item under the cursor!
	set item [$w.zinc find withtag current]
	
	# return unless $item
	set newgroup ""
	if {$group1 == [$w.zinc group $item]} {
	    set newgroup $group2
	} else {
	    set newgroup $group1
	}
	$w.zinc chggroup $item $newgroup 1
	updateLabel $item
    }

    # callback for starting a drag
    set xOrig ""
    set yOrig ""

    proc itemStartDrag {item x y} {
	variable xOrig
	variable yOrig

	set xOrig $x
	set yOrig $y
    }

    # Callback for moving an item
    proc itemDrag {item x y} {
	variable xOrig
	variable yOrig
	variable w

	$w.zinc translate $item [expr $x-$xOrig] [expr $y-$yOrig];
	set xOrig $x;
	set yOrig $y;
    }

    # Callback for moving an item
    proc groupDrag {item x y} {
	variable xOrig
	variable yOrig
	variable w

	set coloredGroup [$w.zinc group $item]
	$w.zinc translate $coloredGroup [expr $x-$xOrig] [expr $y-$yOrig];
	set xOrig $x;
	set yOrig $y;
    }
}



