#-----------------------------------------------------------------------------------
#
#      Copyright (C) 2002
#      Centre d'Études de la Navigation Aérienne
#
#      Authors: Jean-Luc Vinot <vinot@cena.fr> for the graphic design
#               Patrick Lecoanet for the tcl code.
#-----------------------------------------------------------------------------------
#      This small application illustrates both the use of groups in combination
#         of -composescale attributes and an implementation of kind of air traffic
#         control electronic strips.
#      However it is only a simplified example given as is, without any immediate usage!
#
#      3 strips formats are accessible through "+" / "-" buttons on the right side
#
#      1.   small-format: with 2 lines of info, and reduced length
#
#      2.   normal-format: with 3 lines of info, full length
#
#      3.  extended-format: with 3 lines of infos, full length
#                           the 3 lines are zoomed
#                           an additionnel 4th lone is displayed
#
#      An additionnal 4th format (micro-format) is available when double-clicking somewhere...
#
#      Strips can be moved around by drag&drop from the callsign
#
#      When changing size, strips are animated. The animation is a very simple one,
#        which should be enhanced.... You can change the animation parameters, by modifyng
#        $delay and $steps.
#
#-----------------------------------------------------------------------------------

if {![info exists zincDemo]} {
    error "This script should be run from the zinc-widget demo."
}

namespace eval groupsInAtcStrips {
  variable w .groupsInAtcStrips

  catch {destroy $w}
  toplevel $w
  wm title $w "Atc electronic strips using groups"
  wm iconname $w groupsInAtcStrips

  grid [button $w.dismiss -text Dismiss -command "destroy $w"] -row 2 -column 0 -pady 10
  grid [button $w.code -text "See Code" -command "showCode $w"] -row 2 -column 1 -pady 10



  ###########################################
  # Text zone
  #######################
  ####################

  grid [text $w.text -relief sunken -borderwidth 2 -height 5] \
    -row 0 -column 0 -columnspan 2 -sticky ew

  $w.text insert end {These fake air Traffic Control electronic strips illustrates
	the use of groups for an advanced graphic design.
	The following interactions are possible:
	"drag&drop button1" on the callsign.
	"button 1" triangle buttons on the right side of the strips
	to modify strips size
	"double click 1" on the blueish zone to fully reduce size}


  catch {font create dfont -family Helvetica -size 10 -weight bold}
  catch {font create radar-b15 -family helvetica -size 16 -slant roman -weight bold}
  catch {font create radar-b12 -family helvetica -size 12 -slant roman -weight bold}
  catch {font create radar-b10 -family helvetica -size 10 -slant roman -weight bold}
  catch {font create radar-m18 -family helvetica -size 18 -slant roman -weight normal}
  catch {font create radar-m20 -family helvetica -size 20 -slant roman -weight normal}

  set fontsets(scales) {1.2 normal 10 large}
  set fontsets(normal,callsign) radar-b15
  set fontsets(normal,type1) radar-b12
  set fontsets(normal,type2) radar-b10
  set fontsets(normal,type3) radar-b10
  set fontsets(large,callsign) radar-m20
  set fontsets(large,type1) radar-m18
  set fontsets(large,type2) radar-b15
  set fontsets(large,type3) radar-b12

