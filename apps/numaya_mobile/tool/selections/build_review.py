"""Builds the offline selected-design review page (selections pass, 2026-11-13).

Usage: python build_review.py --shots <flat screenshot folder> --before <earlier flat folder>
         --out <review folder> --commit <sha> --evidence <JOURNEY_EVIDENCE.csv> --report <FINAL_REVIEW.md>
         --branch <branch> --coverage <COVERAGE.md> --capture <capture run folder> [--journey <device walk PNGs>]

The page uses relative paths only (no server): before/after pairs copied into the review folder,
the full screen index in screens/, and the journey evidence table. The images show the private
demo photos: the folder stays local.
"""
import argparse, csv, html, os, shutil, subprocess, sys

ap = argparse.ArgumentParser()
for a in ('shots', 'before', 'out', 'commit', 'evidence', 'report', 'branch', 'coverage', 'capture'):
    ap.add_argument('--' + a, required=True)
ap.add_argument('--journey', help='device-walk screenshots, copied to journey/ (the evidence paths point there)')
A = ap.parse_args()
here = os.path.dirname(os.path.abspath(__file__))
app = os.path.dirname(os.path.dirname(here))
esc = html.escape

if os.path.exists(A.out):
    sys.exit('review folder exists: ' + A.out)
os.makedirs(os.path.join(A.out, 'pairs'))

# The full screen index, linking to the flat folder by relative path.
r = subprocess.run([sys.executable, '-X', 'utf8', os.path.join(app, 'tool', 'final_screens', 'build_phone_folder.py'),
                    '--flat', A.shots, '--gallery', os.path.join(A.out, 'screens'), '--commit', A.commit,
                    '--branch', A.branch, '--coverage', A.coverage, A.capture], capture_output=True, text=True, encoding='utf-8')
print(r.stdout[-400:], r.stderr[-1500:])
if r.returncode:
    sys.exit(1)

# Capture keys that predate Compliments living in Messages, shown under their current names
# (in the PNGs, thumbnails and every index together).
REN = [
    ('Likes-Compliments-Compliments-populated', 'Messages-Compliments-in-chat-list'),
    ('Likes-Compliments-Compliment-request-photo', 'Messages-Compliment-conversation-photo'),
    ('Likes-Compliments-Compliment-request-prompt', 'Messages-Compliment-conversation-prompt'),
    ('Likes-Compliments-Compliment-options-menu', 'Messages-Compliment-conversation-menu'),
    ('Likes-Compliments-Dismiss-compliment-sheet', 'Messages-Compliment-dismiss-sheet'),
    ('Likes-Compliments-Send-compliment', 'Compliments-Send-compliment'),
    ('Likes-Compliments-', 'Likes-'),
]
screens = os.path.join(A.out, 'screens')
thumbs = os.path.join(screens, '_thumbnails')
def renamed(name):
    for a, b in REN:
        if a in name:
            return name.replace(a, b)
    return name
for folder in (A.shots, thumbs):
    for f in os.listdir(folder):
        g = renamed(f)
        if g != f:
            os.rename(os.path.join(folder, f), os.path.join(folder, g))
for doc in (os.path.join(A.shots, 'SCREEN_LIST.txt'), os.path.join(screens, 'index.html'), os.path.join(screens, 'SCREEN_INDEX.md'), os.path.join(screens, 'COVERAGE.md')):
    if os.path.exists(doc):
        t = open(doc, encoding='utf-8').read()
        for a, b in REN:
            t = t.replace(a, b)
        open(doc, 'w', encoding='utf-8', newline='').write(t)
for name in ('SCREEN_INDEX.md', 'COVERAGE.md'):
    if os.path.exists(os.path.join(screens, name)):
        shutil.copyfile(os.path.join(screens, name), os.path.join(A.shots, name))
assert not [f for f in os.listdir(A.shots) if 'Likes-Compliments' in f]


def find(folder, needle):
    hits = sorted(f for f in os.listdir(folder) if needle in f and f.endswith('.png'))
    return hits[0] if hits else None

