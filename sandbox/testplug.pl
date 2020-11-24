#!/usr/bin/perl

use Tk;

$mw = MainWindow->new();

$zinc = $mw->Zinc(-backcolor => 'gray',
		  -relief => 'sunken',
		  -width => 800,
		  -height => 500)->pack(-expand => 1,
					-fill => 'both');
$top = 1;
#$ent = $zinc->Entry();
#$entryitem = $zinc->add('window', $top,
#			-window => $ent,
#			-position => [100, 100]);
$dcontainer = $zinc->Frame(-container => 1);
$did = $dcontainer->id();
$vcontainer = $zinc->Frame(-container => 1);
$vid = $vcontainer->id();
#print "container id is $id\n";

$dlabel = $zinc->add('text', $top,
		     -text => "Digistrips",
		     -position => [150, 30]);
$zinc->bind($dlabel, '<1>', sub { $zinc->itemconfigure($vlabel, -color => 'black');
				  $zinc->itemconfigure($dlabel, -color => 'red');
				  $zinc->itemconfigure($vcontitem, -visible => 0);
				  $zinc->itemconfigure($dcontitem, -visible => 1); });
$vlabel = $zinc->add('text', $top,
		     -text => "Virtuosi",
		     -position => [250, 30]);
$zinc->bind($vlabel, '<1>', sub { $zinc->itemconfigure($dlabel, -color => 'black');
				  $zinc->itemconfigure($vlabel, -color => 'red');
				  $zinc->itemconfigure($dcontitem, -visible => 0);
				  $zinc->itemconfigure($vcontitem, -visible => 1); });
$dcontitem = $zinc->add('window', $top,
			-window => $dcontainer,
			-position => [50, 75],
			-visible => 0);
$vcontitem = $zinc->add('window', $top,
			-window => $vcontainer,
			-position => [50, 75],
			-visible => 0);

$mw->update();

system("digistripsIII -stan --use $did -style standalone-1024x768 &");
system("virtuosi -g 1024x768 -use $vid &");

MainLoop();
