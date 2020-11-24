#!/usr/bin/perl
# $Id$
# these simple samples have been developped by C. Mertz mertz@cena.fr and N. Banoun banoun@cena.fr

use Tk;
use Tk::Zinc;
use strict;

my ($grp,, $s, $i);
my $defaultfont = '-b&h-lucida-bold-r-normal-*-*-140-*-*-p-*-iso10646-1';
my $mw = MainWindow->new();
my $zinc = $mw->Zinc(-width => 700, -height => 300,
		     -render => 1,
		     -backcolor => "red", # this will be transparent in the doc
		     )->pack();


$zinc->gname('black|white', 'axial 1');
$zinc->gname('black|white/90', 'axial 2');
$zinc->gname('black|white/30', 'axial 3');
$zinc->gname('black|black:0/30', 'axial 4');
$zinc->gname('white|black(-14 -20', 'radial 1');
$zinc->gname('white:50 0 70|black 50|white 100(0 0', 'radial 2');
$zinc->gname('white|black:80[-14 -20', 'path 1');
$zinc->gname('white|white 30|black:80[-14 -20', 'path 2');

$grp = $zinc->add('group', 1);
$zinc->add('rectangle', $grp, [0, 0, 70, 50],
	   -filled => 1,
	   -fillcolor => 'white',
	   );
$zinc->add('rectangle', $grp, [0, 0, 70, 50],
	   -filled => 1,
	   -linewidth => 1, # to help making the background transparent with gimp!

	   -fillcolor => 'axial 1',
	   -tags => ['rect']);
$zinc->add('text', $grp,
	   -text => 'axial 1',
	   -anchor => 'center',
	   -position => [35, -10],
	   -tags => ['txt']);
$zinc->translate($grp, 20, 30);
$i = 1;
foreach $s (('axial 2', 'axial 3', 'axial 4', 'radial 1',
	    'radial 2', 'path 1', 'path 2')) {
  $grp = $zinc->clone($grp);
  $zinc->addtag("g$grp", 'withtag', "$grp*attrs"); #, $grp, 0);
  $zinc->itemconfigure(".$grp.txt",
		       -text => $s);
  $zinc->itemconfigure(".$grp.rect",
		       -fillcolor => $s);
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
