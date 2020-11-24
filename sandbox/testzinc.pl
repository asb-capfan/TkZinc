#!/usr/bin/perl -w


use Tk;
use Tk::Zinc;
use Tk::Photo;
use Tk::ZincText;
#use ZincText;
use Controls;

$map_path = "/usr/share/toccata/maps";

$mw = MainWindow->new();
$logo = $mw->Photo(-file => "logo.gif");


###################################################
# creation zinc
###################################################
$top = 1;
$scale = 1.0;
$center_x = 0.0;
$center_y = 0.0;
$zinc_width = 800;
$zinc_height = 500;
$delay = 2000;
$rate = 0.3;
%tracks = ();

$zinc = $mw->Zinc(-render => 2, -backcolor => 'gray65', -relief => 'sunken');
$zinc->pack(-expand => 1, -fill => 'both');
$zinc->configure(-width => $zinc_width, -height => $zinc_height);
#$radar = $top;
$radar = $zinc->add('group', $radar, -tags => ['controls', 'radar']);
$zinc->configure(-overlapmanager => $radar);

new ZincText($zinc);
###################################################
# Création fonctions de contrôle à la souris
###################################################
new Controls($zinc);

###################################################
# creation panneau controle
###################################################
$rc = $mw->Frame()->pack();
$rc->Button(-text => 'Up',
	    -command => sub { $center_y -= 30.0;
			      update_transform($zinc); })->grid(-row => 0,
								-column => 2,
								-sticky, 'ew');
$rc->Button(-text => 'Down',
	    -command => sub { $center_y += 30.0;
			      update_transform($zinc); })->grid(-row => 2,
								-column => 2,
								-sticky, 'ew');
$rc->Button(-text => 'Left',
	    -command => sub { $center_x += 30.0;
			      update_transform($zinc); })->grid(-row => 1,
								-column => 1);
$rc->Button(-text => 'Right',
	    -command => sub { $center_x -= 30.0;
			      update_transform($zinc); })->grid(-row => 1,
								-column => 3);
$rc->Button(-text => 'Expand',
	    -command => sub { $scale *= 1.1;
			      update_transform($zinc); })->grid(-row => 1,
								-column => 4);
$rc->Button(-text => 'Shrink',
	    -command => sub { $scale *= 0.9;
			      update_transform($zinc); })->grid(-row => 1,
								-column => 0);
$rc->Button(-text => 'Reset',
	    -command => sub { $scale = 1.0;
			      $center_x = $center_y = 0.0;
			      update_transform($zinc); })->grid(-row => 1,
								-column => 2,
								-sticky, 'ew');
$rc->Button(-text => 'Quit',
	    -command => \&exit)->grid(-row => 3,
				      -column => 2);


###################################################
# Code de reconfiguration lors d'un
# redimensionnement.
###################################################
$zinc->Tk::bind('<Configure>', [\&resize]);

sub resize {
    my ($zinc) = @_;
    my $ev = $zinc->XEvent();
    my $width = $ev->w;
    my $height = $ev->h;
    my $bw = $zinc->cget(-borderwidth);
    $zinc_width = $width - 2*$bw;
    $zinc_height = $height - 2*$bw;
    update_transform($zinc);
}

sub update_transform {
    my ($zinc) = @_;

    $zinc->treset($top);
    $zinc->translate($top, -$center_x, -$center_y);
    $zinc->scale($top, $scale, $scale);
    $zinc->scale($top, 1, -1);
    $zinc->translate($top, $zinc_width/2, $zinc_height/2);
}


