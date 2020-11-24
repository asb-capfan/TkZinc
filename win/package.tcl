#
# This script is intended to be run in the win sub-directory
# with: tclsh build.tcl
# actions include: subst, tcl, perl, doc, wrap, clean. If nothing
# is specified all actions are performed in order.

set todo [lindex $argv 0]

set root [file join [file dirname [info script]] ..]

#
# First get the configure variable values.
#
set fid [open [file join $root configure.in]]
while { ! [eof $fid] } {
  set line [gets $fid]
  if { [regexp {^MAJOR_VERSION=(.*)$} $line dummy major] } {
    continue
  }
  if { [regexp {^MINOR_VERSION=(.*)$} $line dummy minor] } {
    continue
  }
  if { [regexp {^PATCHLEVEL=(.*)$} $line dummy patchlevel] } {
    continue
  }
}
close $fid

if { $todo eq "subst" || $todo eq "" } {
  #
  # Substitute @variables@ in the .in registred files
  # producing their expanded equivalent into files
  # without the .in extension.
  #
  puts "Performing configuration variables substitution..."

  set registredFiles {
    { . starkit.tcl }
    { win makefile.vc }
    { win Tkzinc.wxs }
  }

  set libFile "Tkzinc${major}${minor}.dll"
  set stubLibFile "Tkzincstub${major}${minor}.dll"

  #
  # Then substitute all occurences in known files
  #
  foreach t $registredFiles {
    set fid [open [file join $root [lindex $t 0] [lindex $t 1].in]]
    set fod [open [file join $root [lindex $t 0] [lindex $t 1]] w]

    while { ! [eof $fid] } {
      set line [gets $fid]
      regsub -all {@MAJOR_VERSION@} $line $major line
      regsub -all {@MINOR_VERSION@} $line $minor line
      regsub -all {@PATCHLEVEL@} $line $patchlevel line
      puts $fod $line
    }

    close $fid
    close $fod
  }
}

