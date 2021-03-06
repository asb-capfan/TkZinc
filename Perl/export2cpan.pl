#!/usr/bin/perl

#
# If we want to extract a release right out of the repository
# just pass the release tag as first parameter and the script
# will leave a tarball in the current directory after chewing
# a moment in /tmp.
# the first argument should be a CVS tag looking like cpan_3_2_95
# or cpan_3_295. The second underscore will be removed for computing the
# 

# In the other case (no parameters) the script supposes we are
# in the Perl subdir of a Tkzinc working directory and it will
# setup zinc-perl for compilation in export2cpan/tk-zinc-<version>.
# The source files are taken from the working directory. This is
# the anticipated behavior when developping/testing or making
# a debian package from the rules file.
# this script has been provided by mertz @ intuilab dot com
# $Id$

use strict;
use Cwd qw(cwd);

my $ZINC_PREFIX = 'tk-zinc';
my $DEFAULT_SERVER = 'cvs.tkzinc.org';
my $DEFAULT_CVS_MODULE = '/srv/tkzinc/cvsroot';
my $TMP = '/tmp/forCPAN';

# computing major, minor and patchlevel from var defined in ../configure.in
sub version4cpan {
    my $configure_in = "../configure.in";
    
    open(FD, "<$configure_in") or die "Could not open file $configure_in";
    
    my ($major, $minor, $patchlevel);
    while (<FD>) {
        if (/^MAJOR_VERSION=(\d+)/)
        {
            $major = $1;
        }
        elsif (/^MINOR_VERSION=(\d+)/)
        {
            $minor = $1;
        }
        elsif (/^PATCHLEVEL=(\d+)/)
        {
            $patchlevel = $1;
        }
    }

    close (FD);
    
    print "PATCHLEVEL: $patchlevel\n";
    return sprintf ("%d.%d%02d", $major,$minor,$patchlevel);
}

sub filesubst {
    my ($fileIn, $fileOut, $key, $val) = @_;

    open(FDIN, "<$fileIn") or die "Could not open input file $fileIn";
    open(FDOUT, ">$fileOut") or die "Could not open output file $fileOut";

    while (<FDIN>) {
        if (/$key/) {
            s/$key/$val/g;
        }
        print FDOUT $_;
    }

    close(FDIN);
    close(FDOUT);
}

my $VERSION;
my $FROM_CVS = (scalar(@ARGV) != 0);
my $DIR_FROM_CVS;
my $CWD = cwd();
chomp($CWD);

#
# See if parameters are given (there should be a cvs tag
# and may be the repository machine).
#
if ($FROM_CVS) {
    my $cvstag = $ARGV[0];
    my $server = $DEFAULT_SERVER;
    if (scalar(@ARGV) == 2) {
        $server = $ARGV[1];
    }
    print "Building a CPAN release tarball from tag $cvstag.\n";
    $cvstag =~ /^.*?([\d_]+)$/;
    my $tag_version = $1;
    if ($tag_version =~ /(\d+)_(\d+)_(\d+)/) {
        $tag_version = "$1_$2$3";
    }
    $VERSION = version4cpan;   # version computed from the source directory
    $DIR_FROM_CVS = "$ZINC_PREFIX-$VERSION";
    system("rm -rf $TMP");
    system ("mkdir $TMP");
    chdir("$TMP");
    # the following command always fail with cvs 1.11.1p1 !!
    my $command = "cd $TMP; cvs -d $server:$DEFAULT_CVS_MODULE export -r $cvstag -d $DIR_FROM_CVS Tkzinc";
    # my $command = "cd $TMP; cvs -d /pii/repository export -r $cvstag -d $DIR_FROM_CVS Tkzinc";
    print "$command\n";
    my $error = system($command);
    die "CVS extraction did not succeed" if $error;
    chdir("$DIR_FROM_CVS/Perl");
    my $EXTRACTED_VERSION = version4cpan; # version gotten from the tagged CVS files
    if ($EXTRACTED_VERSION ne $VERSION) {
        print "Oops! the tag version '$tag_version' does not match the version '$VERSION' in the sources, aborting\n";
        exit(1);
    }
    system ("cd $TMP/$DIR_FROM_CVS; ./configure");

} else {
    $VERSION = version4cpan;
    print "cd ..; ./configure\n";
    system ("cd ..; ./configure"); # for creating  Makefile.pl from xxx.in files
}

print "VERSION $VERSION\n";

my $CP = 'cp -r';

my $EXPORT_DIR = '../export2cpan';
my $VERSION_DIR = "$ZINC_PREFIX-$VERSION";

if (-d "$EXPORT_DIR/$VERSION_DIR") {
    system("rm -rf $EXPORT_DIR/$VERSION_DIR");
}

if (! -d $EXPORT_DIR) {
    mkdir($EXPORT_DIR);
}
if (! -d "$EXPORT_DIR/$VERSION_DIR") {
    mkdir("$EXPORT_DIR/$VERSION_DIR");
}
symlink ("$EXPORT_DIR/$VERSION_DIR", "$EXPORT_DIR/$ZINC_PREFIX");

my @files=('t', 'Zinc.xs', 'demos', 'README', 'Zinc');


foreach my $f (@files) {
    system("$CP $f $EXPORT_DIR/$VERSION_DIR");
}

# modifying the $VERSION of Zinc.pm with the correctly perl formated version scheme.
&filesubst ('Zinc.pm', "$EXPORT_DIR/$VERSION_DIR/Zinc.pm", '^\$VERSION *=.*;', "\$VERSION = $VERSION;");
&filesubst ('Makefile.PL', "$EXPORT_DIR/$VERSION_DIR/Makefile.PL", '^my \$VERSION *=.*;', "my \$VERSION = $VERSION;");

system("$CP ../Copyright $EXPORT_DIR/$VERSION_DIR");
system("$CP ../generic/*.c $EXPORT_DIR/$VERSION_DIR");
system("$CP ../generic/*.h $EXPORT_DIR/$VERSION_DIR");
system("$CP ../win/*.c $EXPORT_DIR/$VERSION_DIR");


#
# If working for an exported copy, build a tarball in the
# current dir.
#
if ($FROM_CVS) {
    chdir("$EXPORT_DIR/$VERSION_DIR");
    
    #
    # Remove the .cvsignore files
    system('find . -name .cvsignore | xargs rm -f');

    #
    # Create the MANIFEST file
    use ExtUtils::Manifest qw( mkmanifest );
    $ExtUtils::Manifest::Quiet = 1;
    &mkmanifest();

    chdir('..');

    system("tar zcf $TMP/$ZINC_PREFIX-$VERSION.tar.gz $VERSION_DIR");
    chdir($CWD);
    print "The tarball is in $TMP/$ZINC_PREFIX-$VERSION.tar.gz\n";
    print "You may want to clean up after testing in $TMP/$DIR_FROM_CVS\n";
}