###################################################
# Creation de pistes.
###################################################
sub create_tracks {
    my $i = 20;
    my $j;
    my $track;
    my $x;
    my $y;
    my $w = $zinc_width / $scale;
    my $h = $zinc_height / $scale;
    my $d;
    my $item;
    
    for ( ; $i > 0; $i--) {
	$track = {};
	$track->{'item'} = $item = $zinc->add('track', $radar, 6);
	$tracks{$item} = $track;
	$track->{'x'} = rand($w) - $w/2 + $center_x;
	$track->{'y'} = rand($h) - $h/2 + $center_y;
	$d = (rand() > 0.5) ? 1 : -1;
	$track->{'vx'} =  (8.0 + rand(10.0)) * $d;
#	$track->{'vx'} = 10;
	$d = (rand() > 0.5) ? 1 : -1;
	$track->{'vy'} =  (8.0 + rand(10.0)) * $d;
#	$track->{'vy'} =  -10;
	$zinc->itemconfigure($item,
			     -lastasfirst => 1,
			     -symbolcolor => 'red',
			     -position => [$track->{'x'}, $track->{'y'}],
			     -speedvector => [$track->{'vx'}, $track->{'vy'}],
			     -speedvectorsensitive => 1,
			     -speedvectorwidth => 2,
			     -speedvectormark => 1,
			     -speedvectorticks => 1,
			     -labeldistance => 30,
			     -markersize => 20,
			     -historycolor => 'gray30',
			     -filledhistory => 0,
			     -circlehistory => 1,
			     -labelformat => "x71x50+0+0 a0a0^0^0 a0a0^0>1 a0a0>2>1 a0a0>3>1 a0a0^0>2"
			    );
	$zinc->itemconfigure($item, 0,
			     -filled => 0,
			     -backcolor => 'gray60',
#			     -border => "contour",
			     -sensitive => 1
			     );
	$zinc->itemconfigure($item, 1,
			     -filled => 1,
			     -backcolor => 'gray55',
			     -text => "AFR001");
	$zinc->itemconfigure($item, 2,
			     -filled => 0,
			     -backcolor => 'gray65',
			     -text => "360");
	$zinc->itemconfigure($item, 3,
			     -filled => 0,
			     -backcolor => 'gray65',
			     -text => "/");
	$zinc->itemconfigure($item, 4,
			     -filled => 0,
			     -backcolor => 'gray65',
			     -text => "410");
	$zinc->itemconfigure($item, 5,
			     -filled => 0,
			     -backcolor => 'gray65',
			     -text => "Balise");
	my $b_on = sub { #print_current($zinc);
			 $zinc->itemconfigure('current', $zinc->currentpart(),
					      -border => 'contour')};
	my $b_off = sub { #print_current($zinc);
			  $zinc->itemconfigure('current', $zinc->currentpart(),
					       -border => 'noborder')};
	my $tog_b = sub { my $current = $zinc->find('withtag', 'current');
			  my $curpart = $zinc->currentpart();
			  if ($curpart =~ '[0-9]+') {
			      my $on_off = $zinc->itemcget($current, $curpart, -sensitive);
			      $zinc->itemconfigure($current, $curpart,
						   -sensitive => !$on_off);
			  }
		      };
	for ($j = 0; $j < 6; $j++) {
	    $zinc->bind($item.":$j", '<Enter>', $b_on);
            $zinc->bind($item.":$j", '<Leave>', $b_off);
            $zinc->bind($item, '<1>', $tog_b);
            $zinc->bind($item, '<Shift-1>', sub {});
        }
	$zinc->bind($item, '<Enter>',
		    sub { #print_current($zinc);
			 $zinc->itemconfigure('current',
					      -historycolor => 'red',
					      -symbolcolor => 'red',
					      -markercolor => 'red',
					      -leaderwidth => 2,
					      -leadercolor => 'red',
					      -speedvectorwidth => 2,
					      -speedvectorcolor => 'red')});
        $zinc->bind($item, '<Leave>',
                    sub { #print_current($zinc);
			 $zinc->itemconfigure('current',
					      -historycolor => 'black',
					      -symbolcolor => 'black',
					      -markercolor => 'black',
					      -leaderwidth => 1,
					      -leadercolor => 'black',
					      -speedvectorwidth => 1,
					      -speedvectorcolor => 'black')});
        $zinc->bind($item.':position', '<1>', [\&create_route]);
        $zinc->bind($item.':position', '<Shift-1>', sub { });
        $track->{'route'} = 0;
    }
}

create_tracks();

sub print_current {
    my ($zinc) = @_;
    my $current;

    $current = $zinc->find('withtag', 'current');
    print join(' ', $current), "\n";
#    print ref($zinc->itemcget($current, -position)) ? 'ref' : 'pas ref', "\n";
#    print 'tout ';
#    for $attr ($zinc->itemconfigure($current)) {
#	print (join(',', @$attr));
#    }
#    print "\n\n";
#    print '-position ', join(',', $zinc->itemconfigure($current, -position)), "\n\n";
}

