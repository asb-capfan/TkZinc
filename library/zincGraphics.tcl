#
#-----------------------------------------------------------------------------------
#
#      Graphics.tcl
#      some graphic design functions
#
#-----------------------------------------------------------------------------------
#  Functions to create complexe graphic component :
#  ------------------------------------------------
#      BuildZincItem          (realize a zinc item from description hash table)
#
#  Function to compute complexe geometrical forms :
#  (text header of functions explain options for each form,
#  function return curve coords using control points of cubic curve)
#  -----------------------------------------------------------------
#      RoundedRectangleCoords (return curve coords of rounded rectangle)
#      HippodromeCoords       (return curve coords of circus form)
#      PolygonCoords          (return curve coords of regular polygon)
#      RoundedCurveCoords     (return curve coords of rounded curve)
#      PolylineCoords         (return curve coords of polyline)
#      TabBoxCoords           (return curve coords of tabBox's pages)
#      PathLineCoords         (return triangles coords of pathline)
#
#  Geometrical basic Functions :
#  -----------------------------
#      PerpendicularPoint
#      LineAngle
#      VertexAngle
#      ArcPts
#      RadPoint
#
#  Pictorial Functions  :
#  ----------------------
#      SetGradients
#      GetPattern
#      GetTexture
#      GetImage
#      InitPixmaps
#      HexaRGBcolor
#      CreateGraduate
#
#-----------------------------------------------------------------------------------
#      Authors: Jean-Luc Vinot <vinot@cena.fr>
#		Patrick Lecoanet <lecoanet@cena.fr> (Straight translation
#		to Tcl, based on Graphics.pm revision 1.9)
# $Id: 
#-----------------------------------------------------------------------------------

namespace eval ::zincGraphics {

  package provide zincGraphics 1.0

  namespace export BuildZincItem RoundedRectangleCoords HippodromeCoords \
    PolygonCoords RoundedCurveCoords PolylineCoords TabBoxCoords PathLineCoords \
    PerpendicularPoint SetGradients GetPattern GetTexture GetImage InitPixmaps \
    HexaRGBcolor CreateGraduate

  namespace eval v {
    # constante facteur point directeur
    variable constPtdFactor 0.5523
    variable Gradients {}
    variable textures {}
    variable images {}
    variable bitmaps {}
    variable pi 3.14159
  }

  if { ![info exists zinc_library] } {
    set zinc_library [file dirname [info script]]
  }
  
  set imagePath [file join $zinc_library .. demos images]

  proc deg2rad {angle} {
    return [expr {$angle * $v::pi / 180.0}]
  }
  
  proc TLGet {list tag {default ""}} {
    foreach {key val} $list {
      if { [string compare $key $tag] == 0 } {
	return $val
      }
    }
    return $default
  }

  #proc TLGet {assoc tag {default ""}} {
    #    array set temp $assoc
    #    if { [info exists temp($tag)] } {
      #	return $temp($tag)
    #    }
    #    return $default
  #}

  proc PointX {point} {
    return [lindex $point 0]
  }

  proc PointY {point} {
    return [lindex $point 1]
  }

  #-----------------------------------------------------------------------------------
  # Graphics::BuildZincItem
  # Création d'un objet Zinc de représentation
  # paramètres :
  # widget : <widget>
  # parentGroup : <group>
  # style : {hash table options}
  # specificTags : [list of specific tags] to add to params -tags
  # name : <str> nom de l'item
  #-----------------------------------------------------------------------------------
  # type d'item valide :
  # les items natifs zinc : group, rectangle, arc, curve, text, icon
  # les items ci-après permettent de spécifier des curves 'particulières' :
  # -roundedrectangle : rectangle à coin arrondi
  #       -hippodrome : hippodrome
  #         -polygone : polygone régulier à n cotés (convexe ou en étoile)
  #     -roundedcurve : curve multicontours à coins arrondis (rayon unique)
  #         -polyline : curve multicontours à coins arrondis (le rayon pouvant être défini 
  #                     spécifiquement pour chaque sommet)
  #         -pathline : création d'une ligne 'épaisse' avec l'item Zinc triangles
  #                     décalage par rapport à un chemin donné (largeur et sens de décalage)
  #                     dégradé de couleurs de la ligne (linéaire, transversal ou double)
  #-----------------------------------------------------------------------------------
  proc BuildZincItem {zinc parentGroup styleTL specificTags name} {
    array set style $styleTL
    if { [info exists style(-params)] } {
      array set params $style(-params)
    }

    if { ! $parentGroup } {
      set parentGroup 1
    }

    if { [llength $specificTags] } {
      if { [info exists params(-tags)] } {
	set params(-tags) [concat $specificTags $params(-tags)]
      } else {
	set params(-tags) $specificTags
      }
    }

    set itemType $style(-itemtype)
    set coords {}
    if { [info exists style(-coords)] } {
     set coords $style(-coords)
    }
    # gestion des polygones particuliers et à coin arrondi
    switch -- $itemType { 
      roundedrectangle {
	set itemType curve
	set params(-closed) 1
	set coords [RoundedRectangleCoords $coords $styleTL]
      }
      hippodrome {
	set itemType curve
	set params(-closed) 1
	set coords [HippodromeCoords $coords $styleTL]
      }
      polygone {
	set itemType curve
	set params(-closed) 1
	set coords [PolygonCoords $coords $styleTL]
      }
      roundedcurve -
      polyline {
	set itemType curve
	if { $itemType eq "roundedcurve" } {
	  set params(-closed) 1
	  set coords [RoundedCurveCoords $coords $styleTL]
	} else {
	  set coords [PolylineCoords $coords $styleTL]
	}
	#
	# multi-contours
	if { [info exists style(-contours)] } {
	  set contours $style(-contours)
	  set numContours [llength $contours]
	  for {set i 0} {$i < $numContours} {incr i} {
	    # radius et corners peuvent être défini spécifiquement
	    # pour chaque contour
	    foreach {type way inCoords radius corners cornersRadius} \
	      [lindex $contours $i] break

	    if { $radius eq "" } {
	      set radius $style(-radius)
	    }
	    if { $itemType eq "roundedcurve" } {
	      set newCoords [RoundedCurveCoords $inCoords [list -radius $radius \
							       -corners $corners]]
	    } else {
	      set newCoords [PolylineCoords $inCoords \
				 [list -radius $radius -corners $corners \
				      -cornersradius $cornersRadius]]
	    }
	    lset style(-contours) $i [list $type $way $newCoords]
	  }
	}
      }
      pathline {
	set itemType triangles
	if { [info exists style(-metacoords)] } {
	  set coords [MetaCoords $style(-metacoords)]
	}

	if { [info exists style(-graduate)] } {
	  set numColors [llength $coords]
	  set params(-colors) [PathGraduate $numColors $style(-graduate)]
	}
	set coords [PathLineCoords $coords $styleTL]
      }
    }

    switch -- $itemType {
      group {
	  set item [eval {$zinc add $itemType $parentGroup} [array get params]]
	if { [llength $coords] } {
	  $zinc coords $item $coords
	}

      }
      text -
      icon {
	set imageFile ""
	if { $itemType eq "icon" } {
	  set imageFile $params(-image)
	  if { $imageFile ne "" } {
	    set params(-image) [InitPixmap $imageFile]
	  }
	}

	  set item [eval {$zinc add $itemType $parentGroup -position $coords} [array get params]]
	if { $imageFile ne "" } {
	  set params(-image) $imageFile
	}
      }
      default {
	set item [eval {$zinc add $itemType $parentGroup $coords} [array get params]]
	if { $itemType eq "curve" && [info exists style(-contours)] } {
	  foreach contour $style(-contours) {
	    eval $zinc contour $item $contour
	  }
	}

	# gestion du mode norender
	if { [info exists style(-texture)] } {
	  set texture [GetTexture $style(-texture)]
	  if { $texture ne "" } {
	    $zinc itemconfigure $item -tile $texture
	  }
	}

	if { [info exists style(-fillpattern)] } {
	  set bitmap [GetBitmap $style(-fillpattern)]
	  if { $bitmap ne "" } {
	    $zinc itemconfigure $item -fillpattern $bitmap
	  }
	}
      }
    }

    # transformation scale de l'item si nécessaire
    if { [info exists style(-scale)] } {
      $zinc scale $item $style(-scale)
    }

    # transformation rotate de l'item si nécessaire
    if { [info exists style(-rotate)] } {
      $zinc rotate $item [deg2rad $style(-rotate)]
    }
    # transformation scale de l'item si nécessaire
    if { [info exists style(-translate)] } {
      $zinc translate $item $style(-translate)
    }

    return $item
  }

