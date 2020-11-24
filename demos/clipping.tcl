# these simple samples have been developped by C. Mertz mertz@cena.fr in perl
# tcl version by Jean-Paul Imbert imbert@cena.fr

if {![info exists zincDemo]} {
    error "This script should be run from the zinc-widget demo."
}

namespace eval clippingDemo {
    variable w .clipping
    catch {destroy $w}
    toplevel $w
    wm title $w "Zinc Clipping Demonstration"
    wm iconname $w "Clipping"

    variable defaultfont [font create -family Helvetica -size 14 -weight normal]

    grid [button $w.dismiss -text Dismiss -command "destroy $w"] -row 2 -column 0 -pady 10
    grid [button $w.code -text "See Code" -command "showCode $w"] -row 2 -column 1 -pady 10

    grid [zinc $w.zinc -width 700 -height 600 -font $defaultfont -borderwidth 3 \
	      -relief sunken] -row 0 -column 0 -columnspan 2 -sticky news
    grid columnconfigure $w 0 -weight 1
    grid columnconfigure $w 1 -weight 1
    grid rowconfigure $w 0 -weight 2

    variable displayClippingItemBackground   0
    variable clip   1

    $w.zinc add text 1 -font $defaultfont -text "You can drag and drop the objects.\nThere are two groups of objects a tan group and a blue group\nTry to move them and discover the clipping area which is a curve.\nwith two contours" -anchor nw -position {10 10}


    variable clippedGroup [$w.zinc add group 1 -visible 1]

    variable clippingItem  [$w.zinc add curve $clippedGroup {10 100 690 100 690 590 520 350 350 590 180 350 10 590} -closed 1 -priority 1 -fillcolor tan2 -linewidth 0 -filled $displayClippingItemBackground]
    $w.zinc contour $clippingItem add +1 {200 200 500 200 500 250 200 250}

    ############### creating the tanGroup objects ################
    # the tanGroup is atomic  that is is makes all children as a single object
    # and sensitive to tanGroup callbacks
    variable tanGroup [$w.zinc add group $clippedGroup -visible 1 -atomic 1 -sensitive 1]
    

    $w.zinc add arc $tanGroup {200 220 280 300} -filled 1 -linewidth 1 -startangle 45 -extent 270 -pieslice 1 -closed 1 -fillcolor tan
    

    $w.zinc add curve $tanGroup {400 400 440 450 400 500 500 500 460 450 500 400} -filled 1 -fillcolor tan -linecolor tan
    

    ############### creating the blueGroup objects ################
    # the blueGroup is atomic too  that is is makes all children as a single object
    # and sensitive to blueGroup callbacks
    variable blueGroup   [$w.zinc add group $clippedGroup -visible 1 -atomic 1 -sensitive 1]

    $w.zinc add rectangle $blueGroup {570 180   470 280} -filled 1 -linewidth 1 -fillcolor blue2

    $w.zinc add curve $blueGroup {200 400 200 500 300 500 300 400 300 300} -filled 1 -fillcolor blue -linewidth 0


    $w.zinc itemconfigure $clippedGroup -clip  $clippingItem


    ###################### drag and drop callbacks ############
    # for both tanGroup and blueGroup

    $w.zinc bind $tanGroup <1> "::clippingDemo::itemStartDrag $tanGroup %x %y" 
    $w.zinc bind $tanGroup <B1-Motion> "::clippingDemo::itemDrag $tanGroup %x %y"
    $w.zinc bind $blueGroup <1> "::clippingDemo::itemStartDrag $blueGroup %x %y" 
    $w.zinc bind $blueGroup <B1-Motion> "::clippingDemo::itemDrag $blueGroup %x %y"



    # callback for starting a drag
    variable xOrig ""
    variable yOrig ""

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
	$w.zinc translate $item  [expr $x-$xOrig] [expr $y-$yOrig];
	set xOrig  $x;
	set yOrig  $y;
    }



    ###################### toggle buttons at the bottom #######
    grid [frame $w.row] -row 1 -column 0 -columnspan 2
    checkbutton $w.row.show -text "Show clipping item" \
	-variable ::clippingDemo::displayClippingItemBackground \
	-command "::clippingDemo::displayClippingArea"
    checkbutton $w.row.clip -text Clip -variable ::clippingDemo::clip \
	-command "::clippingDemo::clipCommand"
    pack $w.row.show $w.row.clip -side left

    proc displayClippingArea {} {
	variable clippingItem
	variable w
	variable displayClippingItemBackground
	$w.zinc itemconfigure $clippingItem -filled  $displayClippingItemBackground
    }

    proc clipCommand {} {
	variable clip
	variable clippedGroup
	variable clippingItem
	variable w

	if {$clip} {
	    $w.zinc itemconfigure $clippedGroup -clip  $clippingItem
	} else {
	    $w.zinc itemconfigure $clippedGroup -clip ""
	}
    }
}
