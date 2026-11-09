"""Assembles the screen-by-screen review folder from final_screens_capture_test.dart captures.

Usage: python build_index.py --out <folder> --commit <sha> --branch <name> --coverage <md> <capture dir> [<capture dir>...]
Later capture dirs replace same-named files from earlier ones. Writes numbered flow folders of the
original PNGs (byte-for-byte), _thumbnails/, index.html (offline, each thumbnail opens its PNG),
SCREEN_INDEX.md and COVERAGE.md.
"""
import argparse, csv, hashlib, html, os, re, shutil, urllib.parse

from PIL import Image

ap = argparse.ArgumentParser()
ap.add_argument('--out', required=True)
ap.add_argument('--commit', required=True)
ap.add_argument('--branch', required=True)
ap.add_argument('--coverage', required=True)
ap.add_argument('captures', nargs='+')
a = ap.parse_args()

# Only the first section matters for these states: the rest repeats a screen captured in full.
TOP_ONLY = ('Discover-out-of-likes', 'Profile-old-link-note')
STATE_FIX = {'Compliments-populated': 'Two requests', 'Profile-setup-hub': '45% complete', 'Support-requests': 'Empty, no requests yet'}
SECTION = re.compile(r'^(.*)-(\d\d)-(top|middle|bottom)$')

shots = {}
for cap in a.captures:
    with open(os.path.join(cap, 'shots.tsv'), encoding='utf-8') as f:
        for r in csv.DictReader(f, delimiter='\t'):
            path = os.path.join(cap, 'shots', r['file'])
            if os.path.exists(path) and os.path.getsize(path) > 1000:
                shots[r['file']] = (r, path)

flows = {}
for fname, (r, path) in sorted(shots.items()):
    flow, name = fname[:-4].split('__', 1)
    m = SECTION.match(name)
    base = m.group(1) if m else name
    key = base.split('-', 1)[1]
    if m and key in TOP_ONLY:
        if m.group(3) != 'top':
            continue
        name, m = base, None
    state = re.sub(r' \((top|middle|bottom), section \d+ of \d+\)$', '', r['kind'])
    flows.setdefault(flow, {}).setdefault(base, {'title': key.replace('-', ' '), 'state': STATE_FIX.get(key, state), 'nav': r['fixture'], 'files': []})['files'].append((name, path, m.group(3) if m else None))

os.makedirs(a.out)
hashes, problems, png_count = {}, [], 0
for flow, entries in flows.items():
    os.makedirs(os.path.join(a.out, flow))
    os.makedirs(os.path.join(a.out, '_thumbnails', flow))
    for base, e in entries.items():
        for name, path, _ in e['files']:
            dest = os.path.join(a.out, flow, name + '.png')
            shutil.copyfile(path, dest)
            png_count += 1
            im = Image.open(dest)
            if im.size != (1080, 2424):
                problems.append(f'{name}: size {im.size}')
            digest = hashlib.sha256(im.convert('RGB').crop((0, 130, 1080, 2424)).tobytes()).hexdigest()
            if digest in hashes and hashes[digest] != (flow, base):
                problems.append(f'{flow}/{name} is identical to {hashes[digest]}')
            hashes.setdefault(digest, (flow, base))
            thumb = im.convert('RGB')
            thumb.thumbnail((300, 674), Image.LANCZOS)
            thumb.save(os.path.join(a.out, '_thumbnails', flow, name + '.jpg'), 'JPEG', quality=78)

entries_total = sum(len(v) for v in flows.values())
is_sheet = lambda b: '-sheet' in b or b.endswith('-menu') or b.endswith('permission-prompt')
sheets = sum(1 for v in flows.values() for b in v if is_sheet(b))

# SCREEN_INDEX.md
md = [f'# Numaya screen index\n\nBranch `{a.branch}`, commit `{a.commit}`. Real screenshots from the Pixel 10 AVD emulator (API 36, 1080 x 2424, density 420, font scale 1.0).\n\n**{entries_total} unique screens and states** ({entries_total - sheets} screens or page states, {sheets} sheets and menus), **{png_count} PNG files**.\n']
for flow, entries in flows.items():
    md.append(f'\n## {flow}\n\n| Screen | State | File(s) | How to get there |\n|---|---|---|---|\n')
    for base, e in entries.items():
        files = '<br>'.join(f'`{flow}/{n}.png`' for n, _, _ in e['files'])
        md.append(f"| {e['title']} | {e['state']} | {files} | {e['nav']} |\n")