  #-----------------------------------------------------------------------------------
  # FONCTIONS GEOMETRIQUES
  #-----------------------------------------------------------------------------------

  #-----------------------------------------------------------------------------------
  # Graphics::MetaCoords
  # retourne une liste de coordonnées en utilisant la fonction d'un autre type d'item
  # paramètres : (options)
  #   -type : type de primitive utilisée
  # -coords : coordonnées nécessitée par la fonction [type]Coords
  #  + options spécialisées passés à la fonction [type]Coords
  #-----------------------------------------------------------------------------------
  proc MetaCoords {options} {
    set pts {}
    set type [TLGet $options -type]
    set coords [TLGet $options -coords]

    switch -- $type {
      polygone {
	set pts [PolygonCoords $coords $options]
      }
      hippodrome {
	set pts [HippodromeCoords $coords $options]
      }
      polyline {
	set pts [PolylineCoords $coords $options]
      }
    }

    return $pts
  }

  #-----------------------------------------------------------------------------------
  # Graphics::RoundedRectangleCoords
  # calcul des coords du rectangle à coins arrondis
  # paramètres :
  # coords : point centre du polygone
  # options :
  #  -radius : rayon de raccord d'angle
  # -corners : liste des raccords de sommets [0 (aucun raccord)|1] par défaut [1,1,1,1]
  #-----------------------------------------------------------------------------------
  proc RoundedRectangleCoords {coords optionsTL} {
    foreach {p0 p1} $coords break
    foreach {x0 y0} $p0 break
    foreach {xn yn} $p1 break

    set radius [TLGet $optionsTL -radius]
    set corners [TLGet $optionsTL -corners]
    if { [llength $corners] == 0 } {
      set corners [list 1 1 1 1]
    }

    # attention aux formes 'négatives'
    if { $xn < $x0 } {
      set xs $x0
      set x0 $xn
      set xn $xs
    }
    if { $yn < $y0 } {
      set ys $y0
      set y0 $yn
      set yn $ys
    }

    set height [_min [expr {$xn - $x0}] [expr {$yn - $y0}]]

    if { $radius eq "" } {
      set radius [expr {int($height/10.0)}]
      if { $radius < 3 } {
	set radius 3
      }
    }

    if { $radius < 2 } {
      return [list [list $x0 $y0] [list $x0 $yn] \
	[list $xn $yn] [list $xn $y0]]
    }


    # correction de radius si necessaire
    set maxRad $height
    if { $corners eq "" } {
      set maxRad [expr {$maxRad / 2.0}]
    }
    if { $radius > $maxRad } {
      set radius $maxRad
    }

    # points remarquables
    set ptdDelta [expr {$radius * $v::constPtdFactor}]
    set x2 [expr {$x0 + $radius}]
    set x3 [expr {$xn - $radius}]
    set x1 [expr {$x2 - $ptdDelta}]
    set x4 [expr {$x3 + $ptdDelta}]
    set y2 [expr {$y0 + $radius}]
    set y3 [expr {$yn - $radius}]
    set y1 [expr {$y2 - $ptdDelta}]
    set y4 [expr {$y3 + $ptdDelta}]

    # liste des 4 points sommet du rectangle : angles sans raccord circulaire
    set anglePts [list [list $x0 $y0] [list $x0 $yn] \
      [list $xn $yn] [list $xn $y0]]

    # liste des 4 segments quadratique : raccord d'angle = radius
    set roundeds [list \
	[list [list $x2 $y0] [list $x1 $y0 c] \
	      [list $x0 $y1 c] [list $x0 $y2]] \
        [list [list $x0 $y3] [list $x0 $y4 c] \
              [list $x1 $yn c] [list $x2 $yn]] \
        [list [list $x3 $yn] [list $x4 $yn c] \
              [list $xn $y4 c] [list $xn $y3]] \
        [list [list $xn $y2] [list $xn $y1 c] \
              [list $x4 $y0 c] [list $x3 $y0]]]

    set pts [list]
    set previous 0
    foreach seg $roundeds aPt $anglePts corner $corners {
      set px 0
      set py 0
      if { $corner } {
	# on teste si non duplication de point
	foreach {nx ny} [lindex $seg 0] break
	if { $previous && ($px == $nx && $py == $ny) } {
	  eval lappend pts [lrange $seg 1 end]
	} else {
	  eval lappend pts $seg
	}
	foreach {px py} [lindex $seg 3] break
	set previous 1
      } else {
	lappend pts $aPt
      }
    }
    return $pts
  }

