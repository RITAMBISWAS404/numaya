#!/usr/bin/env python3
"""Converts the web app's variable fonts (Fontsource woff2, SIL OFL 1.1) to TTF for Flutter.

Run from the repository root after `npm install`:
    pip install fonttools brotli
    python3 apps/numaya_mobile/tool/convert_fonts.py

The Fontsource files are the Latin subset. Names in other scripts fall back to the platform font.
"""
import shutil
from pathlib import Path

from fontTools.ttLib import TTFont

ROOT = Path(__file__).resolve().parents[3]
OUT = ROOT / "apps/numaya_mobile/assets/fonts"
FONTS = {
    "Fraunces-Variable.ttf": "node_modules/@fontsource-variable/fraunces/files/fraunces-latin-full-normal.woff2",
    "Inter-Variable.ttf": "node_modules/@fontsource-variable/inter/files/inter-latin-wght-normal.woff2",
}
LICENSES = {
    "OFL-Fraunces.txt": "node_modules/@fontsource-variable/fraunces/LICENSE",
    "OFL-Inter.txt": "node_modules/@fontsource-variable/inter/LICENSE",
}

OUT.mkdir(parents=True, exist_ok=True)
for name, src in FONTS.items():
    font = TTFont(ROOT / src)
    font.flavor = None
    font.save(OUT / name)
    axes = ", ".join(f"{a.axisTag} {a.minValue:g}-{a.maxValue:g}" for a in font["fvar"].axes)
    print(f"{name}: {axes}")
for name, src in LICENSES.items():
    shutil.copy(ROOT / src, OUT / name)
