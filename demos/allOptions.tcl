# these simple samples have been developped by C. Mertz mertz@cena.fr in perl
# tcl version by Jean-Paul Imbert imbert@cena.fr

if {![info exists zincDemo]} {
    error "This script should be run from the zinc-widget demo."
}

namespace eval allOptions {
    variable w .allOptions
    catch {destroy $w}
    toplevel $w
    wm title $w "Zinc All Option Demonstration"
    wm iconname $w "All options"

    frame $w.buttons
    pack $w.buttons -side bottom -fill x -pady 2m
    button $w.buttons.dismiss -text Dismiss -command "destroy $w"
    button $w.buttons.code -text "See Code" -command "showCode $w"
    pack $w.buttons.dismiss $w.buttons.code -side left -expand 1

    # The explanation displayed when running this demo
    label $w.label -justify left -text {Click on one of the following
	buttons to get a list of Item
	attributes (or zinc options)
	with their types.}

    pack $w.label -padx 10 -pady 10


    # Creating the zinc widget
    zinc $w.zinc -width 1 -height 1 -borderwidth 0 -relief sunken
    pack $w.zinc

    # Creating an instance of every item type

    variable itemTypes
    # These Items have fields! So the number of fields must be given at creation time
    foreach type {tabular track waypoint} {
	set itemTypes($type)  [$w.zinc add $type 1 0]
    }

    # These items needs no specific initial values
    foreach type {group icon map reticle text window} {
	set itemTypes($type) [$w.zinc add $type 1]
    }

    # These items needs some coordinates at creation time
    # However curves usually needs more than 2 points.
    foreach type {arc curve rectangle} {
	set itemTypes($type) [$w.zinc add $type 1 {0 0 1 1}]
    }

    # Triangles item needs at least 3 points for the coordinates 
    foreach type {triangles} {
	set itemTypes($type) [$w.zinc add $type 1 {0 0 1 1 2 2}]
    }

    proc showAllOptions { w type} {
	variable itemTypes

	if [winfo exists .tl] {destroy .tl}
	toplevel .tl
	if {[string compare $type zinc]==0} {
	    set options  [$w.zinc configure]
	    set typeopt optionClass
	    set readopt defaultValue
	    set readoff 3
	    set  title  {All options of zinc widget}
	} else {
	    set options  [$w.zinc itemconfigure $itemTypes($type)];
	    set title  "All attributes of an $type item"
	    set typeopt Type
	    set readopt ReadOnly
	    set readoff 2
	}

	wm title .tl $title

	frame .tl.f1
	set bgcolor ivory

	label .tl.f1.opt -text Option -background $bgcolor -relief ridge -width 20
	label .tl.f1.typ -text $typeopt -background $bgcolor -relief ridge -width 20
	label .tl.f1.rd -text $readopt  -background $bgcolor -relief ridge -width 21

	pack .tl.f1.opt .tl.f1.typ  .tl.f1.rd -side left
	set nbelem [llength $options]
	frame .tl.f2
	listbox .tl.f2.l1 -width 20 -height $nbelem
	listbox .tl.f2.l2 -width 20 -height $nbelem
	listbox .tl.f2.l3 -width 20 -height $nbelem
	pack .tl.f2.l1 .tl.f2.l2 .tl.f2.l3 -side left
	pack .tl.f1 .tl.f2 -side top -anchor nw

	# Remplissage des list box
	foreach elem $options {
	    .tl.f2.l1 insert end [lindex $elem 0]
	    .tl.f2.l2 insert end [lindex $elem 1]
	    .tl.f2.l3 insert end [lindex $elem $readoff]
	}
    }

    pack [frame $w.col]

    variable width 0
    foreach type [lsort [array names itemTypes]] {
	if {[string length $type] > $width} {
	    set width  [string length $type]
	}
    }

    foreach type [lsort [array names itemTypes]] {
	button $w.col.$type -text "$type" -width $width -command "::allOptions::showAllOptions $w $type"
	pack $w.col.$type -pady 4

    }

    button $w.col.b -text "zinc widget options" -command "::allOptions::showAllOptions $w zinc"
    pack $w.col.b -pady 4
}

