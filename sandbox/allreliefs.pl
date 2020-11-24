#!/usr/bin/perl
# $Id$
# these simple samples have been developped by C. Mertz mertz@cena.fr and N. Banoun banoun@cena.fr

use Tk;
use Tk::Photo;
use Tk::Zinc;
use strict;

my ($grp,, $s, $i);
my $defaultfont = '-adobe-helvetica-bold-r-normal-*-100-*-*-*-*-*-*';
my $mw = MainWindow->new();
my $zinc = $mw->Zinc(-width => 700, -height => 300,
		     -render => 1,
		     -backcolor => "red", # this will be transparent in the doc
		     )->pack();


$grp = $zinc->add('group', 1);
$zinc->add('rectangle', $grp, [0, 0, 70, 50],
	   -filled => 1,
	   -fillcolor => 'tan',
	   -linecolor => 'tan',
	   -linewidth => 6,
	   -relief => 'raised',
	   -tags => ['attrs']);
$zinc->add('text', $grp,
	   -text => 'raised',
	   -anchor => 'center',
	   -font => $defaultfont,
	   -position => [35, -10],
	   -tags => ['attrs']);
$zinc->translate($grp, 20, 30);
$i = 1;
foreach $s (('sunken', 'ridge', 'groove',
	     'roundraised', 'roundsunken', 'roundridge', 'roundgroove',
	     'raisedrule', 'sunkenrule')) {
  $grp = $zinc->clone($grp);
  $zinc->addtag("g$grp", 'withtag', 'attrs', $grp, 0);
  $zinc->itemconfigure("attrs && g$grp",
		       -text => $s,
		       -relief => $s);
  $i++;
  if ($i == 5) {
    $zinc->translate($grp, -3*100, 80);
    $i = 1;
  }
  else {
    $zinc->translate($grp, 100, 0);
  }
}


MainLoop();
