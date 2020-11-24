# these simple samples have been developped by C. Mertz mertz@cena.fr in perl
# tcl version by Jean-Paul Imbert imbert@cena.fr

if {![info exists zincDemo]} {
    error "This script should be run from the zinc-widget demo."
}


namespace eval simpleInteractionTrack {
    variable w .simpleInteractionTrack
    catch {destroy $w}
    toplevel $w
    wm title $w "Zinc Track Interaction Demonstration"
    wm iconname $w TrackInteraction

    set defaultfont [font create -family Helvetica -size 14 -weight normal]
    set labelfont [font create -family Courier -size 18 -weight bold]

    grid [button $w.dismiss -text Dismiss -command "destroy $w"] -row 2 -column 0 -pady 10
    grid [button $w.code -text "See Code" -command "showCode $w"] -row 2 -column 1 -pady 10


    ###########################################
    # Zinc
    ###########################################
    grid [zinc $w.zinc -width 600 -height 500 -font $labelfont -borderwidth 0] \
	-row 1 -column 0 -columnspan 2 -sticky news
    grid columnconfigure $w 0 -weight 1
    grid columnconfigure $w 1 -weight 1
    grid rowconfigure $w 1 -weight 2


    # The explanation displayed when running this demo
    $w.zinc add text 1 -position {10 10} -text {This toy-appli shows some interactions on different parts
of a flight track item.
     The following operations are possible:
       - Drag Button 1 on the track to move it.
         Please Note the position history past positions
       - Enter/Leave flight label fields
       - Enter/Leave the speedvector symbol i.e. current
         position label leader} -font $defaultfont


    ###########################################
    # Track
    ###########################################

    #the label format 6 formats for 6 fields#
    variable labelformat {x90x55+0+0 a0a0^0^0 a0a0^0>1 a0a0>2>1 a0a0>3>1 a0a0^0>2}

    #the track#
    variable x 250
    variable y 200
    variable xi 0
    variable yi 0
    variable track [$w.zinc add track 1 6 -labelformat $labelformat -position "$x $y" \
			-speedvector {30 -15} -markersize 10]

    # moving the track to display past positions
    for {set i 0} {$i<=5} {incr i} { 
	$w.zinc coords $track [list [expr $x+$i*10] [expr $y-$i*5]]
    }

    #fields of the label#
    $w.zinc itemconfigure $track 0 -filled 0 -bordercolor DarkGreen -border contour
    $w.zinc itemconfigure $track 1 -filled 1 -backcolor gray60 -text AFR6128

    $w.zinc itemconfigure $track 2 -filled 0 -backcolor gray65 -text 390

    $w.zinc itemconfigure $track 3 -filled 0 -backcolor gray65 -text /

    $w.zinc itemconfigure $track 4 -filled 0 -backcolor gray65 -text 350

    $w.zinc itemconfigure $track 5 -filled 0 -backcolor gray65 -text TUR



    ###########################################
    # Events on the track
    ###########################################
    #---------------------------------------------
    # Enter/Leave a field of the label of the track
    #---------------------------------------------

    for {set field 0} {$field<=5} {incr field} { 
	#Entering the field $field higlights it#
	$w.zinc bind $track:$field <Enter> "::simpleInteractionTrack::highlightEnter $field"
	#Leaving the field cancels the highlight of $field#
	$w.zinc bind $track:$field <Leave> "::simpleInteractionTrack::highlightLeave $field"
    }

    proc highlightEnter {field} {
	if {$field ==0} { 
	    highlightLabelOn 
	} else {
	    highlightFieldsOn $field
	}
	
    }
    proc highlightLeave {field} {
	if {$field==0} {
	    highlightLabelOff 
	} else {
	    if {$field==1} {
		highlightField1Off 
	    } else {
		highlightOtherFieldsOff $field
	    }
	}
    }

    #fonction#
    proc highlightLabelOn {} {
	variable w
	$w.zinc itemconfigure current 0 -filled 0 -bordercolor red -border contour
    }

