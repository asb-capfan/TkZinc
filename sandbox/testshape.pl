#!/usr/bin/perl -w

use Tk;
use Tk::Zinc;
use Controls;

$mw = MainWindow->new();

$top = 1;
$zinc = $mw->Zinc(-render => 1,
		  -borderwidth => 0,
#		  -fullreshape => 0,
		  -relief => 'sunken');
$zinc->pack(-expand => 1, -fill => 'both');
$zinc->configure(-width => 500, -height => 500);

$zinc->gname('white:40 0 60|black 50|white 100(0 0', 'oeil');
$zinc->gname('white:0 0 10|black:100 100/0', 'oeil2');
$zinc->gname('white:100|black:100(-35 -25', 'boule');
$zinc->gname('white:100|black:100(-15 -100', 'arrondi');
$zinc->gname('white:100|black:100/45', 'cyl');
$zinc->gname('white|black[50 0', 'path');

# $arc = $zinc->add('arc', $top, [50, 50, 200, 100],
# 		  -visible => 0);
#$zinc->itemconfigure($top, -clip => $arc);

$view = $zinc->add('group', $top, -tags => "controls");
# $cv = $zinc->add('curve', $view, [50, 50, 100, 150, 270, 70,
# 				 220, 0, 200, 20, 180, 100,
# 				 140, 40, 70, 100],
# 		 -visible => 1,
# 		 -closed => 1,
# 		 -filled => 1);

$g1 = $zinc->add('group', $view);
$zinc->translate($g1, 100, 300);
$rect = $zinc->add('rectangle', $g1, [-40,-50, 40,50],
		   -filled => 1,
		   -fillcolor => 'path'
		  );
$g2 = $zinc->add('group', $view);
$zinc->translate($g2, 200, 300);
$arc = $zinc->add('arc', $g2, [0,0, 100,100],
		   -filled => 1,
		  -linecolor => 'white',
		   -fillcolor => 'boule',
		  -startangle => 120,
		  -extent => 120,
		  -closed => 1,
		  -pieslice => 1,
#		  -fillcolor => 'tan'
		 );
$arc2 = $zinc->add('arc', $view, [90,0, 160,50],
		   -visible => 0,
		   -linewidth => 0,
		   -filled => 1,
		   -fillcolor => 'brown');
$g3 = $zinc->add('group', $view);
$zinc->translate($g3, 300, 300);
$cv3 = $zinc->add('curve', $g3,
#		  [[-50, -40], [0, 0], [-50, 40], [50, 40], [50, -40]],
		  [-50, -40, 0, 0, -50, 40, 50, 40, 50, -40],
		  -visible => 0,
		  -filled => 1,
		  -fillcolor => "#ffffff:100 0 28|#66848c:100 80|#7192aa:100 100/270"
#		  -fillcolor => 'cyl'
);

# $rect = $zinc->add('rectangle', $view, [200,230, 220,250],
# 		   -visible => 1,
# 		   -linewidth => 2,
# 		   -relief => 'sunken',
# 		   -filled => 1,
# 		   -linecolor => 'white',
# 		   -fillcolor => 'tan');
$cv2 = $zinc->add('curve', $view, [],
		  -visible => 1,
		  -linewidth => 2,
		  -linecolor => 'white',
		  -fillcolor => 'tan',
		  -fillrule => 'positive',
		  -relief => 'sunken',
		  -closed => 1,
		  -filled => 1);
$text = $zinc->add('text', $view,
		   -visible => 1,
		   -text => 'Un Texte ICI°°°°°',
		   -position => [200, 100],
		   -color => '#008000');
$zinc->contour($cv2, 'add', 1, [[20, 20], [20, 100, 'c'], [120, 100], [120, 20]]);
$zinc->contour($cv2, 'add', -1, [40, 40, 80, 40, 80, 80, 40, 80]);
$zinc->contour($cv2, 'add', 1, [60, 50, 60, 60, 70, 60, 70, 50]);
$zinc->contour($cv2, 'add', -1, [90, 70, 150, 70, 150, 150, 90, 150]);
$zinc->contour($cv2, 'add', 1, [200, 200, 200, 220, 220, 220, 220, 200]);
$zinc->contour($cv2, 'add', -1, [100, 10, 180, 10, 180, 60, 100, 60]);

$zinc->contour($cv2, 'add', 1, $arc2);
$zinc->contour($cv2, 'add', 1, $text);

# $rect2 = $zinc->add('rectangle', $view, [40,81, 80,130],
# 		    -visible => 1,
# 		    -linewidth => 1,
# 		    -relief => 'sunken',
# 		    -filled => 1,
# 		    -linecolor => 'white',
# 		    -fillcolor => 'tan');

new Controls($zinc);

$zinc->Tk::bind('<a>', sub {print "hop\n", $zinc->contour($cv2, 'remove', 1);});
$zinc->Tk::bind('<b>', sub {my ($x,$y,$c) = $zinc->coords($cv2, 0, 1);
			    if ($c eq 'c') {
			      $zinc->coords($cv2, 0, 1, [[20, 100]]);
			    }
			    else {
			      $zinc->coords($cv2, 0, 1, [[20, 100, 'c']]);
			    }});
$zinc->Tk::bind('<1>', sub {
		  my $ev = $zinc->XEvent();
		  my $it = $zinc->find('closest', $ev->x, $ev->y);
		  print "Closest: $it\n";
#		  my @t = $zinc->vertexat($it, $ev->x, $ev->y);
#		  print "VertexAt: ", join(', ', @t), "\n";
		  $zinc->bind($cv2, '<1>', sub { print "zou\n";});
		  $zinc->coords($cv2, 0, [[100,0]]);
		  print $zinc->bind($cv2, '<1>'), "\n";
		});

$zinc->focusFollowsMouse();

MainLoop();