  #-----------------------------------------------------------------------------------
  # Graphics::HippodromeCoords
  # calcul des coords d'un hippodrome
  # paramètres :
  # coords : coordonnées du rectangle exinscrit
  # options :
  # -orientation : orientation forcée de l'ippodrome [horizontal|vertical]
  #     -corners : liste des raccords de sommets [0|1] par défaut [1,1,1,1]
  #       -trunc : troncatures [left|right|top|bottom|both]
  #-----------------------------------------------------------------------------------
  proc HippodromeCoords {coords optionsTL} {
    foreach {p0 p1} $coords break
    foreach {x0 y0} $p0 break
    foreach {xn yn} $p1 break

    set orientation [TLGet $optionsTL -orientation none]

    # orientation forcée de l'hippodrome (sinon hippodrome sur le plus petit coté)
    switch -- $orientation {
      horizontal { set height [expr {abs($yn - $y0)}] }
      vertical { set height [expr {abs($xn - $x0)}] }
      default { set height [_min [expr {abs($xn - $x0)}] [expr {abs($yn - $y0)}]] }
    }

    set radius [expr {$height/2.0}]

    set corners [TLGet $optionsTL -corners]
    set trunc [TLGet $optionsTL -trunc]
    if { [llength $corners] == 0 } {
      switch -- $trunc {
	both { return [list [list $x0 $y0] [list $x0 $yn] \
	  [list $xn $yn] [list $xn $y0]] }
	left { set corners [list 0 0 1 1] }
	right { set corners [list 1 1 0 0] }
	top { set corners [list 0 1 1 0] }
	bottom { set corners [list 1 0 0 1] }
	default { set corners [list 1 1 1 1] }
      }
    }

    # l'hippodrome est un cas particulier de roundedRectangle
    # on retourne en passant la 'configuration' à la fonction
    # générique roundedRectangleCoords
    return [RoundedRectangleCoords $coords [list -radius [expr {$height/2.0}] -corners $corners]]
  }


  #-----------------------------------------------------------------------------------
  # Graphics::PolygonCoords
  # calcul des coords d'un polygone régulier
  # paramètres :
  # coords : point centre du polygone
  # options :
  #      -numsides : nombre de cotés
  #        -radius : rayon de définition du polygone (distance centre-sommets)
  #  -innerradius : rayon interne (polygone type étoile)
  #       -corners : liste des raccords de sommets [0|1] par défaut [1,1,1,1]
  # -cornerradius : rayon de raccord des cotés
  #    -startangle : angle de départ du polygone
  #-----------------------------------------------------------------------------------
  proc PolygonCoords {coords optionsTL} {
    set numSides [TLGet $optionsTL -numsides 0]
    set radius [TLGet $optionsTL -radius 0]
    if { $numSides < 3 || !$radius } {
      puts "Vous devez au moins spécifier un nombre de cotés >= 3 et un rayon..."
      return {};
    }

    if { [llength $coords] } {
      foreach {cx cy} $coords break
    } else {
      set cx 0
      set cy 0
    }

    set startAngle [TLGet $optionsTL -startangle 0]
    set angleStep [expr {360.0/$numSides}]
    set innerRadius [TLGet $optionsTL -innerradius 0]
    set pts [list]

    # points du polygone
    for {set i 0} {$i < $numSides} {incr i} {
      set p [RadPoint $cx $cy $radius [expr {$startAngle + ($angleStep*$i)}]]
      lappend pts $p

      # polygones 'étoiles'
      if { $innerRadius } {
	set p [RadPoint $cx $cy $innerRadius [expr {$startAngle + ($angleStep*($i+ 0.5))}]]
	lappend pts $p
      }
    }

    set cornerRadius [TLGet $optionsTL -cornerradius {}]
    if { $cornerRadius ne "" } {
      set pts [RoundedCurveCoords $pts [list -radius $cornerRadius -corners \
					    [TLGet $optionsTL -corners {}]]]
    }
    return $pts
  }

  #-----------------------------------------------------------------------------------
  # Graphics::RoundedAngle
  # THIS FUNCTION IS NO MORE USED, NEITHER EXPORTED
  # curve d'angle avec raccord circulaire
  # paramètres :
  # zinc : widget
  # parentGroup : group zinc parent
  # coords : les 3 points de l'angle
  # radius : rayon de raccord
  #-----------------------------------------------------------------------------------
  proc RoundedAngle {zinc parentGroup coords radius} {
    foreach {pt0 pt1 pt2} $coords break

    foreach {cornerPts centerPts} [RoundedAngleCoords $coords $radius] break
    foreach {cx0 cy0} $centerPts break

    # valeur d'angle et angle formé par la bisectrice
    # set angle [VertexAngle $pt0 $pt1 $pt2]

    if { $parentGroup eq "" } {
      set parentGroup 1
    }

    set cornerPts [linsert $cornerPts 0 $pt0]
    lappend cornerPts $pt2
    $zinc add curve $parentGroup $cornerPts -closed 0 -linewidth 1 -priority 20
  }

