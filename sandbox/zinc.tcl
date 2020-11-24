lappend auto_path .

package require Tkzinc
package require Img

set top 1

#memory info
#memory trace on
#memory validate on

image create photo logo -file logo.gif
image create photo logosmall -file logo.gif
#image create photo bois -file texture-bois1.xpm

#set r [zinc .r -backcolor gray -relief sunken -tile bois]
set r [zinc .r -backcolor gray -relief sunken]
pack .r -expand t -fill both
set scale 1.0
set centerX 0.0
set centerY 0.0
set zincWidth 800
set zincHeight 500
#.r configure -width $zincWidth -height $zincHeight
#.r configure -drawbboxes t
set view [.r add group $top -tags "controls"]

frame .rc
button .rc.up -text "Up" \
	-command {set centerY [expr $centerY+30.0]; updateTransform .r}
button .rc.down -text "Down" \
	-command {set centerY [expr $centerY-30.0]; updateTransform .r}
button .rc.left -text "Left" \
	-command {set centerX [expr $centerX+30.0]; updateTransform .r}
button .rc.right -text "Right" \
	-command {set centerX [expr $centerX-30.0]; updateTransform .r}
button .rc.expand -text "Expand" \
	-command {set scale [expr $scale*1.1]; updateTransform .r}
button .rc.shrink -text "Shrink" \
	-command {set scale [expr $scale*0.9]; updateTransform .r}
button .rc.reset -text "Reset" \
	-command {set scale 1.0; set centerX 0.0; set centerY 0.0; \
	updateTransform .r}
button .rc.quit -text "Quit" -command "exit"
grid .rc.up -row 0 -column 2 -sticky ew
grid .rc.down -row 2 -column 2 -sticky ew
grid .rc.left -row 1 -column 1
grid .rc.right -row 1 -column 3
grid .rc.expand -row 1 -column 4
grid .rc.shrink -row 1 -column 0
grid .rc.reset -row 1 -column 2 -sticky ew
grid .rc.quit -row 3 -column 2
pack .rc

bind .r <Configure> "ZincStyleConfig %W %w %h"

proc ZincStyleConfig {zinc w h} {
    global zincWidth zincHeight
    
    set bw [$zinc cget -borderwidth]
    set zincWidth [expr $w - 2*$bw]
    set zincHeight [expr $h - 2*$bw]
    updateTransform $zinc
}

proc updateTransform {zinc} {
    global zincWidth zincHeight
    global scale centerX centerY
    global top
    
    $zinc treset $top
    $zinc translate $top [expr -$centerX] [expr -$centerY]
    $zinc scale $top $scale $scale
    $zinc scale $top 1 -1
    $zinc translate $top [expr $zincWidth/2] [expr $zincHeight/2]
}

#
# TRACKS
#
set track [.r add track $view 6 -tags track -leaderanchors "|0|0"]
.r itemconfigure $track -position "1 1"
.r itemconfigure $track -position "10 10"
.r itemconfigure $track -position "20 20"
.r itemconfigure $track -position "30 30"
.r itemconfigure $track -position "40 40"
.r itemconfigure $track -position "50 50"
.r itemconfigure $track -position "55 60"
.r itemconfigure $track -position "60 70"
.r itemconfigure $track -speedvector "20 0"
.r itemconfigure $track -symbolcolor salmon -speedvectorcolor salmon -leadercolor salmon \
	 -labeldistance 20
.r itemconfigure $track -markersize 20 \
	 -filledmarker 1 \
	 -markerfillpattern AlphaStipple4 \
	 -markercolor salmon
.r itemconfigure $track -labelformat "120x40 l0l0+0+0 x80x20+0+0 x40x20+80+0 x40x20+0+20 x20x20>3>2 x60x20>1>1"
.r itemconfigure $track 0 -filled 1 -backcolor gray -bordercolor gray -relief groove
.r itemconfigure $track 1 -filled 1 -backcolor tan -bordercolor tan -relief groove \
	 -font "cenapii-etiquette-m17" -text "AFR451"
