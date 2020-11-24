# these simple samples have been developped by C. Mertz mertz@cena.fr in perl
# tcl version by Jean-Paul Imbert imbert@cena.fr

if {![info exists zincDemo]} {
    error "This script should be run from the zinc-widget demo."
}

namespace eval windowContours {
    variable w .windowContours
    catch {destroy $w}
    toplevel $w
    wm title $w "Zinc Contours Demonstration"
    wm iconname $w Contours

    variable defaultfont [font create -family Helvetica -size 20 -weight normal]

    grid [button $w.dismiss -text Dismiss -command "destroy $w"] -row 2 -column 0 -pady 10
    grid [button $w.code -text "See Code" -command "showCode $w"] -row 2 -column 1 -pady 10

    # Creating the zinc widget
    grid [zinc $w.zinc -width 600 -height 500 -font 9x15 -borderwidth 3 \
	       -relief sunken] -row 0 -column 0 -columnspan 2 -sticky news
    grid columnconfigure $w 0 -weight 1
    grid columnconfigure $w 1 -weight 1
    grid rowconfigure $w 0 -weight 2

    # The explanation displayed when running this demo
    $w.zinc add text 1 -position {10 10} -text "These windows are simply rectangles holed by 4 smaller\nrectangles. The text appears behind the window glasses.\nYou can drag text or windows" -font 10x20


    # Text in background
    variable backtext [$w.zinc add text 1 -position {50 200} \
			   -text "This text appears\nthrough holes of curves" \
			   -font "-adobe-helvetica-bold-o-normal--34-240-100-100-p-182-iso8859-1"]

    variable window [$w.zinc add curve 1 {100 100 300 100 300 400 100 400} -closed 1 \
			 -visible 1 -filled 1 -fillcolor grey66]


    variable aGlass [$w.zinc add rectangle 1 {120 120 190 240}]
    $w.zinc contour $window add +1 $aGlass

    $w.zinc translate $aGlass 90 0
    $w.zinc contour $window add +1 $aGlass

    $w.zinc translate $aGlass 0 140
    $w.zinc contour $window add +1 $aGlass

    $w.zinc translate $aGlass -90 0
    $w.zinc contour $window add +1 $aGlass


    # deleting $aGlass which is no more usefull
    $w.zinc remove $aGlass

    # cloning $window
    variable window2 [$w.zinc clone $window]

    # changing its background moving it and scaling it!
    $w.zinc itemconfigure $window2 -fillcolor grey50
    $w.zinc translate $window2 30 50
    $w.zinc scale $window 0.8 0.8


    # adding drag and drop callback to the two windows and backtext
    foreach item "$window $window2 $backtext" {
	# Some bindings for dragging the items
	$w.zinc bind $item <1> "::windowContours::itemStartDrag $item %x %y" 
	$w.zinc bind $item <B1-Motion> "::windowContours::itemDrag $item %x %y"
    }

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
	$w.zinc translate $item [expr $x-$xOrig] [expr $y-$yOrig];
	set xOrig $x;
	set yOrig $y;
    }
}
