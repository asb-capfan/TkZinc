#!/usr/local/bin/wish -f

load ../tkzinc3.2.so
package require Img

set top 1

#image create photo logo -file logo.gif
#image create photo papier -file texture-paper.xpm
#image create photo penguin -file xpenguin.png
#image create photo papier -file texture-paper.xpm

set r [zinc .r -backcolor gray -relief sunken -render 0]
pack .r -expand t -fill both
.r configure -width 800 -height 500
#.r configure -drawbboxes t
.r scale $top 1 -1
set view [.r add group $top -tags "controls"]
.r translate $view 200 -200
set view2  [.r add group $top]
.r translate $view2 300 -200

set arc [.r add arc $view "50 -10 200 -100" -filled t -closed t -pieslice t \
	-fillcolor "white|darkslateblue" -linewidth 1 \
	-startangle 0 -extent 120]
#set arc [.r add arc $view "50 -10 200 -100" -filled t -closed t -pieslice t -fillcolor "#ff0000|#00ff00" -linewidth 0]
#.r add arc $view "60 -20 190 -90" -filled t -closed t -pieslice t -fillcolor "white|darkslateblue" -linewidth 1 -linecolor white

#set arc2 [.r clone $arc -linecolor red -firstend "8 10 5"]
#.r rotate $arc2 10
#.r translate $arc2 100 -100

#.r add icon $view2 -image penguin
set cliparc [.r add arc $view "-100 100 100 -100" -filled t \
	-fillcolor tan ]
.r lower $cliparc
#.r rotate $cliparc 20 0 0
#.r translate $cliparc 100 -40
#.r itemconfigure $view2 -clip $cliparc
bind .r <1> ".r rotate $cliparc [expr 3.14/3] 0 0"
source "controls.tcl"
.r bind $cliparc <1> {puts a}
puts "[ .r bind  $cliparc <1> ]\n"

