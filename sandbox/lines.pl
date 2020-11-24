#!/usr/bin/perl -w

use Tk;
use Tk::Zinc;
    
$mw = MainWindow->new();

$top = 1;
$zinc = $mw->Zinc(-render => 1,
		  -borderwidth => 0,
		  -highlightthickness => 0,
		  -relief => 'sunken',
		  -takefocus => 1,
#		  -tile => $papier
		  );
$zinc->pack(-expand => 1, -fill => 'both');
$zinc->configure(-width => 500, -height => 500);

print "coucou\n";
$view = $zinc->add('group', $top, -tags => "controls");
$mp3 = $zinc->add('curve', $view, [20, 280, 100, 430, 200, 430],
		  -linewidth => 9,
		  -closed => 0,
		  -linestyle => 'dashed',
		  -joinstyle => 'round',
#		  -firstend => [3, 12, 8],
#		  -lastend => "12 12 8",
		  -capstyle => 'round',
		  -linecolor => 'red:100');

$mw->Tk::bind('<p>', sub { print "perfs: ", join(',', $zinc->monitor()), "\n" });
$mw->Tk::bind('<t>', sub { $zinc->remove($mp3); });
$mw->Tk::bind('<q>', sub { exit(0); });
$zinc->focusFollowsMouse();
MainLoop();
