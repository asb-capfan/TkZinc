#!/usr/bin/perl -w

use Tk;
use Tk::Zinc;
use Controls;
use Tk::Photo;
require Tk::PNG;
    
$mw = MainWindow->new();
$logo = $mw->Photo(-file => "logo.gif");
$papier = $mw->Photo(-file => "texture-paper.xpm");
$penguin = $mw->Photo(-format => 'png',
		      -file => "xpenguin.png");

$top = 1;
$zinc = $mw->Zinc(-render => 1,
		  -borderwidth => 0,
		  -highlightthickness => 0,
		  -relief => 'sunken',
		  -takefocus => 1,
		  -tile => $papier);
$zinc->pack(-expand => 1, -fill => 'both');
$zinc->configure(-width => 500, -height => 500);
$gr1 = $zinc->add('group', $top);
$clip = $zinc->add('arc', $gr1, [50, 50, 399, 399],
		   -filled => 1,
		   -fillcolor => 'Pink:40',
#		   -fillpattern => 'AlphaStipple4',
		   -linewidth => 0);
#$zinc->itemconfigure($gr1, -clip => $clip);
$gr2 = $zinc->add('group', $gr1);
$clip2 = $zinc->add('rectangle', $gr2, [200, 200, 450, 300],
		    -filled => 1,
#		    -fillcolor => 'white:100|white:0',
		    -fillcolor => 'white:100 0|black:100 100/90',
#		    -fillcolor => 'white 0 |blue 20|blue 80|black:0 100/270',
		    -linewidth => 0);
#$zinc->itemconfigure($gr2, -clip => $clip2);
$view = $zinc->add('group', $gr2, -tags => "controls");
$zinc->lower($clip);
$zinc->lower($clip2);

new Controls($zinc);

$cv2 = $zinc->add('curve', $view, [],
		  -linewidth => 2);
$cv3 = $zinc->add('curve', $view, [],
		  -linewidth => 2);

$tri2 = $zinc->add('triangles', $view, [50, 50, 300, 50, 150, 150, 300, 150],
		   -colors => ['tan:50', '', '', 'red']);
$zinc->contour($cv2, 'union', $tri2);

$tri3 = $zinc->add('triangles', $view, [150, 150, 50, 50, 150, 50, 300, 50],
		   -colors => ['grey50', 'blue', 'red', 'yellow'],
		   -fan => 1);
$tri4 = $zinc->clone($tri3, -colors => ['grey', 'red']);
$zinc->translate($tri4, 100, 300);

$zinc->contour($cv3, 'union', $tri3);
$zinc->translate($tri3, 0, 300);
$zinc->translate($cv3, 0, 300);

$zinc->monitor(1);
$mw->Tk::bind('<p>', sub { print "perfs: ", join(',', $zinc->monitor()), "\n" });
$mw->Tk::bind('<t>', sub { $zinc->remove($arc); });
$mw->Tk::bind('<q>', sub { exit(0); });
$zinc->focusFollowsMouse();
MainLoop();
