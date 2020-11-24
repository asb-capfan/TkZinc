#-----------------------------------------------------------------------------------
# MagicLens.tcl
#
#  This small demo shows the use of groups, transformations, clipping
#  gradients and multi-contour curves to produce a structured and non
#  trivial small application
#
#      Authors: Jean-Luc Vinot <vinot@cena.fr>
#		            Patrick Lecoanet (Translation to Tcl).
#
#-----------------------------------------------------------------------------------

if {![info exists zincDemo]} {
  error "This script should be run from the zinc-widget demo."
}

namespace eval magicLens {

  image create photo paper -data {
    R0lGODlhIAAgALMAAAAAAP///6ysrKKiogAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
    AAAAAAAAACH5BAAAAAAALAAAAAAgACAAAwSzUIgxpKzzTmqprximgRxpdaQ3ot0YZm8Gfyp8
    fhuYc9stXzxVqCTT2Wy6F1HZGyaPJRGwuIvOejfpMrgSxbBHDTXFihp/LW2V7EUxrVLkzLyU
    s4CpWJKHNffbaXI4LU1VhUJoRV5vTVtXOWVQgSaIXHF1hJWQlHF3aXo+NV1zLos/W08moaWP
    lp6Eo0Z8kGKpdrNZSLaruHV8e4e/RIYuV2eGT4Ktbr9/kpc7p6Wud4iNAhEAOw==
  }

  catch {font create magfont -family Helvetica -size 13 -weight bold}
  catch {font create nfont -family Helvetica -size 11 -weight normal}

