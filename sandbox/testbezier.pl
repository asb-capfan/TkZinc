#!/usr/bin/perl -w


use Tk;
use Tk::Zinc;
use Controls;
use Tk::Photo;
require Tk::PNG;


$top = 1;
$lw = 8;
$arrow = [8, 10, 6];

#
#          Cap, Filled, Border, Relief, Title
#
@show = (
	 ['round',      0, 1, 'flat',   'CapRound'],
	 ['butt',       0, 1, 'flat',   'CapButt'],
	 ['projecting', 0, 1, 'flat',   'CapProjecting'],
	 ['round',      0, 1, 'sunken', 'Sunken'],
	 ['round',      0, 1, 'raised', 'Raised'],
	 ['round',      0, 1, 'groove', 'Groove'],
	 ['round',      0, 1, 'ridge',  'Ridge'],
	 ['round',      1, 1, 'roundsunken', 'RoundSunken'],
	 ['round',      1, 1, 'roundraised', 'RoundRaised'],
	 ['round',      1, 1, 'roundgroove', 'RoundGroove'],
	 ['round',      1, 1, 'roundridge',  'RoundRidge'],
	 ['round',      1, 1, 'sunkenrule', 'SunkenRule'],
	 ['round',      1, 1, 'raisedrule',  'RaisedRule'],
	 ['round',      1, 0, 'flat',   'Fill'],
	 ['round',      1, 1, 'flat',   'FillBorder']);

$mw = MainWindow->new();
#$logo = $mw->Photo(-file => "logo.gif");
$papier = $mw->Photo(-file => "texture-paper.xpm");

$zinc = $mw->Zinc(-render => 1,
		  -lightangle => 120,
		  -borderwidth => 0,
		  -highlightthickness => 0,
		  -relief => 'sunken',
		  -takefocus => 1,
		  -backcolor => 'red'
	#	  -tile => $papier
		  );
$zinc->pack(-expand => 1, -fill => 'both');
$zinc->configure(-width => 500, -height => 500);
$zinc->scale($top, 1, -1);

$view = $zinc->add('group', $top,
		   -tags => 'controls');
$clipbez = $zinc->add('bezier', $view, [20, -20,
					890, -20,
					890, -900,
					20, -400],
		      -linewidth => 0,
		      -filled => 1,
		      -fillcolor => 'tan');
#$zinc->itemconfigure($view,
#		     -clip => $clipbez);

#
# Create the model
#
$model = $zinc->add('group', $view);
$mp = $zinc->add('bezier', $model, [50, -150,
				    100, -50,
				    270, -130,
				    220, -200,
				    200, -180,
				    180, -300,
				    140, -160,
				    70, -300],
		 -fillcolor => 'tan',
		 -tags => 'bezier',
		 -linewidth =>$lw);
#$zinc->add('rectangle', $model, [50, -150, 100, -50]);
@bbox = $zinc->bbox($mp);
@bbox = $zinc->transform($model, \@bbox);
$x = ($bbox[2] + $bbox[0]) / 2;
$y = $bbox[1] + 5;
$zinc->add('text', $model,
	   -text => 'CapRound',
	   -color => 'blue',
	   -alignment => 'center',
	   -anchor => 's',
	   -tags => 'title',
	   -position => [$x, $y]);

#
# Now clone for each variation on the polygon
#
$col = 0;
$row = 0;
foreach $current (@show) {
  ($cap, $filled, $border, $relief, $title) = @{$current};
  $grp = $zinc->clone($model);
  $zinc->translate($grp, $col * 240, $row * (-290 - (2 * $lw)));
  $zinc->itemconfigure($zinc->find('withtag', "$grp*bezier"),
		       -capstyle => $cap,
		       -filled => $filled,
		       -linewidth => $border ? $lw : 0,
		       -relief => $relief,
		       -linecolor => $relief eq 'flat' ? 'yellow' : 'tan');
  $zinc->itemconfigure($zinc->find('withtag', "$grp*title"),
		       -text => $title);
  $col++;
  if ($col >= 4) {
    $col = 0;
    $row++;
  }
}

#
# Suppress the model
#
$zinc->remove($model);

my @coords = (
10, 0, 40, 0, 70, 0,
70, 0, 80, 0, 80, 10,
80, 10, 80, 40, 80, 70,
80, 70, 80, 80, 70, 80,
70, 80, 40, 80, 10, 80,
10, 80, 0, 80, 0, 70,
0, 70, 0, 40, 0, 10,
0, 10, 0, 0, 10, 0);
$zinc->add('bezier', $view, \@coords);

#
# Some optional graphic features
$closed = 0;
#set smooth 0
$arrows = 'none';

sub toggle_arrows {
  if ($arrows eq 'none') {
    $arrows = 'first';
    $f = $arrow;
    $l = '';
  }
  elsif ($arrows eq 'first') {
    $arrows = 'last';
    $f = '';
    $l = $arrow;
  }
  elsif ($arrows eq 'last') {
    $arrows = 'both';
    $f = $arrow;
    $l = $arrow;
  }
  elsif ($arrows eq 'both') {
    $arrows = 'none';
    $f = '';
    $l = '';
  }
  $zinc->itemconfigure('bezier',
		       -firstend => $f,
		       -lastend => $l)
}


sub toggle_closed {
  $closed = !$closed;
  foreach $ curve ($zinc->find('withtag', 'bezier')) {
    if ($closed) {
      @coords = $zinc->coords($curve, 0, 0);
      $zinc->coords($curve, 'add', \@coords);
    }
    else {
      $zinc->coords($curve, 'remove', -1)
    }
  }
}

$zinc->Tk::focus();

$zinc->Tk::bind('<a>', \&toggle_arrows);
$zinc->Tk::bind('<c>', \&toggle_closed);

$zinc->Tk::bind('<Shift-1>',
		sub {my $ev = $zinc->XEvent();
		     my $it = $zinc->find('closest', $ev->x, $ev->y);
		     print "$it ", $zinc->verticeat($it, $ev->x, $ev->y), "\n"});
$zinc->Tk::bind('<Shift-ButtonRelease-1>', sub {Tk::break});

new Controls($zinc);
MainLoop();
