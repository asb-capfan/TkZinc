# these simple samples have been developped by C. Mertz mertz@cena.fr in perl
# tcl version by Jean-Paul Imbert imbert@cena.fr

if {![info exists zincDemo]} {
    error "This script should be run from the zinc-widget demo."
}

namespace eval linesDemo {
    variable w .lines
    catch {destroy $w}
    toplevel $w
    wm title $w "Zinc Lines Demonstration"
    wm iconname $w Lines
    
    grid [button $w.dismiss -text Dismiss -command "destroy $w"] -row 2 -column 0 -pady 10
    grid [button $w.code -text "See Code" -command "showCode $w"] -row 2 -column 1 -pady 10
    
    variable defaultfont [font create -family Helvetica -size 14 -weight normal]
    
    grid [zinc $w.zinc -width 700 -height 600 -font $defaultfont -borderwidth 3 \
	      -relief sunken] -row 1 -column 0 -columnspan 2 -sticky news
    grid columnconfigure $w 0 -weight 1
    grid columnconfigure $w 1 -weight 1
    grid rowconfigure $w 1 -weight 2
    
    $w.zinc add text 1 -font $defaultfont -anchor nw -position {20 20} \
-text "A set of lines with different styles of lines and termination\nNB: some attributes such as line styles are not necessarily\navailable with an openGL rendering system"
    
    $w.zinc add curve 1 {20 100 320 100}
    $w.zinc add curve 1 {20 120 320 120} -linewidth 20
    
    $w.zinc add curve 1 {20 160 320 160} -linewidth 20 -capstyle butt
    
    $w.zinc add curve 1 {20 200 320 200} -linewidth 20 -capstyle projecting
    
    $w.zinc add curve 1 {20 240 320 240} -linewidth 20 -linepattern AlphaStipple7 -linecolor red
    
    
    # right column
    $w.zinc add curve 1 {340 100 680 100} -firstend {10 10 10} -lastend {10 25 45}
    
    $w.zinc add curve 1 {340 140 680 140} -linewidth 2 -linestyle dashed
    
    $w.zinc add curve 1 {340 180 680 180} -linewidth 4 -linestyle mixed
    
    $w.zinc add curve 1 {340 220 680 220} -linewidth 2 -linestyle dotted
    
    
    $w.zinc add curve 1 {20 300 140 360 320 300 180 260} -closed 1 -filled 1 -fillpattern "" \
	-fillcolor grey60 -linecolor red -marker AtcSymbol7 -markercolor blue
    
    
    $w.zinc add curve 1 {340 300 440 360 620 300 480 260} -closed 1 -linewidth 10 -joinstyle miter \
	-linecolor red
    
    $w.zinc add curve 1 {400 300 440 330 560 300 480 280} -closed 1 -linewidth 10 -joinstyle round \
	-tile "" -fillcolor grey60 -filled 1 -linecolor red
}
