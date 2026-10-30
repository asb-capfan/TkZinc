#!/usr/bin/env python3
"""Build a native Windows TkZinc DLL for this Python's Tkinter (MinGW GCC)."""

import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import struct
import subprocess
import sys
import tarfile
import tkinter as tk
import urllib.request


ROOT = Path(__file__).resolve().parents[1]
# Official GitHub release-tag archives; verify before extracting any headers.
SOURCE_HASHES = {
    ('tcl', '8.6.15'): '26ec488cef5b9cd71a3290c257e40c2157fc258cad248f71404db56db8a016d1',
    ('tk', '8.6.15'): '60b345a44d8070a8b64a0bb9c24263f1a82288e945d5bd7f91df43070abc442a',
}


def source_tree(project, version, supplied, cache, fetch):
    if supplied:
        source = Path(supplied).resolve()
    else:
        tag = 'core-' + version.replace('.', '-')
        source = cache / (project + '-' + tag)
        digest = SOURCE_HASHES.get((project, version))
        if digest is None:
            raise RuntimeError('No pinned archive for %s %s; pass --%s-source '
                               'with matching official sources' % (project, version, project))
        archive = cache / ('%s-%s.tar.gz' % (project, version))
        if not archive.exists():
            if not fetch:
                raise RuntimeError('Missing %s sources. Use --fetch-sources or --%s-source.'
                                   % (project, project))
            url = 'https://github.com/tcltk/%s/archive/refs/tags/%s.tar.gz' % (project, tag)
            print('Downloading', url, flush=True)
            with urllib.request.urlopen(url, timeout=60) as response:
                with archive.open('wb') as output:
                    shutil.copyfileobj(response, output)
        if hashlib.sha256(archive.read_bytes()).hexdigest() != digest:
            raise RuntimeError('SHA-256 mismatch: %s' % archive)
        if not source.exists():
            with tarfile.open(archive, 'r:gz') as bundle:
                # Only ordinary files/directories under the expected root.
                for member in bundle.getmembers():
                    target = (cache / member.name).resolve()
                    if source not in (target, *target.parents):
                        raise RuntimeError('Unexpected archive path: %s' % member.name)
                    if not (member.isfile() or member.isdir()):
                        raise RuntimeError('Unsupported archive entry: %s' % member.name)
                if hasattr(tarfile, 'data_filter'):
                    bundle.extractall(cache, filter='data')
                else:
                    bundle.extractall(cache)
    header = source / 'generic' / (project + '.h')
    contents = header.read_text(encoding='utf-8')
    patch = re.search(r'^#\s*define\s+%s_PATCH_LEVEL\s+"([^"]+)"' % project.upper(),
                      contents, re.MULTILINE)
    if not patch or patch.group(1) != version:
        raise RuntimeError('%s does not match loaded %s %s' % (header, project, version))
    return source


