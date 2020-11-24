
lappend auto_path ..
package require Tkzinc

set defaultfont -b&h-lucida-bold-r-normal-*-*-140-*-*-p-*-iso10646-1
zinc .zinc -width 700 -height 300 -render 1 -backcolor red
pack .zinc


puts start
.zinc gname black|white {axial 1}
#.zinc gname {=conical 70 |white|gray20 50|white} {axial 2}
.zinc gname {=conical 70 |red|yellow 50|red} {axial 2}
.zinc gname {=axial -50 -50 50 50|black|white} {axial 3}
.zinc gname {=axial 30|black|black;0} {axial 4}
.zinc gname {=radial -50 -50 50 50|white|black} {radial 1}
.zinc gname {=radial 0 0|white;50 0 70|black 50|white 100} {radial 2}
.zinc gname {=path -14 -20|white|black;80} {path 1}
.zinc gname {=path -14 -20|white|white 30|black;80} {path 2}
puts end

set grp [.zinc add group 1]
#.zinc add rectangle $grp {0 0 70 50} -filled 1 -fillcolor white   
.zinc add rectangle $grp {0 0 200 300} -filled 1 -linewidth 1 \
    -fillcolor {axial 1} -tags rect
.zinc add text $grp -text {axial 1} -anchor center -position {35 -10} \
    -tags txt

.zinc translate $grp 20 30

set i 1
foreach s {{axial 2} {axial 3} {axial 4} {radial 1}
    {radial 2} {path 1} {path 2}} {

    set grp [.zinc clone $grp]
    .zinc addtag "g$grp" withtag "$grp*attrs"
    .zinc itemconfigure ".$grp.txt" -text $s
    .zinc itemconfigure ".$grp.rect" -fillcolor $s
    incr i
    
    if {$i == 5} {
	.zinc translate $grp [expr -3*100] 80
	set i 1
    } else {
	.zinc translate $grp 100 0
    }
}

