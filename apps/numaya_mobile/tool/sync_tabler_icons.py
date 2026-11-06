#!/usr/bin/env python3
"""Copy the Tabler SVGs that lib/core/design_system/icons/tabler_icons.dart names into
assets/icons/tabler/{outline,filled}/, unmodified, plus the MIT licence.

Usage: python3 tool/sync_tabler_icons.py <path to the extracted npm package @tabler/icons@3.50.0>
       (`npm pack @tabler/icons@3.50.0 && tar xzf tabler-icons-3.50.0.tgz` gives `package/`).
--check compares the bundled files with the package instead of copying.
"""
import json, pathlib, re, shutil, sys

VERSION = '3.50.0'
ROOT = pathlib.Path(__file__).resolve().parent.parent
MAP = ROOT / 'lib/core/design_system/icons/tabler_icons.dart'
OUT = ROOT / 'assets/icons/tabler'


def main() -> int:
    args = [a for a in sys.argv[1:] if not a.startswith('--')]
    check = '--check' in sys.argv
    pkg = pathlib.Path(args[0])
    version = json.loads((pkg / 'package.json').read_text())['version']
    if version != VERSION:
        print(f'expected @tabler/icons {VERSION}, found {version}')
        return 1
    src = MAP.read_text()
    wanted = set()
    # Entries may be wrapped by dart format, so whitespace (including newlines) is allowed.
    for outline, filled in re.findall(
        r"outline:\s*'([a-z0-9-]+)',\s*filled:\s*(?:'([a-z0-9-]+)'|null)", src
    ):
        wanted.add(('outline', outline))
        if filled:
            wanted.add(('filled', filled))
    bad = 0
    for style, name in sorted(wanted):
        a = pkg / 'icons' / style / f'{name}.svg'
        b = OUT / style / f'{name}.svg'
        if not a.exists():
            print(f'missing upstream: {style}/{name}')
            bad += 1
            continue
        if check:
            if not b.exists() or a.read_bytes() != b.read_bytes():
                print(f'differs: {style}/{name}')
                bad += 1
        else:
            b.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(a, b)
    if not check:
        shutil.copyfile(pkg / 'LICENSE', OUT / 'LICENSE')
        # Drop files the map no longer names.
        for style in ('outline', 'filled'):
            for f in (OUT / style).glob('*.svg'):
                if (style, f.stem) not in wanted:
                    f.unlink()
    print(f'{len(wanted)} Tabler SVGs {"checked" if check else "synced"}, {bad} problems')
    return 1 if bad else 0


if __name__ == '__main__':
    sys.exit(main())