###################################################
# creation way point
###################################################
sub create_route {
    my ($zinc) = @_;
    my $wp;
    my $connected;
    my $x;
    my $y;
    my $i = 4;
    my $track = $tracks{$zinc->find('withtag', 'current')};
    
    if ($track->{'route'} == 0) {
	$x = $track->{'x'} + 8.0 * $track->{'vx'};
	$y = $track->{'y'} + 8.0 * $track->{'vy'};
	$connected = $track->{'item'};
	for ( ; $i > 0; $i--) {
	    $wp = $zinc->add('waypoint', 'radar', 2,
			     -position => [$x, $y],
			     -connecteditem => $connected,
			     -connectioncolor => 'green',
			     -symbolcolor => 'green',
			     -labelformat => 'x20x18+0+0');
	    $zinc->lower($wp, $connected);
	    $zinc->bind($wp.':0', '<Enter>',
			sub {$zinc->itemconfigure('current', 0, -border => 'contour')});
	    $zinc->bind($wp.':position', '<Enter>',
			sub {$zinc->itemconfigure('current', -symbolcolor => 'red')});
	    $zinc->bind($wp.':leader', '<Enter>',
			sub {$zinc->itemconfigure('current', -leadercolor => 'red')});
	    $zinc->bind($wp.':connection', '<Enter>',
			sub {$zinc->itemconfigure('current', -connectioncolor => 'red')});
	    $zinc->bind($wp.':0', '<Leave>',
			sub {$zinc->itemconfigure('current', 0, -border => '')});
	    $zinc->bind($wp.':position', '<Leave>',
			sub {$zinc->itemconfigure('current', -symbolcolor => 'green')});
	    $zinc->bind($wp.':leader', '<Leave>',
			sub {$zinc->itemconfigure('current', -leadercolor => 'black')});
	    $zinc->bind($wp.':connection', '<Leave>',
			sub {$zinc->itemconfigure('current', -connectioncolor => 'green')});
	    $zinc->itemconfigure($wp, 0,
				 -text => "$i",
				 -filled => 1,
                                 -backcolor => 'gray55');
	    $zinc->bind($wp.':position', '<1>', [\&del_way_point]);
	    $x += (2.0 + rand(8.0)) * $track->{'vx'};
	    $y += (2.0 + rand(8.0)) * $track->{'vy'};
	    $connected = $wp;
	}
	$track->{'route'} = $wp;
    }
    else {
	$wp = $track->{'route'};
	while ($wp != $track->{'item'}) {
	    $track->{'route'} = $zinc->itemcget($wp, -connecteditem);
	    $zinc->bind($wp.':position', '<1>', '');
	    $zinc->bind($wp.':position', '<Enter>', '');
	    $zinc->bind($wp.':position', '<Leave>', '');
	    $zinc->bind($wp.':leader', '<Enter>', '');
            $zinc->bind($wp.':leader', '<Leave>', '');
            $zinc->bind($wp.':connection', '<Enter>', '');
            $zinc->bind($wp.':connection', '<Leave>', '');
            $zinc->bind($wp.':0', '<Enter>', '');
            $zinc->bind($wp.':0', '<Leave>', '');
            $zinc->remove($wp);
	    $wp = $track->{'route'};
	}
	$track->{'route'} = 0;
    }
}

###################################################
# suppression waypoint intermediaire
###################################################
sub find_track {
    my ($zinc, $wp) = @_;
    my $connected = $wp;
    
    while ($zinc->type($connected) ne 'track') {
	$connected = $zinc->itemcget($connected, -connecteditem);
    }
    return $connected;
}

sub del_way_point {
    my ($zinc) = @_;
    my $wp = $zinc->find('withtag', 'current');
    my $track = $tracks{find_track($zinc, $wp)};
    my $next = $zinc->itemcget($wp, -connecteditem);
    my $prev;
    my $prevnext;

    $prev = $track->{'route'};
    if ($prev != $wp) {
	$prevnext = $zinc->itemcget($prev, -connecteditem);
	while ($prevnext != $wp) {
	    $prev = $prevnext;
	    $prevnext = $zinc->itemcget($prev, -connecteditem);
	}
    }
    $zinc->itemconfigure($prev, -connecteditem => $next);
    $zinc->bind($wp.':position', '<1>', '');
    $zinc->remove($wp);
    if ($wp == $track->{'route'}) {
	if ($next == $track->{'item'}) {
	    $track->{'route'} = 0;
	}
	else {
	    $track->{'route'} = $next;
	}
    }
}

sub stick_wp {
    my ($zinc) = @_;
    my $ev = $zinc->XEvent();

    if ($just_wiped) {
	$just_wiped = 0;
	return;
    }
    my ($x, $y) = $zinc->transform('radar', [$ev->x, $ev->y]);
    my $wp = $zinc->add('waypoint', 'radar', 2,
			-position => [$x, $y],
			-connectioncolor => 'red',
			-symbolcolor => 'red',
			-labelformat => 'a2a2+0+0',
			-tags => ['text']);
    $zinc->itemconfigure($wp, 0,
			 -text => "$x".'@'."$y",
			 -color => 'red',
			 -filled => 1,
			 -backcolor => 'gray55');
    $zinc->bind($wp.':position', '<1>', [\&wipe_wp]);
}

sub wipe_wp {
    my ($zinc) = @_;
    $zinc->remove('current');
    $just_wiped = 1;
}

$zinc->Tk::bind('<2>', [\&stick_wp]);


