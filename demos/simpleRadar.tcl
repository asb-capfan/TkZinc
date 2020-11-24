# $Id$
# This simple radar has been initially developped by P. Lecoanet <lecoanet@cena.fr>
# It has been adapted by C. Mertz <mertz@cena.fr> for demo purpose.

if {![info exists zincDemo]} {
    error "This script should be run from the zinc-widget demo."
}

namespace eval simpleRadar {
    variable rotation 0
    variable w .simpleRadar
    catch {destroy $w}
    toplevel $w
    wm title $w "Simple radar display"
    wm iconname $w SimpleRadar

    text $w.text -relief sunken -borderwidth 2 -height 11
    pack $w.text -expand yes -fill both

    $w.text insert end {This a very simple radar display, where you can see flight tracks,
	a so-called ministrip (green) and and extend flight label (tan background).
	The following operations are possible:
	Shift-Button 1 for using a square lasso (result in the terminal).
	Click Button 2 for identifiying the closest item (result in the terminal).
	Button 3 for dragging most items, but not the ministrip (not in the same group).
	Shift-Button 3 for zooming independently on X and Y axis.
	Ctrl-Button 3 for rotating graphic objects.
	Enter/Leave in flight label fields, speed vector, position and leader,
	and in the ministrip fields.
	Click Button 1 on flight track to display a route.}



    #-------------------------------------------------
    # Create zinc
    #-------------------------------------------------
    variable top 1
    variable scale 1.0
    variable centerX 0.0
    variable centerY 0.0
    variable zincWidth 800
    variable zincHeight 500
    variable delay 2000
    variable rate 0.3
    array unset tracks
    # if true the flights are no more moving
    variable pause 0

#    zinc $w.zinc -render 1 -enablerotation 1 -backcolor gray65 -relief sunken -font 10x20 \
#      -width $zincWidth -height $zincHeight
    zinc $w.zinc -render 1 -backcolor gray65 -relief sunken -font 10x20 \
      -width $zincWidth -height $zincHeight
    pack $w.zinc -expand 1 -fill both

    $w.zinc add group $top -tags {controls radar}
    $w.zinc configure -overlapmanager [$w.zinc find withtag radar]

#    bind $w.zinc <Alt-1> {
#      incr ::simpleRadar::rotation 10
#      %W configure -screenrotation $::simpleRadar::rotation
#    }
#    bind $w.zinc <Alt-3> {
#      incr ::simpleRadar::rotation -10
#      %W configure -screenrotation $::simpleRadar::rotation
#    }

    #-------------------------------------------------
    # Create control panel
    #-------------------------------------------------
    frame $w.f
    pack $w.f
    button $w.f.up -text Up -command "::simpleRadar::Up $w.zinc"
    grid $w.f.up -row 0 -column 2 -sticky ew
    button $w.f.down -text Down -command "::simpleRadar::Down $w.zinc"
    grid $w.f.down -row 2 -column 2 -sticky ew
    button $w.f.left -text Left -command "::simpleRadar::Left $w.zinc"
    grid $w.f.left -row 1 -column 1
    button $w.f.right -text Right -command "::simpleRadar::Right $w.zinc"
    grid $w.f.right -row 1 -column 3
    button $w.f.expand -text Expand -command "::simpleRadar::Expand $w.zinc"
    grid $w.f.expand -row 1 -column 4
    button $w.f.shrink -text Shrink -command "::simpleRadar::Shrink $w.zinc"
    grid $w.f.shrink -row 1 -column 0
    button $w.f.reset -text Reset -command "::simpleRadar::Reset $w.zinc"
    grid $w.f.reset -row 1 -column 2 -sticky ew
    button $w.f.pause -text Pause -command "::simpleRadar::Pause $w.zinc"
    grid $w.f.pause -row 0 -column 6

    #--------------------------------------------------
    # Resize handling code
    #--------------------------------------------------
    bind $w.zinc <Configure> "::simpleRadar::resize $w.zinc %w %h"

    proc Up {z} {
	variable centerY
	set centerY [expr $centerY - 30.0]
	updateTransform $z
    }

    proc Down {z} {
	variable centerY
	set centerY [expr $centerY + 30.0]
	updateTransform $z
    }