  image create photo backtex -data {
    R0lGODlhIAAgAPcAALi4uLe3t7a2trS0tLOzs7KysrGxsbCwsK+vr66urq2traysrKurq6qq
    qqmpqaioqKenp6ampqWlpaSkpKOjo6KioqGhoaCgoJ+fn56enp2dnZycnJubm5qampmZmZiY
    mJeXl5aWlpWVlZSUlJOTk5KSkpGRkZCQkI+Pj46Ojo2NjYyMjIuLi4qKiomJiYiIiIeHh4aG
    hoWFhYSEhIODg4KCgoGBgYCAgH9/f35+fn19fXx8fHt7e3p6enl5eXh4eHR0dAAAAAAAAAAA
    AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
    AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
    AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
    AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
    AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
    AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
    AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
    AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
    AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
    AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
    AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAAAAAAALAAAAAAgACAABwj/ADto4ABCAwgS
    Ijps4NAhA4cJE0SIcJjhggUKDxxcGBEixAiGAz04oEDwQ4cQJjiU+MBhxAcNIzZMkGDBQgQI
    FDyEwGCBw4YNHShQMFhQQwcLIj5sAMEhAwkOEiSczFABQ0uaHjowLLhBxM4IEi54wFCBZQUO
    HixgGCECw9oPKSRw+OChroYJFECY+JAhQwkTGjCUGHEBgwi0JTo8qHCCA4oHHT6w1GBwRIcJ
    DyxIrvAgwswKGz5SnLD2RImHHRRqWNjUQoULGfZ2ABGi6VIMeCVAEEwhAwYKEkMUvPD652+X
    IVCkCBGYpwXfFTKEgKCho3AQIDAU3lB3A2wLGkSQ/zhawUJX00o1ZBCRIsXF1+A/gMjqwaTb
    urgnfCCB4sQIEArNRsIIE0RQgXonhZDVByKogFx2Qik3wm8ZyKdgZEKpBOBCHmDnAQl0SbRB
    TSKYIMIFE2hAFwoeZOBBZx2ckBIFmrmEgQQPUHASB27lZSIIInhQAQp3XbDdWB+gwIKD3vGF
    F3caULBAByqY4AGPETAwAVomWQABCHT5NJtlGag1l0AcmLCcehdI4IAFIJRwAgkXMJBUYBl0
    MMIJUeGlVl8ooECCdxlocEEEPYVQAgkeXAAUCCMM5oEGDDwwQQXlZbBBCSF4Z5VWq6n30wcj
    DBSnCSFckKNVdXUYZGCrbf/gG1sbVDBTeEwV6hNnhUbmoUKazmeBBBNEpgFNE4BXwlisanCW
    enONRdMFHYBoa19eWbUBT/95IEKgIPgF4EGl6rYlpxdoYCIMMgSqkAgSJLDABTx6oAIEB26b
    7pUkgBCVVhC0KFAGGVFgAoACVUABBpbCtlpkHiw6V5UYrHCCg3xVyGC4GPxkJGwdiFDCoubJ
    GoIKJICWZgiupesABhl49kEImvrWkgkuUVBBVBuAOEEDEoAZ3U9yQRWBehB4VxVDVDF1UXiH
    HehfV0HS25BDI2bFAUMcGApimfQCaWAIH4QlJXEZAClZTBB3HapvxIEWQgQRbE1qBxF8ABsJ
    JFRaBAIDiFYQwQPIWl1mzymUkMKgW28QQa1vahduX5T3hUEDcFIWQgeAURAa2R8kXSZ2HNBp
    kWuYnnX0eBzUNkIGQ3WgHQaPu3XYUOq5BXOhG0iwaUO1pvBfCAEBADs=
  }

  image create photo striptex -data {
    R0lGODlhCgBQAID/ALbd9tnn6ywAAAAACgBQAAACNYyPmcDtCqN0FMiL68Nc6daFx8eIImmZ
    HaquZMux8CXPUW17bw7h/Lj7IXxC4s/IQ+aUNmYBADuioNSSFFMFXrHZ7mMr8YpZ4LE5AX6d
    m+X1Oe1+t+NiOJ1UAAA7
  }

  ##########################################
  # Zinc
  ##########################################
  grid [zinc $w.zinc -render 1 -width 700 -height 500 -borderwidth 0 \
      -lightangle 130 -tile backtex] -row 1 -column 0 -columnspan 2 -sticky news
  grid columnconfigure $w 0 -weight 1
  grid columnconfigure $w 1 -weight 1
  grid rowconfigure $w 1 -weight 2

  catch "$w.zinc gname {=axial 90|#ffffff 0|#ffeedd 30|#e9d1ca 90|#e9a89a} idnt"
  catch "$w.zinc gname {#c1daff|#8aaaff} back"
  catch "$w.zinc gname {=path -40 -40|#000000;50 0|#000000;50 92|#000000;0 100} shad"
  catch "$w.zinc gname {#ffeedd|#8a9acc} btnOutside"
  catch "$w.zinc gname {=axial 180|#ffeedd|#8a9acc} btnInside"
  catch "$w.zinc gname {#8aaaff|#5b76ed} ch1"