if { $todo eq "tcl" || $todo eq "" } {
  #
  # Make the Tcl library
  #
  set tmpdir buildtcl

  puts "Compiling the tcl variant..."

  if { [catch {exec nmake -f makefile.vc 2>log} result] } {
    puts $result
    exit
  }

  #
  # Copy the library files, it makes it easier to test in situ.
  #
  foreach f [glob -directory [file join $root library] zinc*.tcl] {
    file copy -force $f $tmpdir
  }
  #
  # Build a merged pkgIndex.tcl
  #
  set fout [open [file join $tmpdir pkgIndex.tcl] a]
  set fin [open [file join $root library pkgIndex.tcl]]
  foreach line [split [read $fin] \n] {
    if {![regexp {^\s*$|^#} $line]} {
	    puts $fout $line
    }
  }
  close $fin
  close $fout

  #
  # Create a demo script ending in .tcl
  #
  file copy -force [file join $root demos zinc-widget] [file join $tmpdir zinc-widget.tcl]
}

if { $todo eq "perl" || $todo eq "" } {
  #
  # Make the Tkzinc Perl library for windows
  #
  puts "Compiling the perl variant..."

  #
  # Create a perl build directory and copy the relevant
  # files in it.
  #
  set wd [pwd]
  set buildDir buildperl
  set make nmake

  puts "Creating temporary build structure for Tkzinc perl variant"

  if { [file exists $buildDir] } {
      file delete -force $buildDir
  }
  file mkdir $buildDir

  foreach f {t Zinc.xs demos README Zinc} {
    file copy -force [file join $root Perl $f] $buildDir
  }
  #
  # Add the version in Zinc.pm and Makefile.PL
  foreach f {Zinc.pm Makefile.PL} {
    set fid [open [file join $root Perl $f]]
    set fod [open [file join $buildDir $f] w]

    while { ! [eof $fid] } {
      set line [gets $fid]
      regsub -all SEEexport2cpan $line [format "%d.%d%02d" $major $minor $patchlevel] line
      puts $fod $line
    }

    close $fid
    close $fod
  }
  foreach f [glob -nocomplain [file join $root generic *.c] [file join $root generic *.h] \
                              [file join $root win *.c] [file join $root debian changelog] \
                              [file join $root debian copyright]] {
    file copy -force $f $buildDir
  }

  #
  # Build a .bat script for the Perl demos.
  #
  set fout [open [file join $buildDir demos zinc-demos.bat] w]
  set fin [open [file join $buildDir demos zinc-demos]]
  puts $fout {@rem = '--*-Perl-*--
@echo off
if "%OS%" == "Windows_NT" goto WinNT
perl -x -S "%0" %1 %2 %3 %4 %5 %6 %7 %8 %9
goto endofperl
:WinNT
perl -x -S %0 %*
if NOT "%COMSPEC%" == "%SystemRoot%\system32\cmd.exe" goto endofperl
if %errorlevel% == 9009 echo You do not have Perl in your PATH.
if errorlevel 1 goto script_failed_so_exit_with_non_zero_val 2>nul
goto endofperl
@rem ';}
  puts $fout [read $fin]
  puts $fout {__END__
:endofperl}
  close $fin
  close $fout

  #
  # Call the perl setup and then make it.
  #
  puts "Compiling the perl variant"

  cd $buildDir
  if { [catch {exec perl Makefile.PL 2>log} result] } {
    puts $result
    exit
  }
  if { [catch {exec $make 2>log} result] } {
    puts $result
    exit
  }
  cd $wd
}


proc dochtml { root } {
  #
  # Making of the html version
  #
  set cwd [pwd]
  cd [file join $root doc]

  DocClean
  puts "First pass through htlatex."
  if { [catch {exec htlatex refman.tex refman 2>log} result] } {
    puts $result
    exit
  }
  puts "Preparing the index."
  if { [catch {exec tex {\def\filename{{refman}{idx}{4dx}{ind}}} {\input} idxmake.4ht 2>log} result] } {
    puts $result
    exit
  }
  puts "Running makeindex."
  if { [catch {exec makeindex -o refman.ind refman.4dx 2>log} result] } {
    puts $result
    exit
  }
  puts "Second pass through htlatex."
  if { [catch {exec htlatex refman.tex refman 2>log} result] } {
    puts $result
    exit
  }

  cd $cwd
}

proc docpdf { root } {
  #
  # Making of the pdf version
  #
  set cwd [pwd]
  cd [file join $root doc]

  DocClean
  puts "First pass through pdflatex."
  if { [catch {exec pdflatex refman.tex 2>log} result] } {
    puts $result
    exit
  }
  puts "Running makeindex."
  if { [catch {exec makeindex -o refman.ind refman.idx 2>log} result] } {
    puts $result
    exit
  }
  puts "Second pass through pdflatex."
  if { [catch {exec pdflatex refman.tex 2>log} result] } {
    puts $result
    exit
  }
  puts "Third pass through pdflatex."
  if { [catch {exec pdflatex refman.tex 2>log} result] } {
    puts $result
    exit
  }

  cd $cwd
}

proc DocClean { } {
  #
  # Need to get rid of some temporary files.
  #
  file delete -force log refman.aux refman.idx refman.ind refman.lof
  file delete -force refman.log refman.out refman.toc texput.log
  file delete -force idxmake.dvi idxmake.log refman.4ct refman.4dx refman.4ix
  file delete -force refman.4tc refman.dvi refman.idx refman.ilg refman.ind
  file delete -force refman.log refman.tmp refman.xref refman.lg refman.idv
}

if { $todo eq "doc" || $todo eq "" } {
  #
  # Make the pdf manual. Run the command
  # three time to make the crossrefs ok.
  #
  puts "Building the documentation..."
  docpdf $root
  dochtml $root
  DocClean
}

if { $todo eq "docpdf" } {
  docpdf $root
}

if { $todo eq "dochtml" } {
  dochtml $root
}

if { $todo eq "wrap" || $todo eq "" } {
  #
  # Wrap up the msi package.
  #
  puts "Wrapping the msi package..."

  if { [catch {exec candle Tkzinc.wxs 2>log} result] } {
    puts $result
    exit
  }
  if { [catch {exec light Tkzinc.wixobj 2>log} result] } {
    puts $result
    exit
  }
}

if { $todo eq "clean" || $todo eq "" } {
  #
  # Clean up after messing around
  #
  puts "Cleaning up..."

  file delete -force log pkgIndex.tcl zinc-widget.tcl zinc-demos.bat Tkzinc.wixobj
  file delete -force buildtcl
  file delete -force buildperl
  set cwd [pwd]
  cd [file join $root doc]
  file delete -force refman.pdf refman.css nayk0a01.png
  file delete -force [glob refman*.html]
  cd $cwd
}