    proc Left {z} {
	variable centerX
	set centerX [expr $centerX + 30.0]
	updateTransform $z
    }

    proc Right {z} {
	variable centerX
	set centerX [expr $centerX - 30.0]
	updateTransform $z
    }

    proc Expand {z} {
	variable scale
	set scale [expr $scale * 1.1]
	updateTransform $z
    }

    proc Shrink {z} {
	variable scale
	set scale [expr $scale * 0.9]
	updateTransform $z
    }

    proc Reset {z} {
	variable centerX
	variable centerY
	variable scale
	set scale 1.0
	set centerX 0.0
	set centerY 0.0
	updateTransform $z
    }

    proc Pause {z} {
	variable pause
	set pause [expr ! $pause]
    }

    proc resize {z w h} {
	variable zincWidth
	variable zincHeight

	set bw [$z cget -borderwidth]
	set zincWidth [expr $w - 2 * $bw]
	set zincHeight [expr $h - 2 * $bw]
	updateTransform $z
    }

    proc updateTransform {z} {
	variable centerX
	variable centerY
	variable zincWidth
	variable zincHeight
	variable scale

	$z treset 1
	$z translate 1 [expr -$centerX] [expr -$centerY]
	$z scale 1 $scale $scale
	$z scale 1 1 -1
#  set hVirtualSize [expr hypot($zincWidth, $zincHeight)/2]
#	$z translate 1 $hVirtualSize $hVirtualSize
	$z translate 1 [expr $zincWidth/2] [expr $zincHeight/2]
    }

    #------------------------------------------------
    # Create the tracks
    #------------------------------------------------
    proc createTracks {z} {
	variable oneTrack
	variable zincWidth
	variable zincHeight
	variable scale
	variable centerX
	variable centerY
	variable tracks

	set w [expr $zincWidth / $scale]
	set h [expr $zincHeight / $scale]
	
	set allTracks {}

	set bOn "$z itemconfigure current \[$z currentpart\] -border contour"
	set bOff "$z itemconfigure current \[$z currentpart\] -border noborder"

	for {set i 20} {$i > 0} {incr i -1} {
	    set item [$z add track radar 6 -lastasfirst 1]
	    lappend allTracks $item
	    set oneTrack $item

	    set tracks($item,x) [expr rand()*$w - $w/2 + $centerX]
	    set tracks($item,y) [expr rand()*$h - $h/2 + $centerY]
	    set d [expr (rand() > 0.5) ? 1 : -1]
	    set tracks($item,vx) [expr (8.0 + rand()*10.0) * $d]
	    set d [expr (rand() > 0.5) ? 1 : -1]
	    set tracks($item,vy) [expr (8.0 + rand()*10.0) * $d]
	    $z itemconfigure $item -position "$tracks($item,x) $tracks($item,y)" -circlehistory 1 \
		-speedvector "$tracks($item,vx) $tracks($item,vy)" -speedvectorsensitive 1 \
		-labeldistance 30 -markersize 20 -historycolor white -filledhistory 0 \
		-labelformat {x80x60+0+0 x63a0^0^0 x33a0^0>1 a0a0>2>1 x33a0>3>1 a0a0^0>2}
	    $z itemconfigure $item 0 -filled 0 -backcolor gray60 -sensitive 1
	    $z itemconfigure $item 1 -filled 1 -backcolor gray55 -text [format {AFR%03i} $i]
	    $z itemconfigure $item 2 -filled 0 -backcolor gray65 -text 360
	    $z itemconfigure $item 3 -filled 0 -backcolor gray65 -text /
	    $z itemconfigure $item 4 -filled 0 -backcolor gray65 -text 410
	    $z itemconfigure $item 5 -filled 0 -backcolor gray65 -text Balise

	    for {set j 0} {$j < 6} {incr j} {
		$z bind $item:$j <Enter> $bOn
		$z bind $item:$j <Leave> $bOff
		$z bind $item <1> "::simpleRadar::fieldSensitivity $z"
		$z bind $item <Shift-1> {}
	    }
	    $z bind $item <Enter> [list $z itemconfigure current -historycolor red3 \
				       -symbolcolor red3 -markercolor red3 -leaderwidth 2 \
				       -leadercolor red3 -speedvectorwidth 2 -speedvectorcolor red3]
	    $z bind $item <Leave> [list $z itemconfigure current -historycolor white \
				       -symbolcolor black -markercolor black -leaderwidth 1 \
				       -leadercolor black -speedvectorwidth 1 -speedvectorcolor black]
	    $z bind $item:position <1> "::simpleRadar::createRoute $z"
	    $z bind $item:position <Shift-1> {}
	    set tracks($item,route) 0
	}

	set tracks(all) $allTracks
    }

