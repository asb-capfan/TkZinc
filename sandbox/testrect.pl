#!/usr/bin/perl -w

use Tk;
use Tk::Zinc;

use Controls;

$mw = MainWindow->new();


###################################################
# creation zinc
###################################################
$top = 1;
$zinc_width = 800;
$zinc_height = 500;

$zinc = $mw->Zinc(-backcolor => 'gray65', -relief => 'sunken');
$zinc->pack(-expand => 1, -fill => 'both');
$zinc->configure(-width => $zinc_width, -height => $zinc_height);

#$zinc->configure(-drawbboxes => 1);

#print "cells ", $zinc->cells(), " visual ", $zinc->visual(), " ", $zinc->visualsavailable(), "\n";

$zinc->scale($top, 1, -1);
$view = $zinc->add('group', $top, -tags => ["controls"]);
$zinc->translate($view, 300, -200);
$view2 = $zinc->add('group', $top);
$zinc->translate($view2, 100, -50);


#$rect0 = $zinc->add('rectangle', $view [100, -105, 200, -305],
#                    -filled => t,
#                    -fillcolor => "white|cadetblue3");

$color1 = 'darkslateblue';
$color2 = '#f0ffff';
$gangle = 0;
$shades = 8;
$rect1 = $zinc->add('rectangle', $view, [-50, 100, 50, -100],
		    -filled => 1,
		    -relief => 'flat',
		    -linewidth => 1,
		    -fillpattern => 'AlphaStipple7',
		    -fillcolor => "$color1|$color2/$gangle%$shades");
#
# Mire
$zinc->add('curve', $view, [-10, 0, 10, 0],
	   -linecolor => 'red');
$zinc->add('curve', $view, [0, -10, 0, 10],
	   -linecolor => 'red');

$handle = $zinc->add('arc', $view, [-3, -106, 3, -112],
		     -filled => 1,
		     -fillcolor => 'red');
$zinc->bind($handle, '<B1-Motion>', \&adjustcontrol);

sub adjustcontrol {
    my $ev = $zinc->XEvent();
    my $x;
    my $y;
    my ($xo, $yo, $xc, $yc) = $zinc->coords($rect1);

    ($x, $y) = $zinc->transform($view, [$ev->x, 0]);
    if ($x < $xo) {
	$x = $xo;
    }
    elsif ($x > $xc) {
	$x = $xc;
    }
    $zinc->coords($handle, [$x - 3, $yc-6, $x + 3, $yc-12]);
    $x = ($x - $xo)*100/($xc-$xo);
    $zinc->itemconfigure($rect1,
			 -fillcolor => "$color1 0 $x|$color2/$gangle%$shades");
}

#
# 72 61 139 = DarkSlateBlue
#
# 240 255 255 = azure
#
#set rect2 [.r add rectangle $view "202 -320 302 -350" -filled t -fillcolor darkgray -linewidth 2]

#set rect3 [.r add rectangle $view "250 -100 350 -300" -filled t -relief raised -linewidth 4 -fillcolor "white|cadetblue3" -linecolor white]

#set rect4 [.r add rectangle $view2 "0 0 101 -81" -linewidth 2 -linecolor darkgray -filled t]
#.r itemconfigure $rect4 -fillcolor "white|darkslateblue"

#set rect5 [.r add rectangle $view2 "0 0 101 -81" -linewidth 2 -linecolor blue -filled t -fillcolor blue -relief sunken]
#.r translate $rect5 0 -90


new Controls($zinc);

MainLoop();


1;
