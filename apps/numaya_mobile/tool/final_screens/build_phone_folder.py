"""Builds the flat phone-review folder and its sibling index from final_screens_capture_test.dart.

Usage: python build_phone_folder.py --flat <folder> --gallery <folder> --commit <sha> --branch <name>
  --coverage <md> <capture dir>
The flat folder holds only the original PNGs, numbered in flow order, plus SCREEN_LIST.txt. The
sibling gallery folder holds index.html, thumbnails, SCREEN_INDEX.md and COVERAGE.md. Verifies that
every capture is copied once, byte for byte.
"""
import argparse, csv, hashlib, html, os, re, shutil, urllib.parse

from PIL import Image

ap = argparse.ArgumentParser()
for a in ('flat', 'gallery', 'commit', 'branch', 'coverage'):
    ap.add_argument('--' + a, required=True)
ap.add_argument('capture')
A = ap.parse_args()

SECTION = re.compile(r'^(.*)-(\d\d)-(top|middle|bottom)$')
TOP_ONLY = ('Discover-out-of-likes',)
STATE_FIX = {'Compliments-populated': 'Two requests', 'Profile-setup-hub': '45% complete', 'Support-requests': 'Empty, no requests yet'}
OB, DI, LI, CH, PR, SE, SA = '01-Onboarding', '02-Discover', '03-Likes-Compliments', '05-Chat', '06-Profile', '10-Settings', '11-Safety-Help-Legal'
# (anchor, [rows placed straight after it]): sheets and states beside the screen that opens them.
MOVES = [
    (f'{OB}/20-Photo-tips-sheet', [f'{OB}/41-Photo-options-menu']),
    (f'{DI}/09-Allowance-used', [f'{DI}/11-Discover-out-of-likes']),
    (f'{LI}/11-Send-compliment-typed', [f'{LI}/41-Send-compliment-keyboard-open', f'{LI}/42-Send-compliment-discard-sheet', f'{LI}/43-Send-compliment-sent', f'{LI}/44-Send-compliment-already-sent', f'{LI}/45-Send-compliment-failed', f'{LI}/46-Send-compliment-no-credits']),
    (f'{CH}/10-Unmatch-sheet', [f'{SA}/02-Report-person-sheet', f'{SA}/03-Block-person-sheet']),
    (f'{CH}/11-Message-actions-menu', [f'{CH}/41-Chat-replying', f'{CH}/42-Chat-attach-menu', f'{CH}/43-Chat-photo-pending', f'{CH}/44-Chat-photo-sent', f'{CH}/45-Chat-photo-viewer', f'{CH}/46-Chat-reply-to-photo', f'{CH}/47-Chat-quoted-photo', f'{CH}/48-Chat-reply-to-long-text', f'{CH}/49-Chat-typed-send', f'{CH}/50-Chat-quoted-long-text', f'{CH}/51-Chat-quote-unavailable', f'{CH}/52-Chat-voice-recording', f'{CH}/53-Chat-voice-preview', f'{CH}/54-Chat-voice-sent', f'{CH}/55-Chat-voice-playing', f'{CH}/56-Chat-send-failed']),
    (f'{PR}/02-Edit-profile', [f'{PR}/07-Edit-bio-sheet', f'{PR}/08-Height-sheet', f'{PR}/09-Languages-sheet', f'{PR}/10-Work-sheet', f'{PR}/11-Exercise-choice-sheet']),
    (f'{SE}/09-Delete-account', [f'{SE}/41-Delete-confirm-sheet']),
    (f'{SA}/07-Support-requests', [f'{SA}/41-Support-requests-populated']),
]
RENAME_FLOW = {f'{SA}/02-Report-person-sheet': CH, f'{SA}/03-Block-person-sheet': CH}

rows = {}
for r in csv.DictReader(open(os.path.join(A.capture, 'shots.tsv'), encoding='utf-8'), delimiter='\t'):
    path = os.path.join(A.capture, 'shots', r['file'])
    assert os.path.exists(path) and os.path.getsize(path) > 1000, r['file']
    flow, name = r['file'][:-4].split('__', 1)
    m = SECTION.match(name)
    base = m.group(1) if m else name
    if m and base.split('-', 1)[1] in TOP_ONLY and m.group(3) != 'top':
        continue
    key = f'{flow}/{base}'
    state = re.sub(r' \((top|middle|bottom), section \d+ of \d+\)$', '', r['kind'])
    e = rows.setdefault(key, {'key': key, 'flow': flow, 'base': base, 'state': STATE_FIX.get(base.split('-', 1)[1], state), 'nav': r['fixture'], 'files': []})
    e['files'].append((name, path, m.group(3) if m and base.split('-', 1)[1] not in TOP_ONLY else None))

