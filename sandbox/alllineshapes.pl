#!/usr/bin/perl
# $Id$
# these simple samples have been developped by C. Mertz mertz@cena.fr

use Tk;
use Tk::Zinc;
use strict;

my $defaultfont = '-b&h-lucida-bold-r-normal-*-*-140-*-*-p-*-iso10646-1';
my $mw = MainWindow->new();
my $zinc = $mw->Zinc(-width => 700, -height => 420,
#		     -render => 1,
#		     -backcolor => "red", # this will be transparent in the doc
		     )->pack();


my $i = 1;
my $x = 20;
my $y = 20;
foreach my $lineshape ( qw(straight rightlightning leftlightning
			   rightcorner leftcorner doublerightcorner
			   doubleleftcorner) ) {
    my $wpt = $zinc->add('waypoint', 1, 1,
			 -position => [$x, $y],
			 -labelformat => "a5a5+0+0",
			 -leaderanchors => '% 100x100',
			 -leadershape => $lineshape,
			 -labeldistance => 120,
			 );
    $zinc->itemconfigure($wpt, 0,
			 -text => $lineshape,
			 -alignment => "center",
			 );
    $i++;
    if ($i == 4) {
	$x = 20;
	$y = $y + 150;
	$i = 1;
    }
    else {
	$x = $x + 210;
    }
}



MainLoop();