    createTracks $w.zinc

    #---------------------------------------------------
    # Create route way points
    #---------------------------------------------------
    proc createRoute {z} {
	variable tracks

	set track [$z find withtag current]

	if { $tracks($track,route) == 0 } {
	    set x [expr $tracks($track,x) + 8.0 * $tracks($track,vx)]
	    set y [expr $tracks($track,y) + 8.0 * $tracks($track,vy)]
	    set connected $track
	    for {set i 4} {$i > 0} {incr i -1} {
		set wp [$z add waypoint radar 2 -position "$x $y" -labelformat x20x18+0+0 \
			    -connecteditem $connected -connectioncolor green -symbolcolor green]
		$z lower $wp $connected
		$z bind $wp:0 <Enter> "$z itemconfigure current 0 -border contour"
		$z bind $wp:position <Enter> "$z itemconfigure current -symbolcolor red"
		$z bind $wp:leader <Enter> "$z itemconfigure current -leadercolor red"
		$z bind $wp:connection <Enter> "$z itemconfigure current -connectioncolor red"
		$z bind $wp:0 <Leave> "$z itemconfigure current 0 -border noborder"
		$z bind $wp:position <Leave> "$z itemconfigure current -symbolcolor green"
		$z bind $wp:leader <Leave> "$z itemconfigure current -leadercolor black"
		$z bind $wp:connection <Leave> "$z itemconfigure current -connectioncolor green"
		$z itemconfigure $wp 0 -text $i -filled 1 -backcolor gray55
		$z bind $wp:position <1> "::simpleRadar::delWaypoint $z"
		set x [expr $x + (2.0 + rand()*8.0) * $tracks($track,vx)]
		set y [expr $y + (2.0 + rand()*8.0) * $tracks($track,vy)]
		set connected $wp
	    }
	    set tracks($track,route) $wp
	} else {
	    set wp $tracks($track,route)
	    while { $wp != $track } {
		set tracks($track,route) [$z itemcget $wp -connecteditem]
		$z bind $wp:position <1> {}
		$z bind $wp:position <Enter> {}
		$z bind $wp:position <Leave> {}
		$z bind $wp:leader <Enter> {}
		$z bind $wp:leader <Leave> {}
		$z bind $wp:connection <Enter> {}
		$z bind $wp:connection <Leave> {}
		$z bind $wp:0 <Enter> {}
		$z bind $wp:0 <Leave> {}
		$z remove $wp
		set wp $tracks($track,route)
	    }
	    set tracks($track,route) 0
	}
    }

    #-----------------------------------------------------
    # Toggle current field sensitivity
    #-----------------------------------------------------
    proc fieldSensitivity {z} {
	set curPart [$z currentpart]
	if { [regexp {[0-9]+} $curPart] } {
	    set onOff [$z itemcget current $curPart -sensitive]
	    $z itemconfigure current $curPart -sensitive [expr !$onOff]
	}
    }

    #-----------------------------------------------------
    # Removal of a route Waypoint
    #-----------------------------------------------------
    proc findTrack {z wp} {
	set connected $wp
	
	while { [$z type $connected] != "track" } {
	    set connected [$z itemcget $connected -connecteditem]
	}
	return $connected
    }