    proc highlightLabelOff {} {
	variable w
	$w.zinc itemconfigure current 0 -filled 0 -bordercolor DarkGreen -border contour
    }

    proc highlightFieldsOn {field} {
	variable w
	$w.zinc itemconfigure current $field -border contour -filled 1 -color white
    }

    proc highlightField1Off {} {
	variable w
	$w.zinc itemconfigure current 1 -border "" -filled 1 -color black -backcolor gray60
    }

    proc highlightOtherFieldsOff {field} {
	variable w
	$w.zinc itemconfigure current $field -border "" -filled 0 -color black -backcolor gray65
    }

    #---------------------------------------------
    # Enter/Leave other parts of the track
    #---------------------------------------------
    $w.zinc bind $track:position <Enter> "$w.zinc itemconfigure $track -symbolcolor red"
    $w.zinc bind $track:position <Leave> "$w.zinc itemconfigure $track -symbolcolor black"
    $w.zinc bind $track:speedvector <Enter> "$w.zinc itemconfigure $track -speedvectorcolor red"
    $w.zinc bind $track:speedvector <Leave> "$w.zinc itemconfigure $track -speedvectorcolor black"
    $w.zinc bind $track:leader <Enter> "$w.zinc itemconfigure $track -leadercolor red"
    $w.zinc bind $track:leader <Leave> "$w.zinc itemconfigure $track -leadercolor black"

    #---------------------------------------------
    # Drag and drop the track
    #---------------------------------------------
    #Binding to ButtonPress event -> "moveOn" state#
    $w.zinc bind $track <1> { 
	::simpleInteractionTrack::selectColorOn
	::simpleInteractionTrack::moveOn %x %y
    }

    bind $w.zinc <greater> {
      %W itemconfigure $::simpleInteractionTrack::track -labelangle \
          [expr 10 + [%W itemcget $::simpleInteractionTrack::track -labelangle]]
    }
    bind $w.zinc <less> {
      %W itemconfigure $::simpleInteractionTrack::track -labelangle \
          [expr 10 - [%W itemcget $::simpleInteractionTrack::track -labelangle]]
    }
    focus $w.zinc

    #"moveOn" state#
    proc moveOn {x y} {
	variable track
	variable w
	variable xi
	variable yi

	set xi $x
	set yi $y

	#ButtonPress event not allowed on track
	$w.zinc bind $track <ButtonPress-1> ""
	#Binding to Motion event -> move the track#
	$w.zinc bind $track <Motion> "::simpleInteractionTrack::bindMotion %x %y" 

	#Binding to ButtonRelease event -> "moveOff" state#
	$w.zinc bind $track <ButtonRelease-1> {
	    ::simpleInteractionTrack::selectColorOff 
	    ::simpleInteractionTrack::moveOff 
	} 
    }

    proc bindMotion { x y} {
	variable xi
	variable yi

	move $xi $yi $x $y

	set xi $x
	set yi $y
    }

    #"moveOff" state#
    proc moveOff {} {
	variable track
	variable w
	#Binding to ButtonPress event -> "moveOn" state#
	$w.zinc bind $track <ButtonPress-1> { 
	    ::simpleInteractionTrack::selectColorOn
	    ::simpleInteractionTrack::moveOn %x %y 
	}

	
	#Motion event not allowed on track
	$w.zinc bind $track <Motion> "" 
	#ButtonRelease event not allowed on track
	$w.zinc bind $track <ButtonRelease-1> ""
    }

    #move the track#
    proc move {xi yi x y} {
	variable w
	variable track

	selectColorOn 
	foreach {X1 Y1} [$w.zinc coords $track] break
	$w.zinc coords $track [list [expr $X1+$x-$xi] [expr $Y1+$y-$yi]]
    }


    proc selectColorOn {} {
	variable track
	variable w

	$w.zinc itemconfigure $track -speedvectorcolor white -markercolor white -leadercolor white
    }

    proc selectColorOff {} {
	variable track
	variable w

	$w.zinc itemconfigure $track -speedvectorcolor black -markercolor black -leadercolor black
    }
}