###################################################
# creation macro
###################################################
#$macro = $zinc->add("tabular", $radar, 10,
#    -labelformat => "x40x20+0+0 x40x20+40+0"
#    );
#$zinc->itemconfigure($macro, 0 , -text => "une");
#$zinc->itemconfigure($macro, 1, -text => "macro");
#$zinc->itemconfigure($macro, -connecteditem => $track);
#$zinc->bind($macro.":0", "<Enter>", [ \&borders, "on"]);
#$zinc->bind($macro.":0", "<Leave>", [ \&borders, "off"]);

###################################################
# creation ministrip
###################################################
$ministrip = $zinc->add("tabular", $radar, 10,
    -labelformat => "x80x20+0+0",
    -position => [100, 10]);
$zinc->itemconfigure($ministrip, 0 , -text => 'ministrip');
$zinc->bind($ministrip.':0', '<Enter>',
	    sub {$zinc->itemconfigure('current', 0, -border => 'contour')});
$zinc->bind($ministrip.':0', '<Leave>',
    sub {$zinc->itemconfigure('current', 0, -border => '')});

###################################################
# creation map
###################################################
$mw->videomap("load", "$map_path/videomap_paris-w_90_2", 0, "paris-w");
$mw->videomap("load", "$map_path/videomap_orly", 17, "orly");
$mw->videomap("load", "$map_path/hegias_parouest_TE.vid", 0, "paris-ouest");

$map = $zinc->add("map", $radar,
		  -color => 'gray80');
$zinc->itemconfigure($map,
		     -mapinfo => 'orly');

$map2 = $zinc->add("map", $radar,
		   -color => 'gray60',
		   -filled => 1,
		   -priority => 0,
		   -fillpattern => AlphaStipple6);
$zinc->itemconfigure($map2,
		     -mapinfo => 'paris-ouest');

$map3 = $zinc->add("map", $radar,
		   -color => 'gray50');
$zinc->itemconfigure($map3,
		     -mapinfo => "paris-w");


###################################################
# Map info
###################################################
#$mw->mapinfo('mpessai', 'create');
#$mw->mapinfo('mpessai', 'add', 'text', 'normal', 'simple', 0, 200, "Et voilà");
#$mw->mapinfo('mpessai', 'add', 'line', 'simple', 0,  0, 0, 0, 200);
#$mw->mapinfo('mpessai', 'add', 'line', 'simple', 5, -100, 100, 0, 0);
#$zinc->itemconfigure($map3, -mapinfo => 'mpessai');

#$c1= $zinc->add('curve', $radar, [],
#		-filled => 1,
#		-linewidth => 1,
#		-fillcolor => 'blue');
#$zinc->coords($c1, [200, 200, 300, 200, 300, 300, 200, 300]);
#$zinc->bind($c1, '<1>', sub {$zinc->coords($c1, 'remove', 0);});
#$zinc->bind($c1, '<2>', sub {$zinc->coords($c1, 'add', 0, [0, 0]);});
#$zinc->bind($c1, '<3>', sub {$zinc->coords($c1, []);});
#my $c = $zinc->add('curve', $radar, [],
#		   -filled => 1,
#		   -fillcolor => 'red');
#$zinc->contour($c, 'union', [100, 0, 0, 0, 0, 100, 100, 100]);
#$zinc->contour($c, 'diff', [75, 75, 25, 75, 25, 25, 75, 25]);
#print join(' ', $zinc->coords($c, 0)), "\n";
#print join(' ', $zinc->coords($c, 1)), "\n";


###################################################
# Rafraichissement des pistes
###################################################
$zinc->repeat($delay, [\&refresh, $zinc]);

sub refresh {
    my ($zinc) = @_;
    my $t;

    foreach $t (values(%tracks)) {
	$t->{'x'} += $t->{'vx'} * $rate;
	$t->{'y'} += $t->{'vy'} * $rate;
	$zinc->itemconfigure($t->{'item'},
			     -position => [$t->{'x'}, $t->{'y'}]);
    }
}

sub borders {
    my($widget, $onoff) = @_;
    $onoff = "on" unless $onoff;
    my $part = $zinc->currentpart;
    my $contour = "noborder";
    $contour = "contour" if ($onoff eq 'on');
    $zinc->itemconfigure('current', $part, -border => $contour) if ($part >= 0);
}

sub finditems {
    my($cornerx, $cornery) = @_;

    print "--- enclosed --->",
    join('|', $zinc->find('enclosed',$origx, $origy, $cornerx, $cornery)),"\n";
    print "--- overlapping --->",
    join('|',$zinc->find('overlapping',$origx, $origy, $cornerx, $cornery)),"\n\n";
}


MainLoop();


1;