    proc delWaypoint {z} {
	variable tracks

	set wp [$z find withtag current]
	set track [findTrack $z $wp]
	set next [$z itemcget $wp -connecteditem]

	set prev $tracks($track,route)
	if { $prev != $wp } {
	    set prevnext [$z itemcget $prev -connecteditem]
	    while { $prevnext != $wp } {
		set prev $prevnext
		set prevnext [$z itemcget $prev -connecteditem]
	    }
	}
	$z itemconfigure $prev -connecteditem $next
	$z bind $wp:position <1> {}
	$z remove $wp
	if { $wp == $tracks($track,route) } {
	    if { $next == $track } {
		set tracks($track,route) 0
	    } else {
		set tracks($track,route) $next
	    }
	}
    }


    #---------------------------------------------
    # Create a macro
    #---------------------------------------------
    set macro [$w.zinc add tabular radar 10 -labelformat {x73x20+0+0 x20x20+0+0 x53x20+20+0}]
    $w.zinc itemconfigure $macro 0 -backcolor tan1 -filled 1 -fillpattern AlphaStipple7 \
	-bordercolor red3
    $w.zinc itemconfigure $macro 1 -text a
    $w.zinc itemconfigure $macro 2 -text macro
    $w.zinc itemconfigure $macro -connecteditem $oneTrack
    foreach part {0 1 2} {
	$w.zinc bind $macro:$part <Enter> "::simpleRadar::borders $w.zinc 1"
	$w.zinc bind $macro:$part <Leave> "::simpleRadar::borders $w.zinc 0"
    }

    proc borders {z on} {
	if { $on } {
	    set contour contour
	} else {
	    set contour noborder
	}
	$z itemconfigure current 0 -border $contour
    }

    #---------------------------------------------
    # Create a ministrip
    #---------------------------------------------
    set ministrip [$w.zinc add tabular 1 10 -position {100 10} \
		       -labelformat {x153x80^0^0 x93x20^0^0 x63a0^0>1 a0a0>2>1 x33a0>3>1 a0a0^0>2}]
    $w.zinc itemconfigure $ministrip 0 -filled 1 -backcolor grey70 -border contour -bordercolor green
    $w.zinc itemconfigure $ministrip 1 -text ministrip -color darkgreen -backcolor grey40
    $w.zinc itemconfigure $ministrip 2 -text field1 -color darkgreen -backcolor grey40
    $w.zinc itemconfigure $ministrip 3 -text field2 -color darkgreen -backcolor grey40
    $w.zinc itemconfigure $ministrip 4 -text f3 -color darkgreen -backcolor grey40
    $w.zinc itemconfigure $ministrip 5 -text field4 -color darkgreen -backcolor grey40

    foreach field {1 2 3 4 5} {
	$w.zinc bind $ministrip:$field <Enter> \
	    "$w.zinc itemconfigure current $field -border contour -filled 1 -color white"
	$w.zinc bind $ministrip:$field <Leave> \
	    "$w.zinc itemconfigure current $field -border noborder -filled 0 -color darkgreen"
    }

    #-------------------------------------------
    # Create some maps
    #-------------------------------------------
    set dataDir [file join [file dirname [info script]] data]
    videomap load [file join $dataDir videomap_paris-w_90_2] 0 paris-w
    videomap load [file join $dataDir videomap_orly] 17 orly
    videomap load [file join $dataDir hegias_parouest_TE.vid] 0 paris-ouest

    $w.zinc add map radar -color gray80 -mapinfo orly
    $w.zinc add map radar -color gray60 -filled 1 -priority 0 \
	-fillpattern AlphaStipple6 -mapinfo paris-ouest
    $w.zinc add map radar -color gray50 -mapinfo paris-w


    #--------------------------------------------
    # Animate tracks along their trajectories
    #--------------------------------------------
    variable timer [after $delay "::simpleRadar::refresh $w.zinc"]
    bind $w.zinc <Destroy> {puts {canceling timer}; after cancel $::simpleRadar::timer}

    proc refresh {z} {
	variable pause 
	variable timer
	variable delay
	variable tracks
	variable rate

	set timer [after $delay "::simpleRadar::refresh $z"]

	if { ! $pause } {
	    foreach t $tracks(all) {
		set tracks($t,x) [expr $tracks($t,x) + $tracks($t,vx) * $rate]
		set tracks($t,y) [expr $tracks($t,y) + $tracks($t,vy) * $rate]
		$z itemconfigure $t -position [list $tracks($t,x) $tracks($t,y)]
	    }
	}
    }
}
