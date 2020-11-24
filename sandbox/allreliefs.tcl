# $Id$
# these simple samples have been developped by C. Mertz mertz@cena.fr and N. Banoun banoun@cena.fr

lappend auto_path [file join [file dirname [info script]] ..]
package require Tkzinc

set defaultfont "-adobe-helvetica-bold-r-normal-*-100-*-*-*-*-*-*"
zinc .z -width 700 -height 300 -render 1 -backcolor gray
pack .z

set grp [.z add group 1]
.z add rectangle $grp {0 0 70 50} -filled 1 -fillcolor tan -linecolor tan \
    -linewidth 6 -relief raised -tags attrs
.z add text $grp -text raised -anchor center -font $defaultfont \
    -position {35 -10} -tags texts
.z translate $grp 20 30

set i 1
foreach s {sunken ridge groove roundraised roundsunken roundridge roundgroove raisedrule sunkenrule} {
    set grp [.z clone $grp]
    .z itemconfigure "$grp.texts" -text $s
    .z itemconfigure "$grp.attrs" -relief $s
    incr i
    if {$i == 5} {
	.z translate $grp [expr -3*100] 80
	set i 1
    } else {
	.z translate $grp 100 0
    }
}