  #-----------------------------------------------------------------------------------
  # Graphics::RoundedAngleCoords
  # calcul des coords d'un raccord d'angle circulaire
  #-----------------------------------------------------------------------------------
  # le raccord circulaire de 2 droites sécantes est traditionnellement réalisé par un
  # arc (conique) du cercle inscrit de rayon radius tangent à ces 2 droites
  #
  # Quadratique :
  # une approche de cette courbe peut être réalisée simplement par le calcul de 4 points
  # spécifiques qui définiront - quelle que soit la valeur de l'angle formé par les 2
  # droites - le segment de raccord :
  # - les 2 points de tangence au cercle inscrit seront les points de début et de fin
  # du segment de raccord
  # - les 2 points de controle seront situés chacun sur le vecteur reliant le point de
  # tangence au sommet de l'angle (point secant des 2 droites)
  # leur position sur ce vecteur peut être simplifiée comme suit :
  # - à un facteur de 0.5523 de la distance au sommet pour un angle >= 90° et <= 270°
  # - à une 'réduction' de ce point vers le point de tangence pour les angles limites
  # de 90° vers 0° et de 270° vers 360°
  # ce facteur sera légérement modulé pour recouvrir plus précisement l'arc correspondant
  #-----------------------------------------------------------------------------------
  proc RoundedAngleCoords {coords radius} {
    foreach {pt0 pt1 pt2} $coords break
    foreach {pt1x pt1y} $pt1 break
    
    # valeur d'angle et angle formé par la bisectrice
    foreach {angle bisecAngle} [VertexAngle $pt0 $pt1 $pt2] break

    # distance au centre du cercle inscrit : rayon/sinus demi-angle
    set sin [expr {sin([deg2rad $angle] / 2.0)}]
    set delta [expr {$sin ? abs($radius / $sin) : $radius}]

    # point centre du cercle inscrit de rayon $radius
    set refAngle [expr {($angle < 180) ? $bisecAngle+90 : $bisecAngle-90}]
    set c0 [RadPoint $pt1x $pt1y $delta $refAngle]

    # points de tangeance : pts perpendiculaires du centre aux 2 droites
    set p1 [PerpendicularPoint $c0 [list $pt0 $pt1]]
    set p2 [PerpendicularPoint $c0 [list $pt1 $pt2]]
    foreach {p1x p1y} $p1 break
    foreach {p2x p2y} $p2 break

    # point de controle de la quadratique
    # facteur de positionnement sur le vecteur pt.tangence, sommet
    set ptdFactor $v::constPtdFactor
    if { $angle < 90 || $angle > 270 } {
      set diffAngle [expr {($angle < 90) ? $angle : 360 - $angle}]
      if { $diffAngle > 15 } {
	set ptdFactor [expr {$ptdFactor - (((90.0 - $diffAngle)/90.0) * ($ptdFactor/4.0))}]
      }
      set ptdFactor [expr {($diffAngle/90.0) * \
	  ($ptdFactor + ((1.0 - $ptdFactor) * (90.0 - $diffAngle)/90.0))}]
    } else {
      set diffAngle [expr {abs(180.0 - $angle)}]
      if { $diffAngle > 15 } {
	set ptdFactor [expr {$ptdFactor + (((90.0 - $diffAngle)/90.0) * ($ptdFactor/3.0))}]
      }
    }

    # delta xy aux pts de tangence
    set d1x [expr {($pt1x - $p1x) * $ptdFactor}]
    set d1y [expr {($pt1y - $p1y) * $ptdFactor}]
    set d2x [expr {($pt1x - $p2x) * $ptdFactor}]
    set d2y [expr {($pt1y - $p2y) * $ptdFactor}]

    # les 4 points de l'arc 'quadratique' et le centre du cercle inscrit
    set cornerPts [list $p1 \
		       [list [expr {$p1x + $d1x}] [expr {$p1y + $d1y}] c] \
		       [list [expr {$p2x + $d2x}] [expr {$p2y + $d2y}] c] \
		       $p2]

    return [list $cornerPts $c0]
  }

  #-----------------------------------------------------------------------------------
  # Graphics::RoundedCurveCoords
  # retourne les coordonnées d'une curve à coins arrondis
  # paramètres :
  # coords : points de la curve
  # options :
  #  -radius : rayon de raccord d'angle
  # -corners : liste des raccords de sommets [0|1] par défaut [1,1,1,1]
  #-----------------------------------------------------------------------------------
  proc RoundedCurveCoords {coords options} {
    set numFaces [llength $coords]
    set curvePts {}
    set radius [TLGet $options -radius 0]
    set corners [TLGet $options -corners {}]

    for {set index 0} {$index < $numFaces} {incr index} {
      if { ([llength $corners] > $index) && ([lindex $corners $index] == 0) } {
	lappend curvePts [lindex $coords $index]
      } else {
	set prev [expr {$index ? $index - 1 : $numFaces - 1}]
	set next [expr {($index > $numFaces - 2) ? 0 : $index + 1}]
	set angleCoords [list [lindex $coords $prev] \
			     [lindex $coords $index] \
			     [lindex $coords $next]]
	foreach {quadPts centerPts} [RoundedAngleCoords $angleCoords $radius] break
	set curvePts [concat $curvePts $quadPts]
      }
    }
    return $curvePts
  }