order = [rows[k] for k in sorted(rows)]


def index(key):
    hits = [i for i, r in enumerate(order) if r['key'] == key]
    assert len(hits) == 1, key
    return hits[0]


for anchor, moved in MOVES:
    after = anchor
    for k in moved:
        row = order.pop(index(k))
        order.insert(index(after) + 1, row)
        after = k
for k, flow in RENAME_FLOW.items():
    order[index(k)]['flow'] = flow


def new_name(n, flow, name, top_only):
    label = flow.split('-', 1)[1]
    screen = name.split('-', 1)[1]
    if top_only:
        screen = SECTION.match(name).group(1).split('-', 1)[1]
    first = label.split('-')[0].lower().rstrip('s')
    if screen.lower().startswith(first + '-') or screen.lower().startswith(first + 's-'):
        screen = screen.split('-', 1)[1]
    return f'{n:03d}-{label}-{screen[0].upper()}{screen[1:]}.png'


plan = []
for r in order:
    for name, path, where in r['files']:
        top_only = r['base'].split('-', 1)[1] in TOP_ONLY
        d = new_name(len(plan) + 1, r['flow'], name, top_only)
        plan.append((path, d, r, where))

for p in (A.flat, A.gallery):
    assert not os.path.exists(p), p
os.makedirs(A.flat)
os.makedirs(os.path.join(A.gallery, '_thumbnails'))
digest = lambda p: hashlib.sha256(open(p, 'rb').read()).hexdigest()
problems = []
for path, d, r, where in plan:
    dst = os.path.join(A.flat, d)
    shutil.copyfile(path, dst)
    if digest(path) != digest(dst):
        problems.append('bytes ' + d)
    im = Image.open(dst)
    if im.size != (1080, 2424):
        problems.append(f'size {d} {im.size}')
    t = im.convert('RGB')
    t.thumbnail((300, 674), Image.LANCZOS)
    t.save(os.path.join(A.gallery, '_thumbnails', d[:-4] + '.jpg'), 'JPEG', quality=78)
with open(os.path.join(A.flat, 'SCREEN_LIST.txt'), 'w', encoding='utf-8', newline='\r\n') as f:
    for path, d, r, where in plan:
        f.write(f"{d}\t{r['nav']}\t{r['state']}\n")

names = sorted(e.name for e in os.scandir(A.flat) if e.name.endswith('.png'))
assert len(names) == len(plan) == len({n.lower() for n in names}), 'duplicates or missing'
assert not [e for e in os.scandir(A.flat) if e.is_dir()], 'subfolder'
assert [n[:3] for n in names] == [f'{i:03d}' for i in range(1, len(names) + 1)], 'numbering'
hashes = [digest(os.path.join(A.flat, n)) for n in names]
dup = len(hashes) - len(set(hashes))

is_sheet = lambda b: '-sheet' in b or b.endswith('-menu') or b.endswith('permission-prompt')
entries, sheets = len(order), sum(1 for r in order if is_sheet(r['base']))

flat_name = os.path.basename(A.flat.rstrip('/\\'))
md = [f'# Numaya MVP V7 screen index\n\nBranch `{A.branch}`, app commit `{A.commit}`. Real Pixel 10 AVD screenshots (API 36, 1080 x 2424, density 420, font 1.0).\n\n**{entries} unique screens and states** ({entries - sheets} screens or page states, {sheets} sheets and menus), **{len(plan)} PNG files** including scrolling sections.\n\n| File | Screen | State | How to get there |\n|---|---|---|---|\n']
for path, d, r, where in plan:
    md.append(f"| `{d}` | {r['base'].split('-', 1)[1].replace('-', ' ')} | {r['state']}{' (' + where + ')' if where else ''} | {r['nav']} |\n")
open(os.path.join(A.gallery, 'SCREEN_INDEX.md'), 'w', encoding='utf-8', newline='\n').write(''.join(md))
shutil.copyfile(A.coverage, os.path.join(A.gallery, 'COVERAGE.md'))