  #
  # The basics colors, one per column.
  set basicColors {
    {Yellow {#fff52A} {#f1f1f1} {#6a6611}}
    {"Yellow\nOrange" {#ffc017} {#cfcfcf} {#6b510a}}
    {Orange {#ff7500} {#a5a5a5} {#622d00}}
    {Red {#ff2501} {#8b8b8b} {#620e00}}
    {Magenta {#ec145d} {#828282} {#600826}}
    {"Red\nViolet" {#a41496} {#636363} {#020940}}
    {"Violet\nBlue" {#6a25b6} {#555555} {#2a0f48}}
    {Blue {#324bde} {#646464} {#101846}}
    {Cyan {#0a74f0} {#818181} {#064a9a}}
    {"Green\nBlue" {#009bb4} {#969696} {#006474}}
    {Green {#0fa706} {#979797} {#096604}}
    {"Yellow\nGreen" {#9dd625} {#c9c9c9} {#496311}}
  }

  #
  # Compute a set of interpolated colors
  #
  proc CreateGraduate {steps color1 color2} {
    scan $color1 {#%2x%2x%2x} r1 g1 b1
    scan $color2 {#%2x%2x%2x} r2 g2 b2
    set colors [list]
    for {set i 0} {$i < $steps} {incr i} {
      set ratio [expr {$i/($steps-1.0)}]
      lappend colors [format {#%02x%02x%02x} \
                          [expr {$r1 + int(($r2 - $r1) * $ratio)}] \
                          [expr {$g1 + int(($g2 - $g1) * $ratio)}] \
                          [expr {$b1 + int(($b2 - $b1) * $ratio)}]]
    }
    return $colors
  }

  set dx 0
  set dy 0
  set zoom 1.20
  set width 1000
  set height 900
  set simpleLens 1

  variable w .magicLens
  catch {destroy $w}
  toplevel $w
  wm title $w "Color Magic Lens Demonstration"
  wm iconname $w magicLens

  grid [button $w.dismiss -text Dismiss -command "destroy $w"] -row 2 -column 0 -pady 10
  grid [button $w.code -text "See Code" -command "showCode $w"] -row 2 -column 1 -pady 10
  #
  # Create a Zinc instance
  grid [zinc $w.zinc -render 1 -width $width -height $height -borderwidth 0 \
         -tile paper -backcolor {#cccccc}] -row 0 -column 0 -columnspan 2 -sticky ew
  #
  # The main view. The unzoomed world is here.
  $w.zinc add group 1 -tags normview
  #
  # The hidden view. It holds the hidden world.
  # It is clipped by the lens shape.
  $w.zinc add group 1 -tags hiddenview
  #
  # Create the lens itself. It is made of an atomic
  # group, a back to catch the mouse events and a
  # border. The back is not visible but remain sensitive.
  if { $simpleLens } {
    $w.zinc add arc 1 {{-100 -100} {100 100}} -tags {lens lensback} \
          -linewidth 2 -linecolor {#222266;80} -filled 1 -fillcolor {#ffffff;0}
  } {
    $w.zinc add group 1 -atomic yes -tags lens
    $w.zinc add arc lens {{-100 -100} {100 100}} -tags lensborder -linewidth 2 \
        -linecolor {#222266;80}
    $w.zinc clone lensborder -filled yes -visible no -tags lensback
  }
  #
  # Add the clipping shape to the hidden view so that we can view
  # the magnified view only within the lens.
  $w.zinc clone lensback -visible yes -filled yes -tile paper \
       -fillcolor {#ffffff;100} -tags {lens lenszone}
  $w.zinc chggroup lenszone hiddenview true
  $w.zinc itemconfigure hiddenview -clip lenszone
  #
  # The zoomed view is inside the hidden view.
  $w.zinc add group hiddenview -tags magview
  $w.zinc scale magview $zoom $zoom
  #
  # Create the vertical color stripes in both normal and magnified views.
  # In the normal view multi-contours curves are used, they are filled
  # with vertical axial gradients. In the magnified view arc items are
  # used filled with solid colors.
  set x 60
  foreach colorDesc $basicColors {
    #
    # Color Description : name, Saturated, Unsaturated, Shadow
    foreach {colorName satColor greyColor shadColor} $colorDesc break
    #
    # Add a group in each view
    set normGroup [$w.zinc add group normview]
    $w.zinc translate $normGroup $x 60 yes
    set magGroup [$w.zinc add group magview]
    $w.zinc translate $magGroup $x 60 yes
    #
    # Reference color on a ball shaped item.
    set refBall [$w.zinc add arc $normGroup {{-30 -30} {30 30}} \
          -fillcolor "=radial -12 -20|white 0|$satColor 40|$shadColor 100" \
          -linewidth 2 -filled 1]
    #
    # Clone the reference ball and move it into the magview group
    $w.zinc chggroup [$w.zinc clone $refBall] $magGroup
    #
    # Add the color name in magview
    $w.zinc add text $magGroup -text $colorName -anchor center \
         -alignment center -font magfont -spacing 2
    #
    # Create the color samples (Multi contours curve)
    set gradientBar [$w.zinc add curve $normGroup {} -linewidth 2 \
         -filled 1 -fillcolor "=axial 270|$satColor|$greyColor"]
    #
    # Create intermediate steps between colors (saturated -> unsaturated)
    set c 0
    foreach color [CreateGraduate 11 $satColor $greyColor] {
      # Create a zinc item for the color
      set sample [$w.zinc clone $refBall -fillcolor $color]
      $w.zinc translate $sample 0 [expr {65*($c+1)}]
      # 
      # Add its shape to the multi-contours gradient bar
      $w.zinc contour $gradientBar add 1 $sample
      #
      # Move the item to the maggroup
      $w.zinc chggroup $sample $magGroup
      # 
      # Text of label Saturation % + Color.
      set sampleText [$w.zinc add text $magGroup -text "[expr {((10 - $c)*10)}]%\n$color" \
          -anchor center -alignment center -font nfont -composescale no]
      $w.zinc translate $sampleText 0 [expr {65*($c+1)}]
      incr c
    }
    incr x 80
  }
  #
  # Add the caption text.
  $w.zinc add text normview -position {30 840} -font nfont -tags blurb -color white \
      -text "Move the Magic Lens on a color to see the color value and saturation"
  $w.zinc chggroup [$w.zinc clone blurb -font magfont] magview
  #
  # Lens motion callback proc.
  proc LensMove {x y} {
    variable w
    variable zoom
    $w.zinc translate lens $x $y yes
    $w.zinc translate magview [expr {$x * (1-$zoom)}]  [expr {$y * (1-$zoom)}] yes
  }
  #
  # The bindings needed to drag the lens.
  $w.zinc bind lens <B1-Motion> {::magicLens::LensMove %x %y}
  #
  # Lets put the lens somewhere within the window area.
  LensMove 300 110
}