  #-----------------------------------------------------------------------------------
  # Graphics::PolylineCoords
  # retourne les coordonnées d'une polyline
  # paramètres :
  # coords : sommets de la polyline
  # options :
  #        -radius : rayon global de raccord d'angle
  #       -corners : liste des raccords de sommets [0|1] par défaut [1,1,1,1],
  # -cornersradius : liste des rayons de raccords de sommets
  #-----------------------------------------------------------------------------------
  proc PolylineCoords {coords options} {
    set numFaces [llength $coords]
    set curvePts {}

    set radius [TLGet $options -radius 0]
    set cornersRadius [TLGet $options -cornersradius]

    if { [llength $cornersRadius] } {
      set corners $cornersRadius
    } else {
      set corners [TLGet $options -corners]
    }

    set numCorners [llength $corners]
    for {set index 0} {$index < $numFaces} {incr index} {
      if { $numCorners && (($index >= $numCorners) || ![lindex $corners $index]) } {
	foreach {x y} [lindex $coords $index] { lappend curvePts [list $x $y] }
      } else {
	set prev [expr {$index ? $index - 1 : $numFaces - 1}]
	set next [expr {($index > $numFaces - 2) ? 0 : $index + 1}]
	set angleCoords [list [lindex $coords $prev] [lindex $coords $index] \
			     [lindex $coords $next]]

        if { [llength $cornersRadius] } {
	  set rad [lindex $cornersRadius $index]
	} else {
	  set rad $radius
	}
	foreach {cornerPts centerPts} [RoundedAngleCoords $angleCoords $rad] break
	set curvePts [concat $curvePts $cornerPts]
      }
    }

    return $curvePts
  }

  #-----------------------------------------------------------------------------------
  # Graphics::PathLineCoords
  # retourne les coordonnées d'une pathLine
  # paramètres :
  # coords : points de path
  # options :
  #    -closed : ligne fermée
  #  -shifting : sens de décalage [both|left|right] par défaut both
  # -linewidth : epaisseur de la ligne
  #-----------------------------------------------------------------------------------
  proc PathLineCoords {coords options} {
    set numFaces [llength $coords]
    set pts {}

    set closed [TLGet $options -closed]
    set lineWidth [TLGet $options -linewidth 0]
    set shifting [TLGet $options -shifting both]

    if { ! $numFaces || $lineWidth < 2 } {
      return {}
    }

    set previous {}
    if { $closed } {
      set previous [lindex $coords [expr $numFaces - 1]]
    }
    set next [lindex $coords 1]
    if { $shifting eq "both" } {
      set lineWidth [expr {$lineWidth / 2.0}]
    }

    for {set i 0} {$i < $numFaces} {incr i} {
      set pt [lindex $coords $i]
      foreach {ptX ptY} $pt break
      foreach {nextX nextY} $next break

      if { [llength $previous] == 0 } {
	# extrémité de curve sans raccord -> angle plat
	set previous [list [expr {$ptX + ($ptX - $nextX)}] \
	  [expr {$ptY + ($ptY - $nextY)}]]
      }

      foreach {angle bisecAngle} [VertexAngle $previous $pt $next] break

      # distance au centre du cercle inscrit : rayon/sinus demi-angle
      set sin [expr {sin([deg2rad [expr $angle/2.0]])}]
      set delta [expr {$sin ? abs($lineWidth / $sin) : $lineWidth}]

      if { $shifting eq "left" || $shifting eq "right" } {
	set adding [expr {($shifting eq "left") ? 90 : -90}]
	foreach {x y} [RadPoint $ptX $ptY $delta [expr {$bisecAngle + $adding}]] {
	  lappend pts $x $y
	}
	lappend pts $ptX $ptY

      } else {
	foreach {x y} [RadPoint $ptX $ptY $delta [expr {$bisecAngle + 90}]] {
	  lappend pts $x $y
	}
	foreach {x y} [RadPoint $ptX $ptY $delta [expr {$bisecAngle - 90}]] {
	  lappend pts $x $y
	}
      }

      if { $i == [expr $numFaces - 2] } {
	if { $closed } {
	  set next [lindex $coords 0]
	} else {
	  set nextI [expr $i + 1]
	  set next [list [expr {2 * [PointX [lindex $coords $nextI]] - [PointX $pt]}] \
	    [expr {2 * [PointY [lindex $coords $nextI]] - [PointY $pt]}]]
	}
      } else {
	set next [lindex $coords [expr {$i + 2}]]
      }
      set previous [lindex $coords $i]
    }

    if { $closed } {
      lappend pts [lindex $pts 0] [lindex $pts 1] [lindex $pts 2] [lindex $pts 3]
    }

    return $pts
  }

  #-----------------------------------------------------------------------------------
  # Graphics::PerpendicularPoint
  # retourne les coordonnées du point perpendiculaire abaissé d'un point sur une ligne
  #-----------------------------------------------------------------------------------
  proc PerpendicularPoint {point line} {
    foreach {x y} $point {p1 p2} $line break
    foreach {x1 y1} $p1 {x2 y2} $p2 break

    # cas particulier de lignes ortho.
    set minDist .01
    if { abs($y2 - $y1) < $minDist } {
      # la ligne de référence est horizontale
      return [list $x $y1]
    } elseif { abs($x2 - $x1) < $minDist } {
      # la ligne de référence est verticale
      return [list $x1 $y]
    }

    set a1 [expr {double($y2 - $y1) / double($x2 - $x1)}]
    set b1 [expr {$y1 - $a1 * $x1}]

    set a2 [expr {-1.0 / $a1}]
    set b2 [expr {$y - $a2 * $x}]

    set xRet [expr {double($b2 - $b1) / double($a1 - $a2)}]
    set yRet [expr {$a1 * $xRet + $b1}]

    return [list $xRet $yRet]
  }

