lappend auto_path ..

package require Tkzinc
package require Img

set mask "/usr/X11R6/include/X11/bitmaps/fvwm.xbm"

set r [zinc .r -backcolor gray -relief sunken \
	-insertbackground red -insertwidth 10 -render 0]
pack .r -expand t -fill both
.r configure -width 800 -height 500
# .r configure -drawbboxes t
set top [.r add group 1]
.r addtag controls withtag $top

.r add rectangle $top "-50 0 +50 1" -composescale 0
.r add rectangle $top "0 -50 1 +50" -composescale 0

set x 50.0
set y 100.0
.r add text $top -text "Ancrage Sud Ouest" -position "$x $y" -anchor sw \
	-color yellow
.r add rectangle $top [list [expr $x - 3.0] [expr $y - 3.0] \
	[expr $x + 3.0] [expr $y + 3.0]] -filled 1 -fillcolor red

set x [expr $x + 200.0]
.r add text $top -text "Ancrage Sud" -position "$x $y" -anchor s -color pink
.r add rectangle $top [list [expr $x - 3.0] [expr $y - 3.0] \
	[expr $x + 3.0] [expr $y + 3.0]] -filled 1 -fillcolor red

set x [expr $x + 200.0]
.r add text $top -text "Ancrage Sud Est" -position "$x $y" -anchor se \
	-color violet -overstriked y
.r add rectangle $top [list [expr $x - 3.0] [expr $y - 3.0] \
	[expr $x + 3.0] [expr $y + 3.0]] -filled 1 -fillcolor red

set x 50
set y 150
.r add text $top -text "Ancrage Ouest" -position "$x $y" -anchor w -color lightblue
.r add rectangle $top [list [expr $x - 3.0] [expr $y - 3.0] \
	[expr $x + 3.0] [expr $y + 3.0]] -filled 1 -fillcolor red

set x [expr $x + 200.0]
.r add text $top -text "Ancrage Central" -position "$x $y" -anchor center -color blue
.r add rectangle $top [list [expr $x - 3.0] [expr $y - 3.0] \
	[expr $x + 3.0] [expr $y + 3.0]] -filled 1 -fillcolor red

set x [expr $x + 200.0]
.r add text $top -text "Ancrage Est" -position "$x $y" -anchor e -color darkblue
.r add rectangle $top [list [expr $x - 3.0] [expr $y - 3.0] \
	[expr $x + 3.0] [expr $y + 3.0]] -filled 1 -fillcolor red

set x 50.0
set y 200.0
.r add text $top -text "Ancrage Nord Ouest" -position "$x $y" -anchor nw \
	-color violet -underlined y
.r add rectangle $top [list [expr $x - 3.0] [expr $y - 3.0] \
	[expr $x + 3.0] [expr $y + 3.0]] -filled 1 -fillcolor red

set x [expr $x + 200.0]
.r add text $top -text "Ancrage Nord" -position "$x $y" -anchor n -color pink
.r add rectangle $top [list [expr $x - 3.0] [expr $y - 3.0] \
	[expr $x + 3.0] [expr $y + 3.0]] -filled 1 -fillcolor red

set x [expr $x + 200.0]
.r add text $top -text "Ancrage Nord Est" -position "$x $y" -anchor ne -color yellow
.r add rectangle $top [list [expr $x - 3.0] [expr $y - 3.0] \
	[expr $x + 3.0] [expr $y + 3.0]] -filled 1 -fillcolor red

set x 150
set y 300
.r add text $top -text "Ce texte tient sur plusieurs lignes.\nLes alignements :\n- à gauche\n- à droite\n- au centre\nsont également mis en évidence.\n" -position "$x $y" -anchor center
.r add rectangle $top [list [expr $x - 3.0] [expr $y - 3.0] \
	[expr $x + 3.0] [expr $y + 3.0]] -filled 1 -fillcolor red

set x 400
set y 300
set anim [.r add text $top -text "Ce texte tient sur plusieurs lignes.\nLes alignements :\n- à gauche\n- à droite\n- au centre\nsont également mis en évidence.\nLe texte central montre l'utilisation\nd'un espacement des lignes programmable." -position "$x $y" -anchor center -alignment center -spacing -5 -font {times 14 bold italic}]
.r add rectangle $top [list [expr $x - 3.0] [expr $y - 3.0] \
	[expr $x + 3.0] [expr $y + 3.0]] -filled 1 -fillcolor red

set x 650
set y 300
.r add text $top -text "Ce texte tient sur plusieurs lignes.\nLes alignements :\n- à gauche\n- à droite\n- au centre\nsont également mis en évidence.\n" -position "$x $y" -anchor center -alignment right
.r add rectangle $top [list [expr $x - 3.0] [expr $y - 3.0] \
	[expr $x + 3.0] [expr $y + 3.0]] -filled 1 -fillcolor red


.r addtag text withtype text
.r bind text "<1>" {textB1press %x %y}
.r bind text "<B1-Motion>" {textB1move %x %y}
.r bind text "<Shift-B1-Motion>" {textB1move %x %y}
.r bind text "<Shift-1>" {.r select adjust current @%x,%y}
.r bind text "<KeyPress>" {.r insert [.r focus] insert %A}
.r bind text "<Shift-KeyPress>" {.r insert [.r focus] insert %A}
.r bind text "<Return>" {.r insert [.r focus] insert \n}
.r bind text "<Control-h>" textBs
.r bind text "<BackSpace>" textBs
.r bind text "<Delete>" textBs
.r bind text "<Control-d>" {.r dchars text sel.first sel.last}
.r bind text "<Control-v>" {.r insert [.r focus] insert [selection get]}

proc textB1press {x y} {
    .r cursor current "@$x,$y"
    .r focus current
    focus .r
    .r select from current "@$x,$y"
}

proc textB1move {x y} {
    .r select to current "@$x,$y"
}

proc textBs { } {
    set item [.r focus]
    set i [expr [.r index $item insert] - 1]
    if { $i >= 0 } {
	.r dchars $item $i
    }
}

#
# Add controls to the main group
#
source controls.tcl

#
# Line spacing animation (crude).
#
if {0} {
    set i 0
    while {1} {
	update
	after 200
	.r itemconfigure $anim -spacing [expr ($i % 20) - 5]
	incr i
    }
}
