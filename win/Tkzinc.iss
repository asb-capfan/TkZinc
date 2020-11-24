#define TkzincVersion "3.3.4"
#define TkzincWinVersion "334"

[Setup]
AppName=Tkzinc
AppVersion={#TkzincVersion}
AppVerName=Tkzinc {#TkzincVersion}
LicenseFile="Copyright.rtf"
;;
;; No default directory really exist. Use ActiveTcl default location
;; as a fallback. In all cases the documentation will be installed
;; in this location.
DefaultDirName={pf}\Tkzinc
DisableProgramGroupPage=yes
OutputBaseFilename=Tkzinc{#TkzincWinVersion}

[Messages]
WelcomeLabel2=This will install [name/ver] on your computer.
SelectDirDesc=Where should [name] documentation be installed?
SelectDirLabel3=Setup will install [name] documentation into the following folder.

[Components]
Name: "Tcl"; Description: "Tkzinc Tcl support"; Types: full compact custom; Check: ActiveTcl
Name: "Tcl\Main"; Description: "Tcl component"; Types: full compact custom; Check: ActiveTcl
Name: "Tcl\Demo"; Description: "Tcl demos"; Types: full custom; Check: ActiveTcl
Name: "Perl"; Description: "Perl support files"; Types: full compact custom; Check: ActivePerl
Name: "Perl\Main"; Description: "Perl component"; Types: full compact custom; Check: ActivePerl
Name: "Perl\Demo"; Description: "Perl demos"; Types: full custom; Check: ActivePerl
Name: "Python"; Description: "Python support files"; Types: full compact custom; Check: ActivePython
Name: "Python\Main"; Description: "Python component"; Types: full compact custom; Check: ActivePython
Name: "Python\Demo"; Description: "Python demos"; Types: full custom; Check: ActivePython
Name: "Doc"; Description: "Tkzinc documentation"; Types: full custom

[Files]
;;
;; Tcl component files
Source: "buildtcl\Tkzinc{#TkzincWinVersion}.dll"; DestDir: "{code:TclDir}\lib\Tkzinc{#TkzincVersion}"; Components: Tcl\Main
Source: "buildtcl\pkgIndex.tcl"; DestDir: "{code:TclDir}\lib\Tkzinc{#TkzincVersion}"; Components: Tcl\Main
Source: "buildtcl\zincGraphics.tcl"; DestDir: "{code:TclDir}\lib\Tkzinc{#TkzincVersion}"; Components: Tcl\Main
Source: "buildtcl\zincText.tcl"; DestDir: "{code:TclDir}\lib\Tkzinc{#TkzincVersion}"; Components: Tcl\Main
Source: "buildtcl\zincLogo.tcl"; DestDir: "{code:TclDir}\lib\Tkzinc{#TkzincVersion}"; Components: Tcl\Main
Source: "..\README"; DestDir: "{code:TclDir}\lib\Tkzinc{#TkzincVersion}"; Components: Tcl\Main
Source: "..\BUGS"; DestDir: "{code:TclDir}\lib\Tkzinc{#TkzincVersion}"; Components: Tcl\Main
;;
;; Tcl demo files
Source: "..\demos\*.tcl"; DestDir: "{code:TclDir}\demos\Tkzinc"; Components: Tcl\Demo
Source: "buildtcl\zinc-widget.tcl"; DestDir: "{code:TclDir}\demos\Tkzinc"; Components: Tcl\Demo
Source: "..\demos\images\*.gif"; DestDir: "{code:TclDir}\demos\Tkzinc\images"; Components: Tcl\Demo
Source: "..\demos\images\*.png"; DestDir: "{code:TclDir}\demos\Tkzinc\images"; Components: Tcl\Demo
Source: "..\demos\data\hegias_parouest_TE.vid"; DestDir: "{code:TclDir}\demos\Tkzinc\data"; Components: Tcl\Demo
Source: "..\demos\data\videomap_orly"; DestDir: "{code:TclDir}\demos\Tkzinc\data"; Components: Tcl\Demo
Source: "..\demos\data\videomap_paris-w_90_2"; DestDir: "{code:TclDir}\demos\Tkzinc\data"; Components: Tcl\Demo
;;
;; Documentation files
Source: "..\doc\refman.pdf"; DestDir: "{app}"; Components: Doc
Source: "..\doc\index.html"; DestDir: "{app}"; Components: Doc
Source: "..\doc\refman.html"; DestDir: "{app}"; Components: Doc
Source: "..\doc\refmanch*.html"; DestDir: "{app}"; Components: Doc
Source: "..\doc\refmanli*.html"; DestDir: "{app}"; Components: Doc
Source: "..\doc\*.png"; DestDir: "{app}"; Components: Doc
;;
;; Perl component files
Source: "buildperl\blib\arch\auto\Tk\Zinc\Zinc.dll"; DestDir: "{code:PerlDir}\site\lib\auto\Tk\Zinc"; Components: Perl\Main
Source: "buildperl\blib\arch\auto\Tk\Zinc\Zinc.exp"; DestDir: "{code:PerlDir}\site\lib\auto\Tk\Zinc"; Components: Perl\Main
Source: "buildperl\blib\arch\auto\Tk\Zinc\Zinc.lib"; DestDir: "{code:PerlDir}\site\lib\auto\Tk\Zinc"; Components: Perl\Main
Source: "buildperl\blib\arch\auto\Tk\Zinc\Zinc.bs"; DestDir: "{code:PerlDir}\site\lib\auto\Tk\Zinc"; Components: Perl\Main
Source: "buildperl\blib\lib\Tk\Zinc.pm"; DestDir: "{code:PerlDir}\site\lib\Tk"; Components: Perl\Main
Source: "buildperl\blib\lib\Tk\Zinc\Debug.pm"; DestDir: "{code:PerlDir}\site\lib\Tk\Zinc"; Components: Perl\Main
Source: "buildperl\blib\lib\Tk\Zinc\Graphics.pm"; DestDir: "{code:PerlDir}\site\lib\Tk\Zinc"; Components: Perl\Main
Source: "buildperl\blib\lib\Tk\Zinc\Graphics.pod"; DestDir: "{code:PerlDir}\site\lib\Tk\Zinc"; Components: Perl\Main
Source: "buildperl\blib\lib\Tk\Zinc\Logo.pm"; DestDir: "{code:PerlDir}\site\lib\Tk\Zinc"; Components: Perl\Main
Source: "buildperl\blib\lib\Tk\Zinc\Text.pm"; DestDir: "{code:PerlDir}\site\lib\Tk\Zinc"; Components: Perl\Main
Source: "buildperl\blib\lib\Tk\Zinc\Trace.pm"; DestDir: "{code:PerlDir}\site\lib\Tk\Zinc"; Components: Perl\Main
Source: "buildperl\blib\lib\Tk\Zinc\TraceErrors.pm"; DestDir: "{code:PerlDir}\site\lib\Tk\Zinc"; Components: Perl\Main
Source: "buildperl\blib\lib\Tk\Zinc\TraceUtils.pm"; DestDir: "{code:PerlDir}\site\lib\Tk\Zinc"; Components: Perl\Main
;;
;; Perl demo files
Source: "buildperl\blib\script\zinc-demos.bat"; DestDir: "{code:PerlDir}\bin"; Components: Perl\Demo
Source: "buildperl\blib\lib\Tk\demos\zinc_contrib_lib\*"; DestDir: "{code:PerlDir}\site\lib\Tk\demos\zinc_contrib_lib"; Components: Perl\Demo
Source: "buildperl\blib\lib\Tk\demos\zinc_data\*"; DestDir: "{code:PerlDir}\site\lib\Tk\demos\zinc_data"; Components: Perl\Demo
Source: "buildperl\blib\lib\Tk\demos\zinc_lib\*"; DestDir: "{code:PerlDir}\site\lib\Tk\demos\zinc_lib"; Components: Perl\Demo
Source: "buildperl\blib\lib\Tk\demos\zinc_pm\*"; DestDir: "{code:PerlDir}\site\lib\Tk\demos\zinc_pm"; Components: Perl\Demo
;;
;; Python component files
Source: "buildtcl\Tkzinc{#TkzincWinVersion}.dll"; DestDir: "{code:PythonDir}\tcl\Tkzinc{#TkzincVersion}"; Components: Python\Main
Source: "buildtcl\pkgIndex.tcl"; DestDir: "{code:PythonDir}\tcl\Tkzinc{#TkzincVersion}"; Components: Python\Main
Source: "buildtcl\zincGraphics.tcl"; DestDir: "{code:PythonDir}\tcl\Tkzinc{#TkzincVersion}"; Components: Python\Main
Source: "buildtcl\zincText.tcl"; DestDir: "{code:PythonDir}\tcl\Tkzinc{#TkzincVersion}"; Components: Python\Main
Source: "buildtcl\zincLogo.tcl"; DestDir: "{code:PythonDir}\tcl\Tkzinc{#TkzincVersion}"; Components: Python\Main
Source: "..\Python\library\Zinc.py"; DestDir: "{code:PythonDir}\Lib\Zinc"; Components: Python\Main
Source: "..\Python\library\__init__.py"; DestDir: "{code:PythonDir}\Lib\Zinc"; Components: Python\Main
Source: "..\Python\library\graphics.py"; DestDir: "{code:PythonDir}\Lib\Zinc"; Components: Python\Main
Source: "..\Python\library\geometry.py"; DestDir: "{code:PythonDir}\Lib\Zinc"; Components: Python\Main
Source: "..\Python\library\pictorial.py"; DestDir: "{code:PythonDir}\Lib\Zinc"; Components: Python\Main
;;
;; Python demo files
Source: "..\Python\demos\testGraphics.py"; DestDir: "{code:PythonDir}\ZincDemo"; Components: Python\Demo
Source: "..\Python\demos\paper.gif"; DestDir: "{code:PythonDir}\ZincDemo"; Components: Python\Demo


[Code]
var
  TclVersion: String;
  TclPath: String;
  PerlVersion: String;
  PerlPath: String;
  PythonVersion: String;
  PythonPath: String;

  InfoPage: TOutputMsgWizardPage;

function InitializeSetup() : Boolean;
begin
  if RegQueryStringValue(HKEY_LOCAL_MACHINE, 'SOFTWARE\ActiveState\ActiveTcl', 'CurrentVersion', TclVersion) then begin
    RegQueryStringValue(HKEY_LOCAL_MACHINE, 'SOFTWARE\ActiveState\ActiveTcl\' + TclVersion, '', TclPath)
  end else begin
    TclVersion := '';
  end;
  if RegQueryStringValue(HKEY_LOCAL_MACHINE, 'SOFTWARE\ActiveState\ActivePerl', 'CurrentVersion', PerlVersion) then begin
    RegQueryStringValue(HKEY_LOCAL_MACHINE, 'SOFTWARE\ActiveState\ActivePerl\' + PerlVersion, '', PerlPath)
  end else begin
    PerlVersion := '';
  end;
  if RegQueryStringValue(HKEY_LOCAL_MACHINE, 'SOFTWARE\ActiveState\ActivePython', 'CurrentVersion', PythonVersion) then begin
    RegQueryStringValue(HKEY_LOCAL_MACHINE, 'SOFTWARE\ActiveState\ActivePython\' + PythonVersion, '', PythonPath)
  end else begin
    PythonVersion := '';
  end;
  Result := True;
end;

procedure InitializeWizard;
var
  Info: String;
begin
  Info := '';
  if (TclVersion <> '') or (PerlVersion <> '') or (PythonVersion <> '') then begin
    Info := Info + 'The following languages have been detected: '#13#13;
    if TclVersion <> '' then begin
      Info := Info + '  - ActiveTcl version ' + TclVersion + '  in:  ' + TclPath + ''#13;
    end;
    if PerlVersion <> '' then begin
      Info := Info + '  - ActivePerl version ' + PerlVersion + '  in:  ' + PerlPath + ''#13;
    end;
    if PythonVersion <> '' then begin
      Info := Info + '  - ActivePython version ' + PythonVersion + '  in:  ' + PythonPath + ''#13;
    end;
    Info := Info + #13'The relevant Tkzinc files will be installed in the detected locations.'#13;
  end;
  if (TclVersion = '') or (PerlVersion = '') or (PythonVersion = '') then begin
    Info := Info + #13'Setup failed to detect:'#13#13;
    if TclVersion = '' then begin
      Info := Info + '  - ActiveTcl'#13;
    end;
    if PerlVersion = '' then begin
      Info := Info + '  - ActivePerl'#13;
    end;
    if PythonVersion = '' then begin
      Info := Info + '  - ActivePython'#13;
    end;
    Info := Info + #13'Tkzinc will not be available for those environments.'#13#13;
    Info := Info + 'Please, install the ActiveState packages before the Tkzinc package.'
  end;

  InfoPage := CreateOutputMsgPage(wpLicense, 'Installed Languages',
                                  'Auto detected ActiveState packages', Info);
end;

function ActiveTcl() : Boolean;
begin
  Result := TclVersion <> '';
end;

function ActivePerl() : Boolean;
begin
  Result := PerlVersion <> '';
end;

function ActivePython() : Boolean;
begin
  Result := PythonVersion <> '';
end;

function TclDir(param: String) : String;
begin
  Result := TclPath;
end;

function PerlDir(param: String) : String;
begin
  Result := PerlPath;
end;

function PythonDir(param: String) : String;
begin
  Result := PythonPath;
end;