.r itemconfigure $track 2 -text "WPY" \
	 -font "cenapii-etiquette-m17"
.r itemconfigure $track 3 -text "400" -filled 1 -backcolor wheat \
	 -font "cenapii-etiquette-m17"
.r itemconfigure $track 4 -text "-" -filled 1 -backcolor wheat \
	 -font "cenapii-etiquette-m17"
.r itemconfigure $track 5 -text "450" -font "cenapii-etiquette-m17"

.r bind $track:speedvector <Enter> ".r itemconfigure $track -speedvectorcolor red"
.r bind $track:speedvector <Leave> ".r itemconfigure $track -speedvectorcolor salmon"

set track2 [.r add track $view 4 -speedvector "-20 0" \
	 -symbolcolor salmon  -speedvectorcolor salmon -leadercolor salmon \
	 -labeldx -20 -labeldy 20 -leaderanchors "%30x30" \
	 -historycolor MistyRose -lastasfirst t ]
.r itemconfigure $track2 -labelformat "a3f110+0+0 a3f110>0^0 a3f110^0>0 a3f110>2>0"
.r itemconfigure $track2 0 -filled 1 -backcolor tan -text "BAW452"
.r itemconfigure $track2 1 -filled 1 -backcolor wheat -text "450"
.r itemconfigure $track2 2 -filled 1 -backcolor wheat -text "KMC"
#.r itemconfigure $track2 3 -filled 1 -backcolor wheat -text ""
.r itemconfigure $track2 -connecteditem $track -connectioncolor green
.r itemconfigure $track2 -position "10 0"
.r itemconfigure $track2 -position "-20 10"
.r itemconfigure $track2 -position "-30 20"
.r itemconfigure $track2 -position "-40 30"
.r itemconfigure $track2 -position "-50 40"
.r itemconfigure $track2 -position "-60 50"
.r itemconfigure $track2 -position "-70 50"
.r itemconfigure $track2 -position "-80 50"
.r itemconfigure $track2 -position "-90 50"

#
# WAY POINTS
#
puts "creating way points"
set wp [.r add waypoint $view 1 -tags borders]
.r itemconfigure $wp -symbolcolor bisque -leadercolor bisque  -position "-100 120" \
	 -labelformat "40x20"
.r itemconfigure $wp 0 -bordercolor bisque -text "NCY" -tile logo -filled t
set wp2 [.r add waypoint $view 1 -tags borders]
.r itemconfigure $wp2 -symbolcolor bisque \
    -leadercolor bisque  \
    -position "50 160" \
    -labelformat "40x20" \
    -connectioncolor bisque \
    -connecteditem $wp
.r itemconfigure $wp2 0 -bordercolor bisque -text "MPW"
set wp3 [.r add waypoint $view 1 -tags borders]
.r itemconfigure $wp3 -symbolcolor bisque \
    -leadercolor bisque \
    -position "200 140" \
    -labelformat "40x20" \
    -connectioncolor bisque \
    -connecteditem $wp2
.r itemconfigure $wp3 0 -bordercolor bisque -text "ART"

#
# MACROS
#
puts "creating macros"
set macro [.r add tabular $view 10 -labelformat "x40x20+0+0 x40x20+40+0" \
	       -tags f0borders -connecteditem $track]
.r itemconfigure $macro 0 -text une
.r itemconfigure $macro 1 -text macro

#
# MINISTRIPS
#
puts "creating ministrips"
set ministrip [.r add tabular $view 1 \
	-labelformat "60x20" -position "10 10"]
.r itemconfigure $ministrip 0 -text "ministrip" -sensitive f
set ministrip2 [.r add tabular $view 1 \
	-labelformat "60x20" -connecteditem $ministrip]
.r itemconfigure $ministrip2 0 -text "ministrip2" -sensitive f
set ministrip3 [.r add tabular $view 1 \
	-labelformat "60x20" -connecteditem $ministrip2]
.r itemconfigure $ministrip3 0 -text "ministrip3" -sensitive f

