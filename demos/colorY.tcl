# these simple samples have been developped by C. Mertz mertz@cena.fr in perl
# tcl version by Jean-Paul Imbert imbert@cena.fr

if {![info exists zincDemo]} {
    error "This script should be run from the zinc-widget demo."
}

namespace eval colorY {
    variable w .colorY
    catch {destroy $w}
    toplevel $w
    wm title $w "Zinc Color-y Demonstration"
    wm iconname $w "Color y"

    grid [button $w.dismiss -text Dismiss -command "destroy $w"] -row 2 -column 0 -pady 10
    grid [button $w.code -text "See Code" -command "showCode $w"] -row 2 -column 1 -pady 10

    variable defaultfont [font create -family Helvetica -size 14 -weight normal]

    grid [zinc $w.zinc -width 700 -height 600 -borderwidth 3 -relief sunken -render 1] \
	-row 1 -column 0 -columnspan 2 -sticky news
    grid columnconfigure $w 0 -weight 1
    grid columnconfigure $w 1 -weight 1
    grid rowconfigure $w 1 -weight 2

    $w.zinc add rectangle 1 {10 10 690 100} -fillcolor {=axial 90|red|blue} -filled 1

    $w.zinc add text 1 -font $defaultfont -anchor nw -position {20 20} \
	-text "A variation from non transparent red to non transparent blue.\n"

    $w.zinc add rectangle 1 {10 110 690 200} -fillcolor {=axial 90|red;40|blue;40} -filled 1

    $w.zinc add text 1 -font $defaultfont -anchor nw -position {20 120} \
	-text "A variation from 40%transparent red to 40% transparent blue."

    $w.zinc add rectangle 1 {10 210 690 300} -fillcolor {=axial 90|red;40|green;40 50|blue;40} -filled 1

    $w.zinc add text 1 -font $defaultfont -anchor nw -position {20 220} \
	-text "A variation from 40%transparent red to 40% transparent blue.\nthrough a 40%green on the middle"

    $w.zinc add text 1 -font $defaultfont -anchor nw -position {20 320} \
	-text "Two overlaping transparently colored rectangles on a white background"

    $w.zinc add rectangle 1 {10 340 690 590} -fillcolor white -filled  1
    $w.zinc add rectangle 1 {200 350 500 580} -fillcolor {=axial 90|red;40|green;40 50|blue;40} -filled 1

    $w.zinc add rectangle 1 {10 400 690 500} -fillcolor {=axial 90|yellow;40|black;40 50|cyan;40} -filled 1
}
