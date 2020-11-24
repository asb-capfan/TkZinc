#
# ZincText - Zinc extension for text input on text items and fields
#
# $Id$
#
# AUTHOR
#
# Patrick Lecoanet <lecoanet@cena.fr>
# (and documentation by Christophe Mertz <mertz@cena.fr>)
#
# Copyright (c) 2002 - 2003 CENA, Patrick Lecoanet
#
# See the file "Copyright" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
#
#
# SYNOPSIS
#
#  package require zincText;
#
#  zn_TextBindings $zinc
#
#  $zinc addtag text withtag $a_text
#  $zinc addtag text withtag $a_track
#  $zinc addtag text withtag $a_waypoint
#  $zinc addtag text withtag $a_tabular
#
#
# DESCRIPTION
#
# This module implements text input with the mouse and keyboard 'a la emacs'.
# Text items must have the 'text' tag and must of course be sensitive.
# Track, waypoint and tabular items have fields and these fields can
# be edited the same way. Only sensitive fields can be edited. the following
# interactions are supported:
#
#   <click 1>      To set the cursor position
#   <click 2>      To paste the current selection
#   <drag 1>       To make a selection
#   <shift drag 1> To extend the current selection
#   <shift 1>      To extend the current selection
#   <left arrow>,
#   <right arrow>  To move the cursor to the left or to the right
#   <up arrow>,
#   <down arrow>   To move the cursor up or down a line
#   <ctrl+a>,
#   <home>         To move the cursor at the begining of the line
#   <ctrl+e>
#   <end>          To move the cursor at the end of the line
#   <meta+<>,
#   <meta+>>       To move the cursor at the beginning / end of the text
#   <BackSpace>
#   <ctrl+h>       To delete the char just before the cursor
#   <Delete>       To delete the char just after the cursor
#   <Return>       To insert a return char. This does not validate the input!
#
#

proc zn_TextBindings {zinc} {
    $zinc bind text <1>              "startSel $zinc %x %y"
    $zinc bind text <2>              "pasteSel $zinc %x %y"
    $zinc bind text <B1-Motion>      "extendSel $zinc %x %y"
    $zinc bind text <Shift-B1-Motion> "extendSel $zinc %x %y"
    $zinc bind text <Shift-1>        "$zinc select adjust current @%x,%y"
    $zinc bind text <Left>           "moveCur $zinc -1"
    $zinc bind text <Right>          "moveCur $zinc 1"
    $zinc bind text <Up>             "setCur $zinc up"
    $zinc bind text <Down>           "setCur $zinc down"
    $zinc bind text <Control-a>      "setCur $zinc bol"
    $zinc bind text <Home>           "setCur $zinc bol"
    $zinc bind text <Control-e>      "setCur $zinc eol"
    $zinc bind text <End>            "setCur $zinc eol"
    $zinc bind text <Meta-less>      "setCur $zinc 0"
    $zinc bind text <Meta-greater>   "setCur $zinc end"
    $zinc bind text <KeyPress>       "insertKey $zinc %A"
    $zinc bind text <Shift-KeyPress> "insertKey $zinc %A"
    $zinc bind text <Return>         "insertChar $zinc \\n"
    $zinc bind text <BackSpace>      "textDel $zinc -1"
    $zinc bind text <Control-h>      "textDel $zinc -1"
    $zinc bind text <Delete>         "textDel $zinc 0"
}


proc pasteSel {w x y} {
    set item [$w focus]

    if {[llength $item] != 0} {
	catch {$w insert [lindex $item 0] [lindex $item 1] @$x,$y [selection get]}
    }
}


proc insertChar {w c} {
    set item [$w focus]
    set selItem [$w select item]

    if {[llength $item] == 0} {
	return;
    }
    
    if {([llength $selItem]!= 0) &&
	([lindex $selItem 0] == [lindex $item 0]) &&
	([lindex $selItem 1] == [lindex $item 1])} {
	$w dchars [lindex $item 0] [lindex $item 1] sel.first sel.last
    }
    $w insert [lindex $item 0] [lindex $item 1] insert $c
}


proc insertKey {w c} {
    if {! [binary scan $c {c} code]} {
	return
    }
    set code [expr $code & 0xFF]
    if {($code < 32) || ($code == 128)} {
	puts "rejet $code"
	return
    }
    
    insertChar $w $c
}


proc setCur {w where} {
    set item [$w focus]

    if {[llength $item] != 0} {
	$w cursor [lindex $item 0] [lindex $item 1] $where
    }
}


proc moveCur {w dir} {
    set item [$w focus]

    if {[llength $item] != 0} {
	set index [$w index [lindex $item 0] [lindex $item 1] insert]
	$w cursor [lindex $item 0] [lindex $item 1]  [expr $index + $dir]
    }
}


proc startSel {w x y} {
    set part [$w currentpart t]

    $w cursor current $part @$x,$y
    $w focus current $part
    focus $w
    $w select from current $part @$x,$y
}


proc extendSel {w x y} {
    set part [$w currentpart t]

    $w select to current $part @$x,$y
}


proc textDel {w dir} {
    set item [$w focus]
    set selItem [$w select item]

    if {[llength $item] == 0} {
	return;
    }

    if {([llength $selItem] != 0) &&
	([lindex $selItem 0] == [lindex $item 0]) &&
	([lindex $selItem 1] == [lindex $item 1])} {
	$w dchars [lindex $item 0] [lindex $item 1] sel.first sel.last
    } else {
	set ind [expr [$w index [lindex $item 0] [lindex $item 1] insert] + $dir]
	if { $ind >= 0 } {
	    $w dchars [lindex $item 0] [lindex $item 1] $ind $ind
	}
    }
}

package provide zincText 1.0
