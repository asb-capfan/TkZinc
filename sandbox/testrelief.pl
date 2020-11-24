#!/usr/bin/perl -w

use Tk;
use Tk::Zinc;
use Controls;

$top = 1;
$lw = 8;

$mw = MainWindow->new();
$zinc = $mw->Zinc(-backcolor => 'gray',
		  -relief => 'sunken',
		  -lightangle => 120,
		  -render => 1);
$zinc->pack(-expand => 1,
	    -fill => 'both');
$zinc->configure(-width => 1024,
		 -height => 800);
$zinc->scale($top, 1, -1);

$view = $zinc->add('group', $top, -tags => 'controls');

sub polypoints {
    ($ox, $oy, $rad, $n, $startangle) = @_;

    $step =  2 * 3.14159 / $n;
    $startangle = $startangle*3.14159/180;
    $coords = [];
    for ($i = 0; $i < $n; $i++) {
      $x = $ox + ($rad * cos($i * $step + $startangle));
      $y = $oy + ($rad * sin($i * $step + $startangle));
      push(@{$coords}, $x, $y);
    }
    push(@{$coords}, $coords->[0], $coords->[1]);
    return $coords
}

$zinc->add('curve', $view, polypoints(200, -200, 100, 40, 0),
	   -relief => 'raised',
	   -linewidth => $lw,
	   -smoothrelief => 1,
	   -fillcolor => 'lightblue',
	   -linecolor => 'lightblue',
	   -filled => 1);

$zinc->add('curve', $view, polypoints(450, -200, 100, 40, 0),
	   -relief => 'raised',
	   -linewidth => $lw,
	   -smoothrelief => 1,
	   -fillcolor => 'tan',
	   -linecolor => 'tan',
	   -filled => 1);

$zinc->add('curve', $view, polypoints(700, -200, 100, 40, 0),
	   -relief => 'sunken',
	   -linewidth => $lw,
	   -smoothrelief => 1,
	   -fillcolor => 'tan',
	   -linecolor => 'tan',
	   -closed => 1,
	   -filled => 1);

$zinc->add('curve', $view, polypoints(200, -450, 100, 7, -45),
	   -relief => 'sunken',
	   -linewidth => $lw,
	   -fillcolor => 'tan',
	   -linecolor => 'tan',
	   -filled => 1);


new Controls($zinc);
MainLoop();