  #-----------------------------------------------------------------------------------
  # Graphics::LineAngle
  # retourne l'angle d'un point par rapport à un centre de référence
  #-----------------------------------------------------------------------------------
  proc LineAngle {p center} {
    foreach {x y} $p {xref yref} $center break
    set angle [expr {(atan2($y - $yref, $x - $xref) + $v::pi/2.0) * 180.0 / $v::pi}]
    if { $angle < 0 } {
      set angle [expr {$angle + 360}]
    }
    return $angle
  }

  #-----------------------------------------------------------------------------------
  # Graphics::VertexAngle
  # retourne la valeur de l'angle formée par 3 points
  # ainsi que l'angle de la bisectrice
  #-----------------------------------------------------------------------------------
  proc VertexAngle {pt0 pt1 pt2} {
    set angle1 [LineAngle $pt1 $pt0]
    set angle2 [LineAngle $pt1 $pt2]

    if { $angle2 < $angle1 } {
      set angle2 [expr $angle2 + 360]
    }
    set alpha [expr {$angle2 - $angle1}]
    set bisectrice [expr {$angle1 + ($alpha/2.0)}]

    return [list $alpha $bisectrice]
  }

  #-----------------------------------------------------------------------------------
  # Graphics::ArcPts
  # calcul des points constitutif d'un arc
  # params : x,y centre, rayon, angle départ, delta angulaire, pas en degré
  #-----------------------------------------------------------------------------------
  proc ArcPts {x y rad angle extent step debug} {
    set pts {}

    if { $extent > 0 } {
      for {set alpha $angle} {$alpha <= ($angle + $extent)} {incr $alpha $step} {
	foreach {xn yn} [RadPoint $x $y $rad $alpha] {}
	lappend pts $xn $yn
      }
    } else {
      for {set alpha $angle} {$alpha >= ($angle + $extent)} {incr $alpha $step} {
	lappend pts [RadPoint $x $y $rad $alpha]
      }
    }
    return $pts
  }

  #-----------------------------------------------------------------------------------
  # Graphics::RadPoint
  # retourne le point circulaire défini par centre-rayon-angle
  #-----------------------------------------------------------------------------------
  proc RadPoint {x y rad angle} {
    set alpha [deg2rad $angle]

    set xpt [expr {$x + ($rad * cos($alpha))}]
    set ypt [expr {$y + ($rad * sin($alpha))}]

    return [list $xpt $ypt]
  }


