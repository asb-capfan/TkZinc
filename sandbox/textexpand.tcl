zinc .z
pack .z

proc createItem {type params} {
    if 1 [concat .z add $type 1 $params]
}
