# TkZinc for Python 3

This package supports Python 3.8 and later. Python 2 is not supported.
It provides the `Zinc` package and requires Tkinter and Pillow.

## Install

On Ubuntu/WSL, install the Python dependencies with:

```sh
sudo apt install python3-tk python3-pil python3-pil.imagetk
```

Install this package from the repository root, preferably in a virtual
environment:

```sh
python3 -m pip install ./Python
```

On Windows, use `py -3 -m pip install ./Python` with a Python installation
that includes Tkinter. Check it with `py -3 -m tkinter`.

## Native Windows build for Tkinter

For Windows Python with Tcl/Tk 8.6, a dedicated build script creates the
native DLL using MinGW GCC and Tcl/Tk's stub libraries. A 64-bit build has
been tested with Python 3.13 and Tcl/Tk 8.6.15. The compiler architecture
must match Python; GCC can come from any compatible MinGW installation.
Put it on `PATH` or supply `--cc C:/path/to/gcc.exe`.

Run from the repository root in PowerShell:

```powershell
py -3 win/build_tkzinc.py --fetch-sources
py -3 -m pip install ./Python
$nativePath = (Resolve-Path build/windows-tcl).Path.Replace('\', '/')
$env:TCLLIBPATH = "{$nativePath}"
py -3 Python/demos/testGraphics.py
```

The commands use your checkout location. The build script also prints the
exact `TCLLIBPATH` command. The setting applies to the current PowerShell
session. Keep the braces when the path contains spaces.

The first build downloads SHA-256-checked official Tcl/Tk 8.6.15 source
archives for their headers. Later builds reuse the local cache. GLEW is
built from the bundled sources, so no separate GLEW DLL is needed. The
script does not replace Python's Tcl/Tk DLLs or install into system folders.

Output is `build/windows-tcl/Tkzinc<version>/Tkzinc.dll` together with
`pkgIndex.tcl`, license files and build information. Compiler output is
saved in `build/windows-tcl/build.log`.

For another Tcl/Tk 8.6 patch release, supply matching official source trees:

```powershell
py -3 win/build_tkzinc.py --tcl-source C:/src/tcl8.6.x --tk-source C:/src/tk8.6.x
```

The script checks the headers against the running interpreter. By default
it uses `tclstub86.lib` and `tkstub86.lib` from this Python's `tcl` directory;
use `--stub-dir` for another matching SDK library directory. This script
does not support Tcl/Tk 9 or MSVC.

The Python package does not build the C widget. First build and install the
Tcl/Tk TkZinc extension following the top-level README. It must match the
Tcl/Tk version, architecture and windowing system used by your Python's
Tkinter. The Perl extension is a separate build and cannot be used here.

Tkinter loads the widget with `package require Tkzinc`. To use a local
installation, set `TCLLIBPATH` to the parent directory containing the
`Tkzinc3.3.7` package directory before starting Python. Tcl treats this
variable as a list; surround a path containing spaces with braces.

## Use

```python
import tkinter as tk
import Zinc

root = tk.Tk()
canvas = Zinc.Zinc(root, width=400, height=300, render=0)
canvas.pack(fill="both", expand=True)
canvas.add("rectangle", 1, (20, 20, 180, 120), filled=True, fillcolor="red")
root.mainloop()
```

Run the graphics demo after installation:

```sh
python3 Python/demos/testGraphics.py
```

The demo uses OpenGL and requires a display supporting it. The bundled
`paper.gif` is resolved relative to the demo script, not the working directory.

## Tests

```sh
python3 -m unittest discover -s Python/tests -v
```

Helper tests do not require a display. Widget integration tests require the
native Tcl/Tk TkZinc extension and an X display on Linux. For headless tests:

```sh
xvfb-run -a python3 -m unittest discover -s Python/tests -v
```

Integration tests are skipped when TkZinc or a display is unavailable.
After the Windows build, all tests can run in the same PowerShell session:

```powershell
$env:TKZINC_TEST_REQUIRE_NATIVE = '1'
$env:TKZINC_TEST_LIBRARY_DIR = "$PWD/build/windows-tcl/Tkzinc3.3.7"
py -3 -m unittest discover -s Python/tests -v
```

Adjust the package version in the last path if needed. The extra environment
variables require a real native library and enable the test for paths with
spaces, rather than silently skipping unavailable integration tests.
