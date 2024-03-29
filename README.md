# The TkZinc widget

## WHAT IS THIS?

TkZinc is a canvas like widget extension to Tcl/Tk. 
It adds support for ATC displays, provides structured assembly of items, transformations, clipping, and openGL based rendering features such as gradients and alpha blending.

It is currently available on Unices (tested on Linux), Windows and MacOSX (with X11 and fink).


## WHERE DOES IT COME FROM?

The newest version is found at: https://github.com/asb-capfan/TkZinc/releases

Distribution specific packages may also be available for
Debian/Mandrake/Red Hat distributions, most likely for stable
versions.

For Perl/Tk users, TkZinc is available on the CPAN, see for example
on https://metacpan.org/pod/Tk::Zinc

As a convenience the documentation (pdf+html) is available.


# BUILDING AND INSTALLATION FOR TCL/TK


## 0. Download the distribution

You need a working Tcl/Tk distribution (version >= 8.4). 
You can either grab it using your regular package manager, or build it and install it from scratch.

**On a Linux system, you need the following packages:**

    tcl tcl-dev tk tk-dev

For GL support, you will need the following packages in addition:

    mesa-common-dev libglu1-mesa-dev freeglut3-dev libglew-dev

**On MacOSX you need:**

- fink with `tcltk` and `tcltk-dev` package (http://fink.sf.net)
- tcl/tk sources, though you are _not_ required to compile and install them.
  tcl/tk sources are needed  because some required files are missing in the packages (`tclInt.h` and `tkInt.h`, if you know how to get those files with fink, submit a suggestion to the maintainers).
  I couldn't install them using fink, d/l them instead: http://prdownloads.sourceforge.net/fink/direct_download/source
- X11 et X11 SDK from Apple (http://www.apple.com/macosx/x11/)

**On Windows:**

From sources or on Windows, get, build and _install_ the Tcl/Tk distribution.
On Windows there is currently an incompatibility when using a TkZinc compiled under mingw32 with a core Tcl/Tk compiled with Visual C++. 
You need to grab a Tcl/Tk compiled with the same environment as TkZinc.


## 1. Unpack the distribution

**On Unix/Linux/MacOSX:**

    tar zxf Tkzinc<version>.tgz

**On Windows:**

Use WinZip or something similar to unpack

This creates a directory `Tkzinc<version>` with all the needed files. 
This directory should be in the same directory as the Tcl/Tk sources.


## 2. Configure

**On Unix/Linux:**

    cd Tkzinc<version>
    ./configure  <option>*

This will configure the package for your platform. 
It will install it in `/usr/local`. If you want it elsewhere you can use the `--prefix` and `--exec-prefix` options of `configure` to assign another location.

**On MacOSX:**

Say we have unpacked tcl/tk sources in `$HOME/src`. The `configure` line is as follows: 

    env "CPPFLAGS=-I/sw/include -I$HOME/src/tcl8.4.1/generic -I$HOME/src/tk8.4.1/generic" ./configure --with-tcl=/sw/lib --with-tk=/sw/lib --enable-gl

**On Windows:**

TkZinc has been built using the msys/mingw32 environment.
It is known to work with Tcl/Tk 8.4.2 compiled using the same environment. **CAUTION:** It doesn't work with Tcl/Tk 8.4.1 using mingw32.

The steps for building under mingw32 are the same as on Unices.
Currently there is no support for building with visual C++.

**On all platforms:**

It is possible to customize TkZinc through configure options:

    --enable-gl=[yes|no|damage]
    --disable-gl

This is turned off by default. Building with `--enable-gl` is the recommanded way for openGL support.

    --enable-om=[yes|no]
    --disable-om

This is turned on by default. It controls the inclusion of code for avoid overlap between track labels in radar images.

    --enable-shape=[yes|no]
    --disable-shape

This is turned on by default except on Windows where support code is not currently available (it may become available).
It allows for non rectangular TkZinc windows optionally including the top level window.

And the Tcl standards:

    --enable-threads=[yes|no]
    --disable-threads

Compile a thread aware/thread safe version (not tested in multi threaded environment). 
Needed if Tcl/Tk has been compiled with the same configure option.

    --enable-symbols=[yes|no|mem|all]
    --disable-symbols

Turn on debugging symbols. 
If the form `--enable-symbols=mem` is used, turn on memory debugging as well.


## 3. Make and Install

For use with Tcl on Unix/Linux and Windows using mingw32:

    make
    make install-tcl

It is recommended to do a make distclean before actual building if you have done a previous build.

The warnings while compiling libtess are harmless (or so I believe ;-). 
`libtess` is a tesselation library extracted from GLU/Mesa. 
I trust it as robust unless proven wrong. I do not want to modify the code just to shut up some warnings.


For use with Tcl on Windows using Visual C++:

    nmake /F win/makefile.vc

There is no install target. You are left with the dlls and the start of `pkgIndex.tcl` (it lacks the entries for the Tcl modules in library).
It is needed to compile with Visual C++ if TkZinc is to be used with a Tcl/Tk compiled with Visual C++.

P.S: If a `pkgIndex.tcl` for Tkzinc exists in the autoload path before installing, it will interfere with the generation of the new `pkgIndex.tcl`.
It should be removed or renamed. `echo 'puts $auto_path' | tclsh will` tell the current load path.

**WATCH OUT!** 
On Linux it is quite frequent to have both Mesa and proprietary openGL libraries installed. 
This may lead to big problems at runtime if the linker picks the wrong library. 
It is often the case between the static (`libGL.a`) Mesa library and the dynamic (`libGL.so`) NVidia library. 
It is very important to assert that the link is done with the library matching the openGL driver loaded in the X server.

## 4. Run the demos

In the `Tkzinc<version>` directory run:

    wish8.4 demos/zinc-widget

Under Windows do:

    wish84 demos/zinc-widget

It should start a Tk like '`widget`' demo showing TkZinc features. 
You can also run the demo with: `demos/zinc-widget` if you have in the `PATH` a wish that is greater or equal to 8.4.2.


# BUILDING AND INSTALLATION FOR PERL/TK

TkZinc for Perl/Tk is available for Linux, Windows (Perl/Tk 804) and MacOSX. 
Also remember that the easiest way could be to use the CPAN.


## 0. Perl Distribution

You need a working Perl (>= 5.6) and Perl/Tk distribution (800 or 804). 
You can either grab it using your regular package manager, or build it and install it from scratch. 
To build it from scratch you need:

**Linux:**

On a Linux system, you need `perl`, `perl-tk` and `perl-tk-devel` packages 

**On MacOSX you need:**

- `fink` with `tk-pm` package and its dependencies (http://fink.sf.net)

  `tk-pm` is available in `unstable`. You can add this binary `unstable` tree to you `/sw/etc/apt/sources.list`:


    deb http://fink.opendarwin.org/bbraun 10.3/unstable main crypto
    deb http://fink.opendarwin.org/bbraun 10.3/stable main crypto

- `X11` et `X11 SDK` from Apple (http://www.apple.com/macosx/x11/)

**On Windows you need:**

- Perl and `Perl::Tk` 804, 
- Visual C++ or the Free Visual C++ Command Line Tools

## 1. Unpack the distribution

    tar zxf Tkzinc<version>.tgz
    cd Tkzinc<version>/Perl
    ./export2cpan
    cd ../export2cpan/tk-zinc<version>

## 2. Make and install

This done is the usual way:

    perl Makefile.PL
    make
    make test
    
    # to run the demo without/before installing:
    perl -Mblib demos/zinc-demos
    
    make install

**WATCH OUT!** 
On Linux it is quite frequent to have both Mesa and proprietary openGL libraries installed. 
This may lead to big problems at runtime if the linker picks the wrong library. 
It is often the case between the static (`libGL.a`) Mesa library and the dynamic (`libGL.so`) NVidia library. 
It is very important to assert that the link is done with the library matching the openGL driver loaded in the X server.

## 3. Run the demo

You can choose in the 35 available demos with the following Perl script:

    zinc-demos


# MAKE AND READ THE DOCUMENTATION


It is available in pdf and html forms.
To make the pdf doc you need pdflatex installed. Then do:

    cd Tkzinc<version>
    ./configure
    make pdf

This should create a refman.pdf in the doc directory.

    cd Tkzinc<version>
    ./configure
    make html

This should create the html documentation in the doc directory with all the html pages and images. The entry point is `index.html`.
You need `tex4ht` for doing this. 
It may be packaged separately from `tetex` on Linux, it is so on Debian distributions.



# REPORT BUGS AND WISHES


Please report bugs and suggestions to: https://github.com/asb-capfan/TkZinc/issues

When reporting bugs try to be as specific as possible. 
Include, if possible, the output from the program. 
Compile TkZinc with debugging symbols and include a backtrace of the debugger. 
Send a small Tcl (or Perl) script reproducing the problem.
The availability of a correction may dependent on these infos.
