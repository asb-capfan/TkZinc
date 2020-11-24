set tlbbox [.r add group $top -sensitive f -visible f -tags currentbbox]
.r add rectangle $tlbbox "-3 -3 +3 +3"
set trbbox [.r add group $top -sensitive f -visible f -tags currentbbox]
.r add rectangle $trbbox "-3 -3 +3 +3"
set blbbox [.r add group $top -sensitive f -visible f -tags currentbbox]
.r add rectangle $blbbox "-3 -3 +3 +3"
set brbbox [.r add group $top -sensitive f -visible f -tags currentbbox]
.r add rectangle $brbbox "-3 -3 +3 +3"
.r add rectangle $top "0 0 1 1" -linecolor red -tags "lasso" -visible f -sensitive f

#
# Controls for the window transform.
#
proc press {lx ly action} {
    global x y angle
    set x $lx
    set y $ly
    set angle [expr atan2($y, $x)]
    bind .r "<Motion>" "$action %x %y"
}

proc motion {lx ly} {
    global x y
    set it [.r find withtag controls]
    if {$it != ""} {
	set it [.r group [lindex $it 0]]
    }
    set res [.r transform $it "$lx $ly $x $y"]
    set nx [lindex $res 0]
    set ny [lindex $res 1]
    set ox [lindex $res 2]
    set oy [lindex $res 3]
    .r translate controls [expr $nx - $ox] [expr $ny - $oy]
    set x $lx
    set y $ly
}

proc zoom {lx ly} {
    global x y

    if {$lx > $x} {
	set maxx $lx
    } else {
	set maxx $x
    }
    if {$ly > $y} {
	set maxy $ly
    } else {
	set maxy $y
    }
    set sx [expr 1.0 + double($lx - $x)/$maxx]
    set sy [expr 1.0 + double($ly - $y)/$maxy]
    set x $lx
    set y $ly
    .r scale controls $sx $sy
}

proc rotate {lx ly} {
    global angle

    set langle [expr atan2($ly, $lx)]
    .r rotate controls [expr -($langle-$angle)]
    set angle $langle
}

proc release {} {
    bind .r "<Motion>" ""
}

proc start_lasso {lx ly} {
    global top x y cx cy
    set x $lx
    set y $ly
    set cx $lx
    set cy $ly
    set coords [.r transform $top "$x $y"]
    set fx [lindex $coords 0]
    set fy [lindex $coords 1]
    .r coords lasso  "$fx $fy $fx $fy"
    .r itemconfigure lasso -visible t
    .r raise lasso
    bind .r "<Motion>" "lasso %x %y"
}

proc lasso {lx ly} {
    global top x y cx cy
    set cx $lx
    set cy $ly
    set coords [.r transform $top "$x $y $lx $ly"]
    set fx [lindex $coords 0]
    set fy [lindex $coords 1]
    set fcx [lindex $coords 2]
    set fcy [lindex $coords 3]
    .r coords lasso  "$fx $fy $fcx $fcy"
}

proc fin_lasso {} {
    global x y cx cy
    
    bind .r "<Motion>" ""
    .r itemconfigure lasso -visible f
#    puts "x=$x, y=$y, cx=$cx, cy=$cy"
    puts "enclosed='[.r find enclosed $x $y $cx $cy]', overlapping='[.r find overlapping $x $y $cx $cy]'"
}

proc getrect {x y} {
    list [expr $x-3] [expr $y-3] [expr $x+3] [expr $y+3]
}

proc showbox {} {
    global top tlbbox trbbox blbbox brbbox
    
    if { ! [.r hastag current currentbbox]} {
	if {[catch {.r find withtag current} item] } {
	    return
	}
	set coords [.r transform $top [.r bbox current]]
	set xo [lindex $coords 0]
	set yo [lindex $coords 1]
	set xc [lindex $coords 2]
	set yc [lindex $coords 3]

	.r coords $tlbbox "$xo $yo"
	.r coords $trbbox "$xc $yo"
	.r coords $brbbox "$xc $yc"
	.r coords $blbbox "$xo $yc"
	.r itemconfigure currentbbox -visible t
    }
}

proc hidebox {lx ly} {
    set next [.r find closest $lx $ly]
    if {[llength $next] > 1} {
	set next [lindex $next 0]
    }
    if { $next == "" || ! [.r hastag $next currentbbox] ||\
	    [.r hastag current currentbbox]} {
	.r itemconfigure currentbbox -visible f
    }
}


bind  .r "<ButtonPress-1>" "start_lasso %x %y"
bind  .r "<ButtonRelease-1>" fin_lasso

bind  .r "<ButtonPress-2>" {puts "at point='[.r find closest %x %y]'"}

bind  .r "<ButtonPress-3>" "press %x %y motion"
bind  .r "<ButtonRelease-3>" release

bind  .r "<Shift-ButtonPress-3>" "press %x %y zoom"
bind  .r "<Shift-ButtonRelease-3>" release

bind  .r "<Control-ButtonPress-3>" "press %x %y rotate"
bind  .r "<Control-ButtonRelease-3>" release

.r bind current "<Enter>" showbox
.r bind current "<Leave>" {hidebox %x %y}