#
# MAPS
#
puts "creating maps"
videomap load "/usr/share/toccata/maps/videomap_paris-w_90_2" 0 paris-w
videomap load "/usr/share/toccata/maps/videomap_orly" 17 orly
videomap load "/usr/share/toccata/maps/hegias_parouest_TE.vid" 0 paris-ouest

set map [.r add map $view -color darkblue]
.r itemconfigure $map -mapinfo orly

set map2 [.r add map $view -color darkblue -filled 1 -priority 0 -fillpattern AlphaStipple1]
.r itemconfigure $map2 -mapinfo paris-ouest

set map3 [.r add map $view -color orange]

mapinfo mpessai create
mapinfo mpessai add text normal simple 0 200 "Et voilà"
mapinfo mpessai add line simple 5 0 0 100 100
mapinfo mpessai add line simple 0 100 100 0 200
mapinfo mpessai add line simple 2  -100 100 0 0
.r itemconfigure $map3 -mapinfo mpessai

#
# Clip
#
puts "crée les clips"
set clip [.r add rectangle $view "-100 -100 300 200" -filled t \
	      -linewidth 0 -fillcolor darkgray -visible f]
#.r rotate $clip [expr 3.14159 / 4]
.r lower $clip
#.r itemconfigure $view -clip $clip

.r add rectangle $top "-5 -5 5 5"  -filled t -fillcolor red
set topclip [.r add rectangle $top "-400 -400 400 400" \
		 -filled t -fillcolor lightgray -linewidth 0 -visible t]
.r lower $topclip
#.r rotate $topclip [expr 3.14159 / 4]
#.r itemconfigure $top -clip $topclip

#
# CONTROLS
#
proc borders {onoff} {
    set part [.r currentpart]
    puts "part $part $onoff"
    set contour noborder
    if { $onoff == "on" } {
	set contour "contour oblique"
    }
    if { [regexp {^[0-9]+$} $part] } {
	.r itemconfigure current $part -border $contour
    }
}

.r bind borders <Enter> "borders on"
.r bind borders <Leave> "borders off"
.r bind f0borders:0 <Enter> "borders on"
.r bind f0borders:0 <Leave> "borders off"
.r bind track <Enter> {puts "Entre dans item"}
.r bind track <Leave> {puts "Sort d'item"}
.r bind track:0 <Enter> {puts "Entre dans champ 0"}
.r bind track:0 <Leave> {puts "Sort de champ 0"}
.r bind track:1 <Enter> {puts "Entre dans champ 1"}
.r bind track:1 <Leave> {puts "Sort de champ 1"}
.r bind track:2 <Enter> {puts "Entre dans champ 2"}
.r bind track:2 <Leave> {puts "Sort de champ 2"}
.r bind track:3 <Enter> {puts "Entre dans champ 3"}
.r bind track:3 <Leave> {puts "Sort de champ 3"}

bind .r <2> {puts "%x@%y, item: [.r find atpoint %x %y]"}

proc finditems {cornerx cornery} {
    global origx origy

    puts "--- enclosed ---"
    puts "++ [.r find enclosed $origx $origy $cornerx $cornery] ++"
    puts "--- overlapping ---"
    puts "++ [.r find overlapping $origx $origy $cornerx $cornery] ++"
    puts ""
}

bind .r <ButtonPress-1> "set origx %x; set origy %y"
bind .r <ButtonRelease-1> "finditems %x %y"

.r bind all <1> { if {! [catch {.r find withtag current} item] } { \
	puts "<1> in $item" } else { puts "None" } }

#
#for {set j 0} {$j < 20} {incr j} {
#    memory info
#    for {set i 0} {$i < 10} {incr i} {
#	 set a($i) [.r add icon 1 -image logo]
#	 set b($i) [.r add rectangle 1 "10 10 1000 1000" -filled t -tile logosmall]
#	 set c($i) [.r add curve 1 "10 10 10 100 100 100" -filled t -tile logosmall]
#    }
#    for {set i 0} {$i < 10} {incr i} {
#	 .r remove $a($i)
#	 .r remove $b($i)
#	 .r remove $c($i)
#    }
#}
    
source "controls.tcl"

