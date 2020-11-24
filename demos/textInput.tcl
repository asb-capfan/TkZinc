# these simple samples have been developped by C. Mertz mertz@cena.fr in perl
# tcl version by Jean-Paul Imbert imbert@cena.fr


if {![info exists zincDemo]} {
    error "This script should be run from the zinc-widget demo."
}

namespace eval textInputDemo {
    #
    # We need the text input support
    package require zincText


    variable w .textInput
    catch {destroy $w}
    toplevel $w
    wm title $w "Zinc textInput Demonstration"
    wm iconname $w textInput

    variable defaultfont [font create -family Helvetica -size 16 -weight normal]

    grid [button $w.dismiss -text Dismiss -command "destroy $w"] -row 2 -column 0 -pady 10
    grid [button $w.code -text "See Code" -command "showCode $w"] -row 2 -column 1 -pady 10


    ###########################################
    # Text zone
    #######################
    ####################

    grid [text $w.text -relief sunken -borderwidth 2 -height 5] \
	-row 0 -column 0 -columnspan 2 -sticky ew

    $w.text insert end {This demo demonstrates the use of the zincText package.
	This module is designed for facilitating text input.
	It works on text items or on fields of items such as
	tracks, waypoints or tabulars.}


    ###########################################
    # Zinc
    ##########################################
    grid [zinc $w.zinc -width 500 -height 300 -render 1 -font $defaultfont -borderwidth 0] \
	-row 1 -column 0 -columnspan 2 -sticky news
    grid columnconfigure $w 0 -weight 1
    grid columnconfigure $w 1 -weight 1
    grid rowconfigure $w 1 -weight 2

    #
    # Activate text input support from zincText
    zn_TextBindings $w.zinc

    ### creating a tabular with 3 fields 2 of them being editable
    variable labelformat1 {130x100 x130x20+0+0 x130x20+0+20 x130x20+0+40}

    variable x 120
    variable y 6
    variable track [$w.zinc add track 1 3 -position "$x $y" -speedvector {40 10} -labeldistance 30 -labelformat $labelformat1 -tags text]

    # moving the track to display past positions
    for {set i 0} {$i<=5} {incr i} { 
	$w.zinc coords "$track" "[expr $x+$i*10] [expr $y+$i*2]" 
    }

    $w.zinc itemconfigure $track 0 -border contour -text {  editable} -sensitive 0

    $w.zinc itemconfigure $track 1 -border contour -text editable -sensitive 1

    $w.zinc itemconfigure $track 2 -border contour -text {editable too} -alignment center -sensitive 1


    # creating a text item tagged with "text" but not editable because
    # it is not sensitive
    $w.zinc add text 1 -position {220 160} -text "this text is not editable \nbecause it is not sensitive" -sensitive 0 -tags text


    # creating an editable text item
    $w.zinc add text 1 -position {50 230} -text {this text IS editable} -sensitive 1 -tags text
}
