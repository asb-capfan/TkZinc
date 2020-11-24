# these simple samples have been developped by C. Mertz mertz@cena.fr and N. Banoun banoun@cena.fr
# tcl version by Jean-Paul Imbert imbert@cena.fr

if {![info exists zincDemo]} {
    error "This script should be run from the zinc-widget demo."
}

namespace eval trianglesDemo {
    variable w .triangles
    catch {destroy $w}
    toplevel $w
    wm title $w "Zinc Triangles Demonstration"
    wm iconname $w Triangles

    grid [button $w.dismiss -text Dismiss -command "destroy $w"] -row 2 -column 0 -pady 10
    grid [button $w.code -text "See Code" -command "showCode $w"] -row 2 -column 1 -pady 10

    variable defaultfont [font create -family Helvetica -size 16 -weight normal]

    grid [zinc $w.zinc -width 700 -height 300 -font $defaultfont -render 1 -borderwidth 3 -relief sunken] \
	-row 1 -column 0 -columnspan 2 -sticky news
    grid columnconfigure $w 0 -weight 1
    grid columnconfigure $w 1 -weight 1
    grid rowconfigure $w 1 -weight 2
 

    # 6 equilateral triangles around a point 
    $w.zinc add text 1 -position {40 10} -text "Triangles item without transparency"

    variable x0 200 
    variable y0 150
    variable coords [list "$x0 $y0"]
    for {set i 0} {$i<=6} {incr i} {
	set angle [expr $i * 6.28/6]
	lappend coords "[expr $x0 + 100 * cos($angle)] [expr $y0 - 100 * sin ($angle)]"
    }

    set tr1 [$w.zinc add triangles 1 $coords -fan 1 -colors {white yellow red magenta blue cyan green yellow} -visible 1]


    $w.zinc add text 1 -position {370 10} -text "Triangles item with transparency"


    # using the clone method to make a copy and then modify the clone"colors
    set tr2 [$w.zinc clone $tr1]
    $w.zinc translate $tr2 300 0
    $w.zinc itemconfigure $tr2 -colors {white;50 yellow;50 red;50 magenta;50 blue;50 cyan;50 green;50 yellow;50}
}