  #-----------------------------------------------------------------------------------
  # TabBoxCoords
  # Calcul des shapes de boites à onglets
  #
  # coords : coordonnées rectangle de la bounding box
  #
  # options
  #                  -numpages <n> : nombre de pages (onglets) de la boite
  #              -anchor [n|e|s|w] : ancrage des onglets
  # -alignment [left|center|right] : alignement des onglets sur le coté d'ancrage
  # -tabwidth [<n>|[<n1>,<n2>,<n3>...]|auto] : largeur des onglets
  #          -tabheight [<n>|auto] : hauteur des onglets
  #                  -tabshift <n> : décalage onglet
  #                    -radius <n> : rayon des arrondis d'angle
  #                   -overlap <n> : distance de recouvrement des onglets
  #-----------------------------------------------------------------------------------
  proc TabBoxCoords args {
    set coords [lindex $args 0]
    set options [lrange $args 1 end]
    foreach {p0 p1} $coords break
    foreach {x0 y0} $p0 {xn yn} $p1 break
    set numPages [TLGet $options -numpages 0]

    if { $x0 eq "" || $y0 eq "" || $xn eq "" || $yn eq "" || !$numPages } {
      puts "Vous devez au minimum spécifier le rectangle englobant et le nombre de pages"
      return {}
    }

    set anchor [TLGet $options -anchor n]
    set alignment [TLGet $options -alignment left]
    set len [TLGet $options -tabwidth auto]
    set thick [TLGet $options -tabheight auto]
    set biso [TLGet $options -tabshift auto]
    set radius [TLGet $options -radius 0]
    set overlap [TLGet $options -overlap 0]
    set orientation [expr {($anchor eq "n" || $anchor eq "s") ? "horizontal" : "vertical"}]
    set maxwidth [expr {($orientation eq "horizontal") ? ($xn - $x0) : ($yn - $y0)}]
    set tabswidth 0
    set align 1

    if { $len eq "auto" } {
      set tabswidth $maxwidth
      set len [expr {($tabswidth + ($overlap * ($numPages - 1)))/$numPages}]
    } else {
      if { [llength $len] > 1 } {
	foreach w $len {
	  set tabswidth [expr {$tabswidth + ($w - $overlap)}]
	}
	set tabswidth [expr {$tabswidth + $overlap}]
      } else {
	set tabswidth [expr {($len * $numPages) - ($overlap * ($numPages - 1))}]
      }
      if { $tabswidth > $maxwidth } {
	set tabswidth $maxwidth
	set len [expr {($tabswidth + ($overlap * ($numPages - 1)))/$numPages}]
      }
      if { $alignment eq "center" && (($maxwidth - $tabswidth) > $radius) } {
	set align 0
      }
    }
    if { $thick eq "auto" } {
      set thick [expr {($orientation eq "horizontal") ? \
	  int(($yn - $y0)/10.0) : int(($xn - $y0)/10.0)}]
      if {$thick < 10 } {
	set thick 10
      } elseif {$thick > 40} {
	set thick 40
      }
    }
    if { $biso eq "auto" } {
      set biso [expr {int($thick/2.0)}]
    }
    if { ($alignment eq "right" && $anchor ne "w") || \
	     ($anchor eq "w" && $alignment ne "right") } {
      if { [llength $len] > 1 } {
	for {set p 0} {$p < $numPages} {incr p} {
	    lset len $p [expr {-[lindex $len $p]}]
	}
      } else {
	  set len [expr {-$len}]
      }
      set biso [expr {-$biso}]
	set overlap [expr {-$overlap}]
    }

    if { $alignment eq "center" } {
      set biso1 [expr {$biso / 2.0}]
      set biso2 $biso1
    } else {
      set biso1 0
      set biso2 $biso
    }

    if { $orientation eq "vertical" } {
      if { $anchor eq "w" } {
	set thick [expr {-$thick}]
	set startx $x0
	set endx $xn
      } else {
	set startx $xn
	set endx $x0
      }
      if { ($anchor eq "w" && $alignment ne "right") || \
	($anchor eq "e" && $alignment eq "right") } {
	set starty $yn
	set endy $y0
      } else {
	set starty $y0
	set endy $yn
      }

      set xref [expr {$startx - $thick}]
      set yref $starty
      if  { $alignment eq "center" } {
	set ratio [expr {($anchor eq "w") ? -2 : 2}]
	set yref [expr {$yref + (($maxwidth - $tabswidth)/$ratio)}]
      }

      set cadre [list [list $xref $endy] [list $endx $endy] \
	[list $endx $starty] [list $xref $starty]]
      #
      # flag de retournement de la liste des pts de 
      # curve si nécessaire -> sens anti-horaire
      set inverse [expr {$alignment ne "right"}]
    } else {
      if { $anchor eq "s" } {
	set thick [expr {-$thick}]
      }
      if { $alignment eq "right" } {
	set startx $xn
	set endx $x0
      } else {
	set startx $x0
	set endx $xn
      }
      if { $anchor eq "s" } {
	set starty $yn
	set endy $y0
      } else {
	set starty $y0
	set endy $yn
      }

      set yref [expr {$starty + $thick}]
      if { $alignment eq "center" } {
	set xref [expr {$x0 + (($maxwidth - $tabswidth)/2.0)}]
      } else {
	set xref $startx
      }

      set cadre [list [list $endx $yref] [list $endx $endy] \
	[list $startx $endy] [list $startx $yref]]
      #
      # flag de retournement de la liste des pts de
      # curve si nécessaire -> sens anti-horaire
      set inverse [expr {($anchor eq "n" && $alignment ne "right") || \
	  ($anchor eq "s" && $alignment eq "right")}]
    }

    for {set i 0} {$i < $numPages} {incr i} {
      set pts {}
      #
      # décrochage onglet
      #push (@pts, ([$xref, $yref])) if $i > 0;
      #
      # cadre
      set pts [lrange $cadre 0 end]
      #
      # points onglets
      if { $i > 0 || ! $align } {
	lappend pts [list $xref $yref]
      }
      set tw [expr {([llength $len] > 1) ? [lindex $len $i] : $len}]
      if { $orientation eq "vertical" } {
	set tabdxy [list $thick $biso1 $thick [expr {$tw - $biso2}] 0 $tw]
      } else {
	set tabdxy [list $biso1 [expr {-$thick}] [expr {$tw - $biso2}] [expr {-$thick}] $tw 0]
      }
      foreach {dx dy} $tabdxy {
	lappend pts [list [expr {$xref + $dx}] [expr {$yref + $dy}]]
      }

      if { $radius } {
	if { $i > 0 || ! $align } {
	  set corners [list 0 1 1 1 0 1 1 0]
	} else {
	  set corners [list 0 1 1 0 1 1 0 0 0]
	}
	set curvePts [RoundedCurveCoords $pts [list -radius $radius -corners $corners]]
	if { $inverse } {
	  set curvePts [lreverse $curvePts]
	}
	lappend shapes $curvePts
      } else {
	if { $inverse } {
	  set pts [lreverse $pts]
	}
        lappend shapes $pts
      }

      if { $orientation eq "horizontal" } {
	lappend titlesCoords [list [expr {$xref + ($tw - ($biso2 - $biso1))/2.0}] \
				  [expr {$yref - ($thick/2.0)}]]
	set xref [expr {$xref + ($tw - $overlap)}]
      } else {
	lappend titlesCoords [list [expr {$xref + ($thick/2.0)}] \
	  [expr {$yref + ($len - (($biso2 - $biso1)/2.0))/2.0}]]
	set yref [expr {$yref + ($len - $overlap)}]
      }
    }

    return [list $shapes $titlesCoords $inverse]
  }

  #-----------------------------------------------------------------------------------
  # RESOURCES GRAPHIQUES GRADIENTS, PATTERNS, TEXTURES, IMAGES...
  #-----------------------------------------------------------------------------------
  #-----------------------------------------------------------------------------------
  # Graphics::SetGradients
  # création de gradient nommés Zinc
  #-----------------------------------------------------------------------------------
  proc SetGradients {zinc grads} {
    # initialise les gradients de taches
    if { ! [llength $v::Gradients] } {
      foreach {name gradient} $grads {
	# création des gradients nommés
	$zinc gname $gradient $name
	lappend v::Gradients $name
      }
    }
  }

  #-----------------------------------------------------------------------------------
  # Graphics::GetPattern
  # retourne la ressource bitmap en l'initialisant si première utilisation
  #-----------------------------------------------------------------------------------
  proc GetPattern {name} {
    global bitmaps imagePath

    if { ![info exists bitmaps($name)] } {
      set bitmap "@[file join $imagePath $name]"
      set bitmaps($name) $bitmap
      return $bitmap
    }
    return $bitmaps($name)
  }

  #-----------------------------------------------------------------------------------
  # Graphics::GetTexture
  # retourne l'image de texture en l'initialisant si première utilisation
  #-----------------------------------------------------------------------------------
  proc GetTexture {name} {
    global imagePath

    if { ![info exists v::textures($name)] } {
      set texture [image create photo -file [file join $imagePath $name]]
      if { $texture ne "" } {
	set v::textures($name) $texture
      }
      return $texture
    }
    return $v::textures($name)
  }

  #-----------------------------------------------------------------------------------
  # Graphics::GetImage
  # retourne la ressource image en l'initialisant si première utilisation
  #-----------------------------------------------------------------------------------
  proc GetImage {name} {
    global imagePath

    if { ![info exists v::images($name)] } {
      set image [image create photo -file [file join $imagePath $name]]
      if { $image ne "" } {
	set v::images($name) $image
      }
      return $image
    }
    return $v::images($name)
  }