esc = html.escape
q = urllib.parse.quote
flows = {}
for row in order:
    flows.setdefault(row['flow'], []).append(row)
by_row = {}
for path, d, r, where in plan:
    by_row.setdefault(r['key'], []).append((d, where))
nav = ''.join(f'<a href="#{esc(f)}">{esc(f.split("-", 1)[1])} <span>{len(v)}</span></a>' for f, v in flows.items())
sec = []
for f, rs in flows.items():
    cards = []
    for r in rs:
        title = r['base'].split('-', 1)[1].replace('-', ' ')
        figs = ''.join(f'<a class="shot" href="../{q(flat_name)}/{q(d)}" target="_blank" rel="noopener"><img loading="lazy" src="_thumbnails/{q(d[:-4])}.jpg" width="150" height="337" alt="{esc(title)}">{f"<span class=part>{esc(w)}</span>" if w else ""}</a>' for d, w in by_row[r['key']])
        n = min(len(by_row[r['key']]), 6)
        cards.append(f'<article style="--n:{n}"><div class="shots">{figs}</div><h3>{esc(title)}</h3><p>{esc(r["state"])}</p><p class="nav">{esc(r["nav"])}</p></article>')
    sec.append(f'<section id="{esc(f)}"><h2>{esc(f.split("-", 1)[1])}</h2><div class="grid">{"".join(cards)}</div></section>')
open(os.path.join(A.gallery, 'index.html'), 'w', encoding='utf-8', newline='\n').write(f'''<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Numaya MVP V5 Screens</title>
<style>
:root{{--bg:#f4f4f4;--card:#fff;--ink:#111;--muted:#5f5f5f;--brand:#5b4bb0}}
*{{box-sizing:border-box}}body{{margin:0;background:var(--bg);color:var(--ink);font:15px/1.45 system-ui,"Segoe UI",sans-serif}}
header{{padding:24px 16px 8px;max-width:1500px;margin:auto}}h1{{margin:0 0 4px;font-size:26px}}header p{{margin:0;color:var(--muted)}}
nav{{position:sticky;top:0;z-index:2;background:var(--bg);padding:10px 16px;display:flex;gap:6px;overflow-x:auto;border-bottom:1px solid #ddd}}
nav a{{flex:none;padding:6px 12px;background:var(--card);border-radius:99px;color:var(--ink);text-decoration:none;font-size:13px}}nav span{{color:var(--muted)}}
section{{max-width:1500px;margin:auto;padding:20px 16px;scroll-margin-top:52px}}h2{{font-size:20px;margin:0 0 12px}}
.grid{{display:flex;flex-wrap:wrap;gap:12px;align-items:flex-start}}article{{background:var(--card);border-radius:14px;padding:10px;max-width:100%;width:calc(150px*var(--n) + 6px*(var(--n) - 1) + 20px)}}
.shots{{display:flex;flex-wrap:wrap;gap:6px}}.shot{{position:relative;display:block;width:150px;max-width:100%;line-height:0}}.shot img{{width:100%;height:auto;border-radius:8px;background:#ddd;border:1px solid #e3e3e3}}
.shot:focus-visible{{outline:3px solid var(--brand);outline-offset:2px}}.part{{position:absolute;left:4px;bottom:4px;background:#000b;color:#fff;font-size:11px;line-height:16px;padding:0 6px;border-radius:99px}}
h3{{font-size:14px;margin:8px 0 0}}article p{{margin:0;font-size:13px;color:var(--muted)}}p.nav{{font-size:12px}}
</style></head><body><header><h1>Numaya MVP V7 screens</h1><p>{entries} screens and states, {len(plan)} PNGs. App commit {esc(A.commit[:7])}, Pixel 10 emulator, font 1.0. Click a thumbnail for the full-resolution PNG. <a href="COVERAGE.md">Coverage</a> · <a href="SCREEN_INDEX.md">Screen index</a></p></header><nav>{nav}</nav>{"".join(sec)}</body></html>''')
print(f'entries {entries} sheets {sheets} pngs {len(plan)} problems {len(problems)} identical-bytes {dup}')
for p in problems:
    print(p)
for path, d, r, where in plan:
    if any(k in d for k in ('Welcome', 'Keyboard', 'keyboard', 'Compliment-sent', 'Report-person', 'Support-requests-pop')):
        print(d)
print(plan[-1][1])