  set anim(delay) 50;	# ms between each animation steps
  set anim(steps) 6;	# number of steps for the animation

  #
  # The strip building routine
  proc Strip { } {
    variable scale
    variable w
    #
    # Creating the object group
    set stripG [$w.zinc add group 1]
    #
    # Add a group for all items that will need scaling
    set scaleG [$w.zinc add group $stripG -tags scaling]    
    #
    # Add add background shadow
    $w.zinc add rectangle $scaleG {8 8 374 94} -filled 1 -linewidth 0 \
        -fillcolor shad -tags shadow
    # 
    # This is the strip background
    $w.zinc add rectangle $scaleG {0 0 340 86} -filled 1 \
        -linewidth 3 -linecolor {#aaccff} -fillcolor back -relief roundraised
    #
    # Add a group for the two size change buttons.
    set btnGroup [$w.zinc add group $scaleG]
    $w.zinc translate $btnGroup 340 0 true
    #
    # Clip the button group to a rectangular shape that will
    # be scaled with the rest of the strip.
    $w.zinc itemconfigure $btnGroup -clip [$w.zinc add rectangle $btnGroup {0 0 90 83} -visible no]
    # 
    # Here the cylindrical background of the button area.
    # The scale is not inherited to preserve the cylindrical
    # relief of the area, this is explain the need for a
    # clipping on btnGroup.
    $w.zinc add rectangle $btnGroup {0 0 26 85} -filled 1 -linewidth 0 \
        -fillcolor btnOutside -composescale 0 -tags content
    
    ArrowButton $btnGroup + {0 0 26 43} {14 2 24 40 1 40 14 2} {13 27} [list $stripG more content]
    ArrowButton $btnGroup - {0 43 26 86} {14 83 24 43 1 43 14 83} {13 56} [list $stripG less content]
   
    #
    # This group will get the strip useful content. Its area is clipped.
    set clippedContent [$w.zinc add group $scaleG]
    $w.zinc itemconfigure $clippedContent \
        -clip [$w.zinc add rectangle $clippedContent {3 3 332 80} -visible 0]
    # 
    # One more group to control whether the scale is inherited or not.
    set content [$w.zinc add group $clippedContent -composescale 0 -tags content]
    # 
    # The strip is divided into functional textual zones.
    # They are created here.
    set input [Zone $content {3 3 334 82} 0 white back {} flat [list $stripG scale input]]
    TextField $input TYPA type1 {100 18} {#444444} w
    TextField $input 08:26 type1 {200 18} {#444444} e
    TextField $input NIPOR type2 {100 40} {#444444} w
    TextField $input 8G type2 {158 40} {#444444} center
    TextField $input G23 type2 {200 40} {#444444} e
    TextField $input DEST type2 {10 66} {#555555} w
    TextField $input Bret. type2 {200 66} {#444444} e
    RectField $input {45 56 135 76} ch1

    Zone $content {210 3 346 82} 2 {#deecff} {#d3e5ff} striptex sunken {zreco edit}

    set ident [Zone $content {3 3 90 50} 1 {#ffeedd}  idnt {} sunken [list $stripG move]]
    $w.zinc raise $ident
    TextField $ident EWG361 callsign {10 18} {#000000} w
    TextField $ident Eurowing type2 {10 34} {#444444} w
    #
    # Add and extension area beneath the main strip
    # This extension is shown when the strip is shown in its
    # extended form.
    set extent [$w.zinc add group $scaleG -atomic yes -tags {zinfo edit2}]
    $w.zinc translate $extent 0 86 true
    # 
    # Add a background shadow.
    $w.zinc add rectangle $extent {8 8 348 28} \
        -filled 1 -linewidth 0 -tags shadow -fillcolor shad
    #
    # This is the extention background
    $w.zinc add rectangle $extent {0 0 340 20} -filled 1 \
        -linewidth 2 -linecolor {#aaccff} -fillcolor back -relief roundraised
    TextField $extent 7656 type3 {4 10} {#444444} w
    TextField $extent G23 type3 {47 10} {#444444} center
    TextField $extent 09R type3 {73 10} {#444444} center
    TextField $extent vit: type3 {105 10} {#444444} e
    TextField $extent 260 type3 {106 10} {#444444} w
    TextField $extent EPL type3 {142 10} {#444444} center
    TextField $extent 210 type3 {166 10} {#444444} center
    TextField $extent 8350 type3 {183 10} {#444444} w
    TextField $extent MOD type3 {219 10} {#444444} w
    TextField $extent 21/05/02 type3 {297 10} {#444444} e
    TextField $extent 13:50 type3 {332 10} {#444444} e
    DisplayExtentZone $stripG no

  #
  # Preset the scale and font size of the layout
    set scale($stripG,x) 1.0
    set scale($stripG,y) 1.0
    set scale($stripG,fontset) normal

    return $stripG
  }
      
  proc ArrowButton {top text coords arrow labelpos tags} {
    variable w
    set sGroup [$w.zinc add group $top -atomic 1 -composescale 0 -tags $tags]
    $w.zinc add rectangle $sGroup $coords -filled 1 -visible 0
    $w.zinc add curve $sGroup $arrow -closed 1 -filled 1 \
        -linewidth 1  -linecolor {#aabadd} -fillcolor btnInside
    $w.zinc add text $sGroup -position $labelpos -text $text \
        -font radar-m20 -color {#ffffff} -anchor center
  }

  proc RectField {top coords fillcolor} {
    variable w
    $w.zinc add rectangle $top $coords -linewidth 0 -filled yes \
        -fillcolor $fillcolor
  }

  proc TextField {top text fonttype coords color anchor} {
    variable w
    variable fontsets
    $w.zinc add text $top -position $coords -text $text -font $fontsets(normal,$fonttype) \
        -color $color -anchor $anchor -tags $fonttype
  }

  proc Zone {top coords linewidth linecolor fillcolor texture relief tags} {
    variable w
  #
  # Zone group
    set gz [$w.zinc add group $top -atomic 1 -tags $tags]
  #
  # Zone background
    set rectZone [$w.zinc add rectangle $gz $coords \
                      -filled yes -linewidth $linewidth -linecolor $linecolor \
                      -fillcolor $fillcolor -relief $relief]
    if { $texture ne "" } { 
      $w.zinc itemconfigure $rectZone -tile $texture
    }

    return $gz
  }

  #
  # Called when the user click on the strip's identification area.
  proc CatchStrip {x y} {
    variable w
    variable dx
    variable dy
    
    set strip [lindex [$w.zinc itemcget current -tags] 0]
    foreach {lx ly} [$w.zinc coords $strip] break
    set dx [expr {$lx - $x}]
    set dy [expr {$ly - $y}]
    $w.zinc raise $strip
  }

  #
  # Called when the mouse drag the strip
  proc MotionStrip {x y} {
    variable w
    variable dx
    variable dy

    set strip [lindex [$w.zinc itemcget current -tags] 0]
    $w.zinc translate $strip [expr $x + $dx] [expr $y + $dy] true
  }

  #
  # ExtendedStrip, NormalStrip, SmallStrip, MicroStrip
  # Those functions controls the transition from the current
  # strip layout to the named layout.
  # They are bonud to the resize buttons to the right of
  # the strip.
  proc NormalStrip {} {
    variable w
    set strip [lindex [$w.zinc itemcget current -tags] 0]
    $w.zinc itemconfigure $strip*input -sensitive 1

    DisplayRecoZone $strip yes
    DisplayExtentZone $strip no
    ConfigButtons $strip ExtendedStrip SmallStrip
    ChangeStripFormat $strip 1 1 no
  }

  proc SmallStrip {} {
    variable w
    set strip [lindex [$w.zinc itemcget current -tags] 0]
    DisplayRecoZone $strip no
    ConfigButtons $strip NormalStrip {}
    ChangeStripFormat $strip 1 0.63 no
  }

  proc MicroStrip {} {
    variable w
    set strip [lindex [$w.zinc itemcget current -tags] 0]
    ConfigButtons $strip NormalStrip {}
    ChangeStripFormat $strip 0.28 0.63 no
  }

  proc ExtendedStrip {} {
    variable w
    set strip [lindex [$w.zinc itemcget current -tags] 0]
    $w.zinc itemconfigure $strip*input -sensitive 0
    $w.zinc raise $strip
    DisplayRecoZone $strip no
    DisplayExtentZone $strip yes
    ConfigButtons $strip {} NormalStrip
    ChangeStripFormat $strip 1.3 1.3 yes
  }

  #
  # Controls the display of the gesture recognition area.
  proc DisplayRecoZone {strip bool} {
    variable w
    $w.zinc itemconfigure $strip*zreco -visible $bool
  }

  #
  # Controls the display of the extended information area.
  proc DisplayExtentZone {strip bool} {
    variable w
    $w.zinc itemconfigure $strip*zinfo -visible $bool -sensitive $bool
  }

  #
  # Update the scaling buttons to reflect the current
  # layout of the strip.
  proc ConfigButtons {strip funcUp funcDown} {
    variable w
    if { $funcUp ne "" } {
      $w.zinc itemconfigure $strip*more -visible 1
      $w.zinc bind more <1> ::groupsInAtcStrips::$funcUp
    } {
      $w.zinc itemconfigure $strip*more -visible 0
    }
    if { $funcDown ne "" } {
      $w.zinc itemconfigure $strip*less -visible 1
      $w.zinc bind less <1> ::groupsInAtcStrips::$funcDown
    } {
      $w.zinc itemconfigure $strip*less -visible 0
    }
  }

  #
  # Change the strip size hiding information has needed.
  # Uses an animation to highlight the state change to te user.
  proc ChangeStripFormat {strip xscale yscale composeflag} {
    variable w
    variable scale
    variable anim
    #
    # Adjust the scale inheritance of the content area 
    $w.zinc itemconfigure $strip*content -composescale $composeflag
    #
    # Compute the scaling animation and start it.
    # At the same time if needed switch to bigger/smaller fonts.
    set dx [expr {($xscale - $scale($strip,x)) / $anim(steps)}]
    set dy [expr {($yscale - $scale($strip,y)) / $anim(steps)}]
    set newXScale [expr {$scale($strip,x) + $dx}]
    set newYScale [expr {$scale($strip,y) + $dy}]
    set scale($strip,x) $xscale
    set scale($strip,y) $yscale
    SetFontes $strip
    ::groupsInAtcStrips::ResizeAnim $strip $newXScale $newYScale $dx $dy $anim(steps)
  }

  #
  # This is the animation stepping function
  proc ResizeAnim {strip xscale yscale dx dy steps} {
    variable w
    variable anim
    $w.zinc treset $strip*scaling
    $w.zinc scale $strip*scaling $xscale $yscale
    incr steps -1
    if { $steps > 0 } {
      after $anim(delay) [list ::groupsInAtcStrips::ResizeAnim $strip [expr {$xscale+$dx}] \
                        [expr {$yscale+$dy}] $dx $dy $steps]
    }
  }

  proc SetFontes {strip} {
    variable w
    variable scale
    variable fontsets
    #
    # Find a fontset matching the current y scale
    foreach {maxScale fs} $fontsets(scales) {
      if { $scale($strip,y) < $maxScale } break
    }
    if { $scale($strip,fontset) ne $fs } {
      foreach type {callsign type1 type2 type3} {
        $w.zinc itemconfigure $strip*$type -font $fontsets($fs,$type)
      }
    }
    set scale($strip,fontset) $fs
  }
  #
  # Initialization of user input bindings..
  $w.zinc bind more <1> ::groupsInAtcStrips::ExtendedStrip
  $w.zinc bind less <1> ::groupsInAtcStrips::SmallStrip
  $w.zinc bind move <1> {::groupsInAtcStrips::CatchStrip %x %y}
  $w.zinc bind move <B1-Motion> {::groupsInAtcStrips::MotionStrip %x %y}
  $w.zinc bind scale <Double-Button-1> ::groupsInAtcStrips::MicroStrip

  #
  # Generate a handful of strips
  for {set xn 10; set yn 30; set i 0} {$i < 4} {incr i; incr xn 50; incr yn 120} {
    $w.zinc translate [Strip] $xn $yn true
  }
}
