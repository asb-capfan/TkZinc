Summary: Zinc, a canvas replacement for Tk
Name: perl-Tk-Zinc
Version: 3.296
Release: 1
Copyright: BSD
Vendor: Centre d'Etudes de la Navigation Aerienne
Packager: Alexandre Lemort <lemort@intuilab.com>
Distribution: Zinc
Group: System Environment/Libraries
Url: http://www.cena.fr/divisions/PII/
Source: perl-Tk-Zinc-3.296.tar.gz
Requires: perl-Tk
BuildArchitectures: i386
BuildRoot: /var/tmp/perl-Tk-Zinc-buildroot

%description
Zinc is a canvas like widget for the Tk toolkit. Its has been
 designed to provide a structured organization of its graphical
 components. It provides also advanced geometrical and graphical
 capabilities such as geometric construction (boolean ops),
 transformations, non rectangular clipping gradient fills, smart
 reliefs, etc.

This contains the dynamic libraries that are necessary for
running applications which use Zinc.

%prep
%setup -q -n perl-Tk-Zinc-%{version}

%build
./configure --enable-ptk=yes --enable-gl=damage --prefix=$RPM_BUILD_ROOT/usr --exec-prefix=$RPM_BUILD_ROOT/usr
cd Perl
./export2cpan
cd ../export2cpan/tk-zinc
perl Makefile.PL
make

%clean
rm -rf $RPM_BUILD_ROOT

%install
rm -rf $RPM_BUILD_ROOT
mkdirhier $RPM_BUILD_ROOT/usr/lib
cd export2cpan/tk-zinc
make PREFIX=$RPM_BUILD_ROOT/usr prefix=$RPM_BUILD_ROOT/usr INSTALLDIRS=perl install
find $RPM_BUILD_ROOT/usr -type f -print | sed "s@^$RPM_BUILD_ROOT@@g" | grep -v Zinc.bs | grep -v .packlist > ../../perl-Tk-Zinc-%{version}-filelist

%files -f perl-Tk-Zinc-%{version}-filelist
%defattr(-,root,root)

%changelog
 

 * Tue Oct 31 2000 Stéphane Chatty <chatty@cena.fr>
- Generation of version 3.1.19-1

 * Tue Oct 31 2000 Stéphane Chatty <chatty@cena.fr>
- Generation of version 3.1.19-2

 * Tue Oct 31 2000 Stéphane Chatty <chatty@cena.fr>
- Generation of version 3.1.19-3

 * Tue Oct 31 2000 Stéphane Chatty <chatty@cena.fr>
- Generation of version 3.1.19-4

 * Tue Oct 31 2000 Stéphane Chatty <chatty@cena.fr>
- Generation of version 3.1.19-5

 * Tue Oct 31 2000 Stéphane Chatty <chatty@cena.fr>
- Generation of version 3.1.19-6

 * Tue Oct 31 2000 Stéphane Chatty <chatty@cena.fr>
- Generation of version 3.1.19-7

 * Tue Oct 31 2000 Stéphane Chatty <chatty@cena.fr>
- Generation of version 3.1.19-8

 * Tue Oct 31 2000 Stéphane Chatty <chatty@cena.fr>
- Generation of version 3.1.19-9

 * Tue Oct 31 2000 Stéphane Chatty <chatty@cena.fr>
- Generation of version 3.1.19-10

 * Tue Oct 31 2000 Stéphane Chatty <chatty@cena.fr>
- Generation of version 3.1.19-11

 * Tue Oct 31 2000 Stéphane Chatty <chatty@cena.fr>
- Generation of version 3.1.19-12

 * Mon Mar 12 2001 Stéphane Chatty <chatty@cena.fr>
- Generation of version 3.1.23-1

 * Tue Mar 13 2001 Stéphane Chatty <chatty@cena.fr>
- Generation of version 3.1.23-2

 * Tue Mar 13 2001 Stéphane Chatty <chatty@cena.fr>
- Generation of version 3.1.23-3

 * Fri Mar 16 2001 Stéphane Chatty <chatty@cena.fr>
- Generation of version 3.1.24-1

 * Tue Apr 10 2001 Stéphane Chatty <chatty@cena.fr>
- Generation of version 3.1.26-1

 * Wed Jan 16 2002 Stéphane Chatty
- Generation of version 3.2.3-1

 * Thu Apr 4 2002 Stéphane Chatty <chatty@cena.fr>
- Generation of version 3.2.4-1

 * Wed Sep 18 2002 Stéphane Chatty <chatty@intuilab.com>
- Generation of version 3.2.6-1

 * Mon Feb 17 2003 Alexandre Lemort <lemort@intuilab.com>
- Generation of version 3.2.6h-1
- Mandrake 9 compilation
- Removes installgpc in redhat/rules

 * Wed May 14 2003 Alexandre Lemort <lemort@intuilab.com>
- Generation of version 3.2.92-1
- Mandrake 9 compilation

 * Sat May 17 2003 Alexandre Lemort <lemort@intuilab.com>
- Generation of version 3.2.93-1
- Mandrake 9 compilation

 * Fri Jun 20 2003 Alexandre Lemort <lemort@intuilab.com>
- Generation of version 3.2.94-1
- Mandrake 9 compilation

 * Fri Jun 20 2003 Alexandre Lemort <lemort@intuilab.com>
- Generation of version 3.2.94-2
- Mandrake 9.1 compilation

 * Wed Oct 15 2003 Alexandre Lemort <lemort@intuilab.com>
- Generation of version 3.295-1
- Mandrake 9 compilation

 * Tue Oct 28 2003 Alexandre Lemort <lemort@intuilab.com>
- Generation of version 3.295-2

 * Fri Nov 28 2003 Alexandre Lemort <lemort@intuilab.com>
- Generation of version 3.295-3

 * Mon Dec 15 2003 Alexandre Lemort <lemort@intuilab.com>
- Generation of version 3.296-1