  #-----------------------------------------------------------------------------------
  # Graphics::InitPixmaps
  # initialise une liste de fichier image
  #-----------------------------------------------------------------------------------
  proc InitPixmaps {pixFiles} {
    set imgs {}
    foreach f $pixFiles {
      lappend imgs [GetImage $f]
    }    
    return $imgs
  }


  proc _min {n1 n2} {
    return [expr {($n1 > $n2) ? $n2 : $n1}]
  }

  proc _max {n1 n2} {
    return [expr {($n1 > $n2) ? $n1 : $n2}]
  }

  #-----------------------------------------------------------------------------------
  # Graphics::_trunc
  # fonction interne de troncature des nombres: n = position décimale 
  #-----------------------------------------------------------------------------------
  proc _trunc {val n} {
    regexp {([0-9]+)\.?([0-9]*)} $val match ent dec
    set str [expr {($val < 0) ? -$ent : $ent}]
    if { ($dec ne "") && ($n != 0) } {
      set dec [string range $dec 0 [expr {$n-1}]]
      if { $dec != 0 } {
	set str "$str.$dec"
      }
    }
    return $str;
  }

  #-----------------------------------------------------------------------------------
  # Graphics::RGBdec2hex
  # conversion d'une couleur RGB (255,255,255) au format Zinc '#ffffff'
  #-----------------------------------------------------------------------------------
  proc RGBdec2hex {rgb} {
    return [eval "format {#%04x%04x%04x} $rgb"]
  }

  #-----------------------------------------------------------------------------------
  # zincGraphics::PathGraduate
  # création d'un jeu de couleurs dégradées pour item pathLine
  #-----------------------------------------------------------------------------------
  proc PathGraduate {numColors style} {
    set type [TLGet $style -type]
    set colors [TLGet $style -colors]

    if { $type eq "linear" } {
      return [CreateGraduate $numColors $colors 2]

    } elseif { $type eq "double" } {
      set colors1 [CreateGraduate [expr {$numColors/2+1}] [lindex $colors 0]]
      set colors2 [CreateGraduate [expr {$numColors/2+1}] [lindex $colors 1]]
      set clrs {}
      for {set i 0} {$i <= $numColors} {incr i} {
	lappend clrs [lindex $colors1 $i] [lindex $colors2 $i]
      }
      return $clrs

    } elseif { $type eq "transversal" } {
      foreach {c1 c2} $colors break
      set clrs [list $c1 $c2]
      for {set i 0} {$i < $numColors} {incr i} {
	lappend clrs $c1 $c2
      }
      return $clrs;
    }
  }

  #-----------------------------------------------------------------------------------
  # Graphics::CreateGraduate
  # création d'un jeu de couleurs intermédiaires (dégradé) entre n couleurs
  #-----------------------------------------------------------------------------------
  proc CreateGraduate {totalSteps refColors {repeat 1}} {
    set colors {}
    set numGraduates [expr {[llength $refColors] - 1}]

    if { $numGraduates < 1 } {
      puts "Le dégradé necessite au minimum 2 couleurs de référence..."
      return {}
    }

    set steps [expr {($numGraduates > 1) ? ($totalSteps/($numGraduates - 1.0)) : $totalSteps}]

    for {set c 0} {$c < $numGraduates} {incr c} {
      set c1 [lindex $refColors $c]
      set c2 [lindex $refColors [expr {$c+1}]]

      #
      # Pas de duplication de la couleur de raccord entre
      # deux segments
      set thisSteps $steps
      if { $c < [expr $numGraduates - 1] } {
	set thisSteps [expr $thisSteps - 1]
      }
      for {set i 0} {$i < $thisSteps} {incr i} {
	set color [ComputeColor $c1 $c2 [expr {$i/($steps-1.0)}]]
	for {set k 0} {$k < $repeat} {incr k} {
	  lappend colors $color
	}
      }
    }

    return $colors
  }

  #-----------------------------------------------------------------------------------
  # Graphics::computeColor
  # calcul d'une couleur intermédiaire défini par un ratio ($ratio) entre 2 couleurs
  #-----------------------------------------------------------------------------------
  proc ComputeColor {color0 color1 ratio} {
    if { $ratio > 1.0 } {
      set ratio 1
    } elseif { $ratio < 0 } {
      set ratio 0
    }

    foreach {r0 g0 b0 a0} [ZnColorToRGB $color0] break
    foreach {r1 g1 b1 a1} [ZnColorToRGB $color1] break

    set r [expr {$r0 + int(($r1 - $r0) * $ratio)}]
    set g [expr {$g0 + int(($g1 - $g0) * $ratio)}]
    set b [expr {$b0 + int(($b1 - $b0) * $ratio)}]
    set a [expr {$a0 + int(($a1 - $a0) * $ratio)}]
    return [HexaRGBcolor $r $g $b $a]
  }

  proc ZnColorToRGB {znColor} {
    foreach {color alpha} [split $znColor ";"] break
    set pattern [expr {[string length $color] > 8 ? {#%4x%4x%4x} : {#%2x%2x%2x}}]
    scan $color $pattern r g b

    if {$alpha eq ""} {
      set alpha 100
    }

    return [list $r $g $b $alpha]
  }

  #-----------------------------------------------------------------------------------
  # Graphics::hexaRGBcolor
  # conversion d'une couleur RGB (255,255,255) au format Zinc '#ffffff'
  #-----------------------------------------------------------------------------------
  proc HexaRGBcolor {r g b args} {
    if { [llength $args] } {
      return [format {#%02x%02x%02x;%d} $r $g $b [lindex $args 0]]
    } else {
      return [format {#%02x%02x%02x} $r $g $b]   
    }
  }
}

proc lreverse {l} {
    set res {}
    set i [llength $l]
    while {$i} {
	lappend res [lindex $l [incr i -1]]
    }
    return $res
}