open(os.path.join(a.out, 'SCREEN_INDEX.md'), 'w', encoding='utf-8', newline='\n').write(''.join(md))
shutil.copyfile(a.coverage, os.path.join(a.out, 'COVERAGE.md'))

# index.html
esc = html.escape
url = lambda *p: '/'.join(urllib.parse.quote(x) for x in p)
nav = ''.join(f'<a href="#{esc(f)}">{esc(f)} <span>{len(v)}</span></a>' for f, v in flows.items())
body = []
for flow, entries in flows.items():
    cards = []
    for base, e in entries.items():
        figs = ''.join(
            f'<a class="shot" href="{url(flow, n + ".png")}" target="_blank" rel="noopener" title="Open the full-resolution PNG">'
            f'<img loading="lazy" src="{url("_thumbnails", flow, n + ".jpg")}" width="150" height="337" alt="{esc(e["title"])}{" " + w if w else ""}">'
            f'{f"<span class=part>{esc(w)}</span>" if w else ""}</a>'
            for n, _, w in e['files'])
        count = len(e['files'])
        cards.append(f'<article style="--n:{min(count, 6)}"><div class="shots">{figs}</div><h3>{esc(e["title"])}</h3><p>{esc(e["state"])}</p><p class="nav">{esc(e["nav"])}</p></article>')
    body.append(f'<section id="{esc(flow)}"><h2>{esc(flow)}</h2><div class="grid">{"".join(cards)}</div></section>')
page = f'''<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Numaya Final Screenshots</title>
<style>
:root{{--bg:#f4f4f4;--card:#fff;--ink:#111;--muted:#5f5f5f;--brand:#5b4bb0}}
*{{box-sizing:border-box}}body{{margin:0;background:var(--bg);color:var(--ink);font:15px/1.45 system-ui,"Segoe UI",sans-serif}}
header{{padding:24px 16px 8px;max-width:1500px;margin:auto}}h1{{margin:0 0 4px;font-size:26px}}header p{{margin:0;color:var(--muted)}}
nav{{position:sticky;top:0;z-index:2;background:var(--bg);padding:10px 16px;display:flex;gap:6px;overflow-x:auto;border-bottom:1px solid #ddd}}
nav a{{flex:none;padding:6px 12px;background:var(--card);border-radius:99px;color:var(--ink);text-decoration:none;font-size:13px}}nav span{{color:var(--muted)}}
section{{max-width:1500px;margin:auto;padding:20px 16px;scroll-margin-top:52px}}h2{{font-size:20px;margin:0 0 12px}}
.grid{{display:flex;flex-wrap:wrap;gap:12px;align-items:flex-start}}
article{{background:var(--card);border-radius:14px;padding:10px;max-width:100%;width:calc(150px*var(--n) + 6px*(var(--n) - 1) + 20px)}}
.shots{{display:flex;flex-wrap:wrap;gap:6px}}.shot{{position:relative;display:block;width:150px;max-width:100%;line-height:0}}
.shot img{{width:100%;height:auto;border-radius:8px;background:#ddd;border:1px solid #e3e3e3}}.shot:focus-visible{{outline:3px solid var(--brand);outline-offset:2px}}
.part{{position:absolute;left:4px;bottom:4px;background:#000b;color:#fff;font-size:11px;line-height:16px;padding:0 6px;border-radius:99px}}
h3{{font-size:14px;margin:8px 0 0}}article p{{margin:0;font-size:13px;color:var(--muted)}}p.nav{{font-size:12px}}
</style></head><body><header><h1>Numaya Final Screenshots</h1><p>{entries_total} screens and states, {png_count} PNGs. Commit {esc(a.commit[:7])}, Pixel 10 emulator, font scale 1.0. Click any thumbnail for the full-resolution PNG. <a href="COVERAGE.md">Coverage list</a> · <a href="SCREEN_INDEX.md">Screen index</a></p></header><nav>{nav}</nav>{"".join(body)}</body></html>'''
open(os.path.join(a.out, 'index.html'), 'w', encoding='utf-8', newline='\n').write(page)
print(f'entries {entries_total} sheets {sheets} pngs {png_count}')
for f, v in flows.items():
    print(f, len(v), sum(len(e['files']) for e in v.values()))
print('problems', len(problems))
for p in problems:
    print(p)
