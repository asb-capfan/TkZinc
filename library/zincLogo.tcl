#---------------------------------------------------------------
#  File            : LogoZinc.pm
#
#  Copyright (C) 2001-2002
#  Centre d'Études de la Navigation Aérienne
#  Authors: Vinot Jean-Luc <vinot@cena.fr>
#  $Id$
#---------------------------------------------------------------

package provide zincLogo 1.0

namespace eval ::zincLogo:: {

    set letters(coords) {
	{0 0} {106 0} {106 58} {122 41} {156 41} {131 69}
	{153 99} {203 41} {155 41} {155 0} {218 0} {240 0 c}
	{252 17 c} {252 34} {252 40 c} {249 50 c} {244 56}
	{202 105} {246 105} {246 87} {246 60 c} {271 37 c} {297 37}
	{323 37 c} {342 57 c} {344 68} {347 64 c} {350 60 c}
	{353 56} {363 46 c} {375 37 c} {395 37} {395 79} {393 79}
	{385 79 c} {379 86 c} {379 93} {379 100 c} {385 107 c}
	{393 107} {409 107} {409 148} {397 148} {378 148 c} {364 144 c}
	{354 133} {346 124} {346 148} {305 148} {305 87} {305 83 c}
	{301 79 c} {297 79} {293 79 c} {289 83 c} {289 87} {289 150}
	{251 150} {251 130} {251 126 c} {247 122 c} {243 122} {239 122 c}
	{235 126 c} {235 130} {235 150} {176 150} {154 150 c} {146 131 c}
	{146 114} {148 105} {120 105} {104 81} {104 105} {74 105} {74 41} {52 41}
	{52 105} {20 105} {20 41} {0 41}}
    set letters(lineWidth) 3
    set letters(lineColor) {#000000;80}
    set letters(fillColor) {=axial 270|#ffffff;100 0 28|#66848c;100 96|#7192aa;100 100}
    set letters(shadow,dXy) {6 6}
    set letters(shadow,fillColor) {#000000;18}

    set point(pos) {240 96}
    set point(alpha) 80
    set point(lineWidth) 1
    set point(lineColor) {#a10000;100}
    set point(fillColor) {=radial -20 -20|#ffffff;100 0|#f70000;100 48|#900000;100 80|#ab0000;100 100}
    set point(shadow,dXy) {5 5}
    set point(shadow,fillColor) {=path 0 0|#770000;64 0|#770000;64 65|#770000;0 100}
    
    

    proc create {zinc parent priority x y scaleX scaleY} {
	variable letters
	variable point
	#
	# Create a group to hold the various parts
	set logoGroup [$zinc add group $parent -priority $priority]
	
	#
	# Move the group in the right place
	$zinc coords $logoGroup "$x $y"
	
	#
	# Add a sub-group to isolate the scaling
	set scaleGroup [$zinc add group $logoGroup]
	$zinc scale $scaleGroup $scaleX $scaleY
	
	foreach {dx dy} $letters(shadow,dXy) break
	#
	# Create a curve for the main form shadow
	set lShadow [$zinc add curve $scaleGroup $letters(coords) \
			 -tags lettersShadow -closed 1 -filled 1 -linewidth 0 \
			 -fillcolor $letters(shadow,fillColor)]
	$zinc translate $lShadow $dx $dy
	
	set lineWidth [adjustLineWidth $letters(lineWidth) $scaleX $scaleY]
	
	#
	# Create a curve for the main form
	$zinc add curve $scaleGroup $letters(coords) -tags letters -closed 0 \
	    -filled 1 -fillcolor $letters(fillColor) -linewidth $lineWidth \
	    -linecolor $letters(lineColor)
	
	#
	# Create a group to hold the point and its shadow
	set pointGroup [$zinc add group $scaleGroup -alpha $point(alpha)]
	$zinc coords $pointGroup $point(pos)
	
	foreach {dx dy} $point(shadow,dXy) break
	#
	# Create a curve for the dot shadow
	set pShadow [$zinc add arc $pointGroup {-20 -20 20 20} -tags pointShadow \
			 -closed 1 -filled 1 -fillcolor $point(shadow,fillColor) \
			 -linewidth 0]
	$zinc translate $pShadow $dx $dy
	
	#
	# Create a curve for the dot
	$zinc add arc $pointGroup {-20 -20 20 20} -tags point -closed 1 \
	    -filled 1 -fillcolor $point(fillColor) -linewidth $point(lineWidth) \
	    -linecolor $point(lineColor)

	return $logoGroup
    }
	
    proc adjustLineWidth {lineWidth scaleX scaleY} {
	if {$lineWidth != 0} {
	    if {$lineWidth >= 2} {
		set ratio [expr ($scaleX > $scaleY) ? $scaleY : $scaleX]
		return [expr $lineWidth * $ratio]
	    }
	}
    }
}
