#!/usr/bin/perl
# $Id$
# these simple samples have been developped by C. Mertz mertz@cena.fr

use Tk;
use Tk::Zinc;
use strict;

my $defaultfont = '-b&h-lucida-bold-r-normal-*-*-140-*-*-p-*-iso10646-1';
my $mw = MainWindow->new();
my $zinc = $mw->Zinc(-width => 700, -height => 300,
#		     -render => 1,
		     -backcolor => "grey50", # this will be transparent in the doc
		     )->pack();


my $i = 1;
my $x = 40;
my $y = 40;
foreach my $contour ( (['left'], ['right'], ['top'], ['bottom'],
		       ['top', 'bottom'], ['left','right'], ['left','top'], ['contour'],
		       ['oblique'], ['counteroblique'],['oblique','counteroblique']) )  {
    my $tab = $zinc->add('tabular', 1, 1, -position => [$x, $y],
			 -labelformat => "a5a5+0+0",
			 );
    my $contour_text = "['" . join ("','",@{$contour}) . "']";
    $zinc->itemconfigure($tab, 0,
			 -text => $contour_text,
			 -border => $contour,
			 -alignment => "center",
			 -filled => 1,
			 -backcolor => "gray95",
);
    $i++;
    if ($i == 5) {
	$x = 40;
	$y = $y + 50;
	$i = 1;
    }
    else {
	$x = $x + 160;
    }
}



MainLoop();
