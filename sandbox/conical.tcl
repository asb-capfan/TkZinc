
lappend auto_path ..
package require Tkzinc

set defaultfont -b&h-lucida-bold-r-normal-*-*-140-*-*-p-*-iso10646-1
zinc .zinc -width 700 -height 500 -render 1
pack .zinc


.zinc gname {=radial 0 0 |white|gray30} test1
.zinc gname {=conical 70 |white|gray30 50 50|white} test2

set grp [.zinc add group 1]
#.zinc add rectangle $grp {0 0 70 50} -filled 1 -fillcolor white   
.zinc add rectangle $grp {60 60 360 360} -filled 1 -linewidth 1 \
    -fillcolor test2 -tags rect

.zinc add rectangle $grp {140 140 280 280} -filled 1 -fillcolor gray