def stub_library(directory, project, abi):
    for name in (project + 'stub' + abi + '.lib', 'lib' + project + 'stub' + abi + '.a'):
        candidate = directory / name
        if candidate.is_file():
            return candidate
    raise RuntimeError('Missing %s stub library in %s; pass --stub-dir' % (project, directory))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--cc', default=os.environ.get('CC', 'gcc'), help='MinGW GCC executable')
    parser.add_argument('--build-dir', type=Path, default=ROOT / 'build/windows-tcl')
    parser.add_argument('--stub-dir', type=Path, default=Path(sys.base_prefix) / 'tcl')
    parser.add_argument('--tcl-source', type=Path)
    parser.add_argument('--tk-source', type=Path)
    parser.add_argument('--fetch-sources', action='store_true', help='download pinned Tcl/Tk headers')
    args = parser.parse_args()
    if sys.platform != 'win32':
        parser.error('Run this script with native Windows Python, not WSL')
    compiler = shutil.which(args.cc)
    if not compiler:
        parser.error('GCC not found; put MinGW GCC on PATH or pass --cc C:/path/to/gcc.exe')
    target = subprocess.check_output([compiler, '-dumpmachine'], text=True).strip()
    bits = struct.calcsize('P') * 8
    compiler_bits = 64 if target.startswith('x86_64-') else 32 if re.match(r'i[3-6]86-', target) else 0
    if 'mingw' not in target or compiler_bits != bits:
        parser.error('Compiler target %s does not match this %s-bit Windows Python' % (target, bits))

    window = tk.Tk()
    window.withdraw()
    try:
        tcl_version = window.tk.call('info', 'patchlevel')
        tk_version = window.tk.call('package', 'require', 'Tk')
        threaded = window.tk.getboolean(window.tk.call('set', 'tcl_platform(threaded)'))
    finally:
        window.destroy()
    if not (tcl_version.startswith('8.6.') and tk_version.startswith('8.6.')):
        parser.error('This build supports Tcl/Tk 8.6; detected %s / %s' % (tcl_version, tk_version))

    build = args.build_dir.resolve()
    cache = build / 'deps'
    cache.mkdir(parents=True, exist_ok=True)
    tcl = source_tree('tcl', tcl_version, args.tcl_source, cache, args.fetch_sources)
    tksrc = source_tree('tk', tk_version, args.tk_source, cache, args.fetch_sources)
    libraries = [stub_library(args.stub_dir.resolve(), project, '86') for project in ('tcl', 'tk')]
    configure = (ROOT / 'configure.in').read_text(encoding='utf-8')
    version = '.'.join(re.search(r'^%s=(\d+)' % part, configure, re.MULTILINE).group(1)
                       for part in ('MAJOR_VERSION', 'MINOR_VERSION', 'PATCHLEVEL'))
    package = build / ('Tkzinc' + version)
    objects_dir = build / 'obj'
    package.mkdir(exist_ok=True)
    objects_dir.mkdir(exist_ok=True)
    includes = [ROOT / 'generic', ROOT / 'third_party/glew/include',
                tksrc / 'generic', tksrc / 'win', tksrc / 'xlib', tcl / 'generic', tcl / 'win']
    flags = ['-std=gnu99', '-O2', '-DUSE_TCL_STUBS', '-DUSE_TK_STUBS',
             '-DBUILD_Tkzinc', '-DATC', '-DGL', '-DPACKAGE_VERSION="%s"' % version]
    if threaded:
        flags.append('-DTCL_THREADS=1')
    flags += ['-I' + str(path) for path in includes]
    sources = sorted((ROOT / 'generic').glob('*.c')) + [ROOT / 'win/WinPort.c',
               ROOT / 'third_party/glew/src/glew.c']
    exports = build / 'Tkzinc.def'
    exports.write_text('EXPORTS\nTkzinc_Init\nTkzinc_SafeInit\n', encoding='ascii')
    log_path = build / 'build.log'
    print('Python %s; Tcl %s; Tk %s; %s' % (sys.version.split()[0], tcl_version, tk_version, target))
    objects = []
    with log_path.open('w', encoding='utf-8') as log:
        for source in sources:
            output = objects_dir / (source.stem + '.o')
            command = [compiler, '-c', *flags]
            if source.name == 'glew.c':
                command.append('-DGLEW_STATIC')
            command += [str(source), '-o', str(output)]
            subprocess.run(command, check=True, stdout=log, stderr=subprocess.STDOUT)
            objects.append(str(output))
            print('Compiled', source.name, flush=True)
        subprocess.run([compiler, '-shared', str(exports), *objects, *map(str, libraries),
                        '-lglu32', '-lopengl32', '-lgdi32', '-luser32', '-lws2_32',
                        '-o', str(package / 'Tkzinc.dll')], check=True,
                       stdout=log, stderr=subprocess.STDOUT)
    (package / 'pkgIndex.tcl').write_text(
        'package ifneeded Tkzinc %s [list load [file join $dir Tkzinc.dll] Tkzinc]\n' % version,
        encoding='utf-8')
    for source, destination in ((ROOT / 'Copyright', 'Copyright'),
                                (ROOT / 'third_party/glew/LICENSE.txt', 'LICENSE.glew'),
                                (tcl / 'license.terms', 'LICENSE.tcl'),
                                (tksrc / 'license.terms', 'LICENSE.tk')):
        shutil.copyfile(source, package / destination)
    (package / 'build-info.json').write_text(json.dumps({
        'python': sys.version, 'python_executable': sys.executable, 'bits': bits,
        'tcl': tcl_version, 'tk': tk_version, 'compiler': compiler, 'target': target,
        'tkzinc': version, 'glew': '2.3.1',
    }, indent=2) + '\n', encoding='utf-8')
    print('\nBuilt', package)
    print('Build log:', log_path)
    print("PowerShell: $env:TCLLIBPATH = '{%s}'" % build.as_posix())
    print('Then: py -3 Python/demos/testGraphics.py')


if __name__ == '__main__':
    try:
        main()
    except (RuntimeError, OSError, subprocess.CalledProcessError) as error:
        sys.exit('Build failed: %s (see build.log in the build directory)' % error)