PAIRS = [
    ('Discover', 'O, Name on photo, prompt card, with notes', 'Discover-Profile-01-top',
     'No text shadow on the name: a smooth bottom gradient that fades upward carries the contrast (adaptive, 32 to 62% at the bottom edge, measured per photo). The job line has a briefcase icon. The Compliment button stays on each photo and prompt. No blur: a blur band without a soft mask shows a hard edge.'),
    ('Profile', 'A, Compact hub, with notes', 'Profile-Hub-01-top',
     'A completion pill with the same percentage as Complete your profile (where the setup row leads). A larger circular photo. Credits and streak tiles share one anatomy: icon, number, label, one short line. Neither has a bar, because a balance has no denominator. Outline icons in both tiles.'),
    ('Messages', 'A, Whose turn', 'Messages-All-01-top',
     'Your turn and Waiting on them replace the filter row, using the existing your-move state. A Compliment states its condition in words. Tabler has no filled version of the Compliment glyph, so that mark stays outline.'),
    ('Received Compliment', 'A, Compact context card, with notes', 'Compliment-conversation-photo',
     'The Compliment is the sender’s incoming message. Your photo (or your own answer) is quoted inside the bubble with its thumbnail. No sender photo card and no separate card above.'),
    ('Received Compliment, prompt', 'A, as above', 'Compliment-conversation-prompt',
     'The quote shows your own answer to the prompt.'),
    ('Compliment credits', 'O, Purple balance card, with notes', 'Wallet-Store-Free-01-top',
     'The purple card follows the shared summary anatomy: icon and heading, the balance, a bar of its parts in spend order, then which part is which.'),
    ('Streak', 'O, Streak card, with notes', 'Streaks-Streak',
     'The same summary anatomy: icon and heading, the streak, seven day marks, then the day and today’s state.'),
    ('Welcome', 'Demo entry (review builds only)', 'Onboarding-Welcome',
     'A labelled Explore the demo link under the real sign-in buttons, with a note that it is a sample account on this phone. Release builds compile the demo service out, so it never ships.'),
]
cards = []
for title, choice, needle, note in PAIRS:
    after = find(A.shots, needle)
    before = find(A.before, needle)
    figs = []
    for label, folder, name in (('Before (replacement V8, ee87648)', A.before, before), (f'After ({A.commit[:7]})', A.shots, after)):
        if name:
            dst = f'{label.split(" ")[0].lower()}-{name}'
            shutil.copyfile(os.path.join(folder, name), os.path.join(A.out, 'pairs', dst))
            figs.append(f'<figure><a href="pairs/{esc(dst)}"><img src="pairs/{esc(dst)}" alt="{esc(title)}, {esc(label)}" loading="lazy"></a><figcaption>{esc(label)}</figcaption></figure>')
        else:
            figs.append(f'<figure><div class="none">No {esc(label.split(" ")[0].lower())} image</div><figcaption>{esc(label)}</figcaption></figure>')
    cards.append(f'<section><h2>{esc(title)}</h2><p class="choice">{esc(choice)}</p><p>{esc(note)}</p><div class="pair">{"".join(figs)}</div></section>')

rows = list(csv.reader(open(A.evidence, encoding='utf-8')))
table = '<table><thead><tr>' + ''.join(f'<th>{esc(h)}</th>' for h in rows[0]) + '</tr></thead><tbody>' + ''.join(
    '<tr>' + ''.join(f'<td class="{"s-" + esc(c.split(" ")[0].lower()) if i == 3 else ""}">{esc(c)}</td>' for i, c in enumerate(r)) + '</tr>' for r in rows[1:]) + '</tbody></table>'
shutil.copyfile(A.evidence, os.path.join(A.out, 'JOURNEY_EVIDENCE.csv'))
shutil.copyfile(A.report, os.path.join(A.out, 'FINAL_REVIEW.md'))
if A.journey:
    shutil.copytree(A.journey, os.path.join(A.out, 'journey'), ignore=shutil.ignore_patterns('*.xml', '*c.png'))
n = len([f for f in os.listdir(A.shots) if f.endswith('.png')])
page = f'''<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Numaya Selected Design Review</title>
<style>:root{{--ink:#18181b;--muted:#6b6b72;--line:#e6e6ea;--brand:#7262c7;--bg:#f4f4f5}}*{{box-sizing:border-box}}body{{margin:0;font:15px/1.45 system-ui,sans-serif;color:var(--ink);background:var(--bg)}}
header,main{{max-width:1100px;margin:0 auto;padding:20px 16px}}h1{{font-size:26px;margin:0 0 6px}}h2{{font-size:19px;margin:0 0 4px}}.meta{{color:var(--muted)}}
nav a{{display:inline-block;margin:4px 8px 4px 0;color:var(--brand)}}section{{background:#fff;border-radius:18px;padding:18px;margin:0 0 18px}}.choice{{color:var(--brand);font-weight:600;margin:0 0 6px}}
.pair{{display:grid;grid-template-columns:repeat(auto-fit,minmax(220px,1fr));gap:14px;margin-top:12px}}figure{{margin:0}}img{{width:100%;max-width:320px;border-radius:12px;border:1px solid var(--line);display:block}}figcaption{{color:var(--muted);font-size:13px;margin-top:4px}}
.none{{height:200px;display:grid;place-items:center;border:1px dashed var(--line);border-radius:12px;color:var(--muted);max-width:320px}}
table{{border-collapse:collapse;width:100%;font-size:13px;background:#fff}}td,th{{border:1px solid var(--line);padding:6px;vertical-align:top;text-align:left}}.s-pass{{color:#1f7a45;font-weight:600}}.s-blocked{{color:#b42318;font-weight:600}}.s-not_run,.s-partial{{color:#9a6700;font-weight:600}}
.wrap{{overflow-x:auto}}</style></head><body><header><h1>Numaya selected designs</h1>
<p class="meta">App source {esc(A.commit)} on {esc(A.branch)}. Owner export fx-da197b7-2026-11-13. After images: real Pixel 10 emulator screenshots (1080 x 2424, density 420, font 1.0) from this commit. Before images: the replacement V8 emulator folder (ee87648).</p>
<nav><a href="screens/index.html">All {n} screens</a><a href="#journeys">Journey evidence</a><a href="FINAL_REVIEW.md">Final review (text)</a><a href="JOURNEY_EVIDENCE.csv">Evidence CSV</a></nav></header>
<main>{"".join(cards)}<section id="journeys"><h2>Journey evidence</h2><p class="meta">PASS in one context does not promote another. Backend checks are BLOCKED: no development backend exists.</p><div class="wrap">{table}</div></section></main></body></html>'''
open(os.path.join(A.out, 'index.html'), 'w', encoding='utf-8', newline='\n').write(page)
print('review', A.out, 'screens', n)
