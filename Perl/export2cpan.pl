#!/usr/bin/perl

# Export the current working tree as a standalone Perl/Tk source distribution.
# Run from any directory: perl path/to/TkZinc/Perl/export2cpan.pl
# For a historical release, check out the desired Git revision first.

use strict;
use warnings;
use Cwd qw(abs_path getcwd);
use ExtUtils::Manifest qw(maniadd manifind);
use File::Basename qw(dirname);
use File::Copy qw(copy);
use File::Find qw(find);
use File::Path qw(make_path);
use File::Spec;
use FindBin qw($RealBin);

die "Usage: perl export2cpan.pl (no arguments; export a Git checkout)\n" if @ARGV;

my $source = abs_path(File::Spec->catdir($RealBin, '..'));
my $version = version4cpan(File::Spec->catfile($source, 'configure.in'));
my $export = File::Spec->catdir($source, 'export2cpan', "tk-zinc-$version");

# Never silently delete a previous export or follow a destination symlink.
die "Export already exists: $export\nMove or remove it before exporting again.\n"
    if -e $export || -l $export;
make_path($export);

for my $entry ('t', 'Zinc.xs', 'ZincGlew.c', 'demos', 'README', 'Zinc') {
    copy_tree(File::Spec->catfile($RealBin, $entry),
              File::Spec->catfile($export, $entry));
}

copy_tree(File::Spec->catdir($source, 'third_party', 'glew'),
          File::Spec->catdir($export, 'third_party', 'glew'));

for my $entry ('Zinc.pm', 'Makefile.PL') {
    substitute_version(File::Spec->catfile($RealBin, $entry),
                       File::Spec->catfile($export, $entry), $version);
}

copy_file(File::Spec->catfile($source, 'Copyright'),
          File::Spec->catfile($export, 'Copyright'));

# Use directory entries instead of shell wildcards (also works with spaces).
for my $directory ('generic', 'win') {
    my $path = File::Spec->catdir($source, $directory);
    opendir(my $dh, $path) or die "Cannot read $path: $!\n";
    my @files = sort grep { /\.c\z/ || ($directory eq 'generic' && /\.h\z/) } readdir($dh);
    closedir($dh) or die "Cannot close $path: $!\n";
    die "No source files found in $path\n" unless @files;
    for my $file (@files) {
        copy_file(File::Spec->catfile($path, $file),
                  File::Spec->catfile($export, $file));
    }
}

# Record only exported sources, before MakeMaker creates build artifacts.
# maniadd handles MANIFEST quoting and portable path separators.
my $original_directory = getcwd();
chdir($export) or die "Cannot change to $export: $!\n";
my $manifest = manifind();
$manifest->{'MANIFEST'} = '';
open(my $manifest_file, '>', 'MANIFEST') or die "Cannot create MANIFEST: $!\n";
print {$manifest_file} "MANIFEST\n" or die "Cannot write MANIFEST: $!\n";
close($manifest_file) or die "Cannot close MANIFEST: $!\n";
maniadd($manifest);
die "MANIFEST was not created in $export\n" unless -f 'MANIFEST';
chdir($original_directory) or die "Cannot return to $original_directory: $!\n";

print "Exported Tk::Zinc $version to $export\n";
print "Change to that directory and run: perl Makefile.PL\n";

sub version4cpan {
    my ($path) = @_;
    open(my $fh, '<', $path) or die "Cannot read $path: $!\n";
    my %parts;
    while (<$fh>) {
        $parts{$1} = $2 if /^(MAJOR_VERSION|MINOR_VERSION|PATCHLEVEL)=(\d+)\s*$/;
    }
    close($fh) or die "Cannot close $path: $!\n";
    for my $key ('MAJOR_VERSION', 'MINOR_VERSION', 'PATCHLEVEL') {
        die "Missing $key in $path\n" unless exists $parts{$key};
    }
    return sprintf('%d.%d%02d', @parts{qw(MAJOR_VERSION MINOR_VERSION PATCHLEVEL)});
}

sub copy_file {
    my ($from, $to) = @_;
    die "Symbolic links are not supported in the export: $from\n" if -l $from;
    copy($from, $to) or die "Cannot copy $from to $to: $!\n";
    my $mode = (stat($from))[2] & 0777;
    chmod($mode, $to) or die "Cannot set permissions on $to: $!\n";
}

sub copy_tree {
    my ($from, $to) = @_;
    die "Symbolic links are not supported in the export: $from\n" if -l $from;
    if (-f $from) {
        copy_file($from, $to);
        return;
    }
    die "Missing source directory: $from\n" unless -d $from;
    find({ no_chdir => 1, wanted => sub {
        my $path = $File::Find::name;
        die "Symbolic links are not supported in the export: $path\n" if -l $path;
        my $relative = File::Spec->abs2rel($path, $from);
        my $destination = File::Spec->catfile($to, $relative);
        if (-d $path) {
            make_path($destination);
        } elsif (-f $path) {
            make_path(dirname($destination));
            copy_file($path, $destination);
        } else {
            die "Unsupported source entry: $path\n";
        }
    } }, $from);
}

sub substitute_version {
    my ($from, $to, $value) = @_;
    open(my $in, '<', $from) or die "Cannot read $from: $!\n";
    open(my $out, '>', $to) or die "Cannot write $to: $!\n";
    my $replacements = 0;
    while (<$in>) {
        $replacements += s/\bSEEexport2cpan\b/$value/g;
        print {$out} $_ or die "Cannot write $to: $!\n";
    }
    close($in) or die "Cannot close $from: $!\n";
    close($out) or die "Cannot close $to: $!\n";
    die "Expected one version placeholder in $from, found $replacements\n"
        unless $replacements == 1;
}
